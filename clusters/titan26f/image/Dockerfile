# Heavily borrowed from docker-stacks/scipy-notebook/
# https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile

ARG BASE_CONTAINER=quay.io/jupyter/minimal-notebook:ubuntu-24.04
FROM $BASE_CONTAINER

LABEL maintainer="LROSE <lrose-help@lists.colostate.edu>"

# See https://github.com/NCAR/lrose-core/releases
# LROSE parameters
ENV LROSE_RELEASE="lrose-core-20261006" \
    LROSE_TARGET_OS="ubuntu_24.04" \
    LROSE_TARGET_ARCH="amd64" \
    PATH="/usr/local/lrose/bin:$PATH" \
    DEFAULT_ENV_NAME=lrose-hub-2026 \
    EDITOR=nano \
    VISUAL=nano

# Has to be on a different instruction to use the previously defined parameters
ENV LROSE_RELEASE_URL="https://github.com/NCAR/lrose-core/releases/download/${LROSE_RELEASE}/${LROSE_RELEASE}.${LROSE_TARGET_OS}.${LROSE_TARGET_ARCH}.deb"

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
      build-essential vim netcdf-bin emacs curl && \
    # LROSE
    wget ${LROSE_RELEASE_URL} -O /tmp/lrose.deb && \
    apt-get install -y /tmp/lrose.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD environment.yaml /tmp

# combine the RUN commands, to prevent intermediate docker images;
RUN mamba install --quiet --yes \
      'conda-forge::nb_conda_kernels' \
      'conda-forge::jupyter-server-proxy' \
      'conda-forge::nbgitpuller' \
      'conda-forge::ncview' && \
    mamba create --name lrose-hub-2026 -f /tmp/environment.yaml && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# LROSE auxiliary files
COPY --chown=1000:100 \
     files/update_workshop_material.ipynb \
     files/bashrc_lrose \
     files/condarc \
     files/default_kernel.py \
     /

RUN cat /bashrc_lrose >> /etc/skel/.bashrc

USER ${NB_USER}

WORKDIR "${HOME}"

