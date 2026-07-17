#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

usage() {
cat <<USAGE
Usage: $0 <target-dir> [--push] [-f <Dockerfile>]
    <target-dir>        Relative to git repo root, e.g. shared/unidata-standard
    [--push]            Optionally push the Docker image to DockerHub
    [-f <Dockerfile>]   Specify an alternate Dockerfile to use, relative to <target-dir>
USAGE
exit 1
}

if [ -z "$1" ]; then
    echo "Error: No target-dir provided."
    usage
fi

TARGET=$1
IMAGE_NAME=$(basename $TARGET)
PUSH_IMAGE=false
DOCKERFILE="Dockerfile"

LOG_OPTS=""
LOG_FILE="/dev/null"

# Parse optional arguments
shift
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
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

DATE_TAG=$(date "+%Y%b%d_%H%M%S")
RANDOM_HEX=$(openssl rand -hex 2)
TAG="${DATE_TAG}_${RANDOM_HEX}"
FULL_TAG="unidata/$IMAGE_NAME:$TAG"

GIT_ROOT=$(git rev-parse --show-toplevel)
BUILD_DIR=${GIT_ROOT}/${TARGET}

if [[ -n "$LOG_OPTS" ]]; then
    LOG_DIR=$GIT_ROOT/build_logs/${IMAGE_NAME}
    mkdir -p $LOG_DIR
    LOG_FILE=${LOG_DIR}/${TAG}.log
fi


# Build the Docker image
cd $BUILD_DIR
echo "Building Docker image in $BUILD_DIR with tag: $FULL_TAG using Dockerfile: $DOCKERFILE" | tee -a $LOG_FILE
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
