ARG BASE_CONTAINER=unidata/unidata-standard:2026Jul17_210706_730d
FROM $BASE_CONTAINER

ENV DEFAULT_ENV_NAME=nps26f \
    EDITOR=nano \
    VISUAL=nano

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

COPY environment.yaml /tmp/cluster_environment.yaml
RUN mamba env update \
      -n unidata-standard \
      -f /tmp/cluster_environment.yaml && \
    mamba clean --all -f -y && \
    conda rename -n unidata-standard $DEFAULT_ENV_NAME
