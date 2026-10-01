ARG BASE_CONTAINER=unidata/unidata-standard:2026Aug13_175701_dfae
FROM $BASE_CONTAINER

ENV DEFAULT_ENV_NAME=rsmas26f \
    EDITOR=nano \
    VISUAL=nano

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

COPY environment.yaml /tmp/cluster_environment.yaml

COPY environment_wf.yaml /tmp/environment_wf.yaml

RUN mamba env update \
      -n unidata-standard \
      -f /tmp/cluster_environment.yaml && \
    conda rename -n unidata-standard $DEFAULT_ENV_NAME && \
    mamba env create \
      -f /tmp/environment_wf.yaml && \
    mamba clean --all -f -y
