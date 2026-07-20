#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

usage() {
cat <<USAGE
Usage: $0 <-c|--cluster|-s|--shared <name>> [--push] [-f <Dockerfile>]
    <-c|--cluster>      The cluster found in ./clusters to build
    <-s|--shared>       The shared image found in ./images to build
    [--push]            Optionally push the Docker image to DockerHub
    [-f <Dockerfile>]   Specify an alternate Dockerfile to use, relative to <target-dir>
    [-l|--log]          Log to file in ./build_logs?
Example usage:
    bash $0 -c pyaos26f --log
    bash $0 -s unidata-standard --push
USAGE
exit 1
}

TARGET=""
IMAGE_NAME=""
PUSH_IMAGE=false
DOCKERFILE="Dockerfile"

LOG_OPTS=""
LOG_FILE="/dev/null"

GIT_ROOT=$(git rev-parse --show-toplevel)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --push)
            PUSH_IMAGE=true
            shift
            ;;
        -f)
            if [ -z "$2" ]; then
                echo "Error: -f requires a Dockerfile path"
                usage
            fi
            DOCKERFILE="$2"
            shift 2
            ;;
        --log|-l)
            LOG_OPTS="--progress=plain"
            shift
            ;;
        --cluster|-c)
            IMAGE_NAME=$2
            TARGET=${GIT_ROOT}/clusters/${IMAGE_NAME}/image
            # Ensure target exists
            stat $TARGET &> /dev/null || { echo "Error: $TARGET does not exist!" && usage; }
            shift 2
            ;;
        --shared|-s)
            IMAGE_NAME=$2
            TARGET=${GIT_ROOT}/images/${IMAGE_NAME}
            stat $TARGET &> /dev/null || { echo "Error: $TARGET does not exist!" && usage; }
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$IMAGE_NAME" ]]; then
    echo "Error: No build target provided."
    usage
fi

DATE_TAG=$(date "+%Y%b%d_%H%M%S")
RANDOM_HEX=$(openssl rand -hex 2)
TAG="${DATE_TAG}_${RANDOM_HEX}"
FULL_TAG="unidata/$IMAGE_NAME:$TAG"

if [[ -n "$LOG_OPTS" ]]; then
    LOG_DIR=$GIT_ROOT/build_logs/${IMAGE_NAME}
    mkdir -p $LOG_DIR
    LOG_FILE=${LOG_DIR}/${TAG}.log
fi


# Build the Docker image
cd $TARGET
echo "Building Docker image in $TARGET with tag: $FULL_TAG using Dockerfile: $DOCKERFILE" | tee -a $LOG_FILE
docker build --no-cache --pull --tag "$FULL_TAG" -f "$DOCKERFILE" $LOG_OPTS . 2>&1 | tee -a $LOG_FILE

echo "Docker image built successfully: $FULL_TAG" | tee -a $LOG_FILE

if $PUSH_IMAGE; then
    echo "Pushing Docker image to DockerHub: $FULL_TAG" | tee -a $LOG_FILE
    docker push "$FULL_TAG" 2>&1 | tee -a $LOG_FILE
    echo "Docker image pushed successfully: $FULL_TAG" | tee -a $LOG_FILE
else
    echo "Skipping Docker image push. Use '--push' to push the image." | tee -a $LOG_FILE
fi

echo "Thanks, come again!
Image produced: $FULL_TAG" | tee -a $LOG_FILE

exit 0
