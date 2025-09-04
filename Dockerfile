FROM python:3.11-slim-bullseye
# Modified from Ronny Moreas's script


RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip3 install --no-cache-dir globus-cli

ARG TARGETARCH
ARG GCP_VERSION=3.2.7

RUN if [ "$TARGETARCH" = "arm64" ]; then \
        GCP_URL="https://downloads.globus.org/globus-connect-personal/v3/linux_aarch64/stable/globusconnectpersonal-aarch64-${GCP_VERSION}.tgz"; \
    else \
        GCP_URL="https://downloads.globus.org/globus-connect-personal/v3/linux/stable/globusconnectpersonal-${GCP_VERSION}.tgz"; \
    fi && \
    curl -s "${GCP_URL}" | (tar xzf - -C /opt/ && mv /opt/globusconnectpersonal-* /opt/gcp)

COPY entrypoint.sh /opt/gcp

ARG GCP_UID=1000
ARG GCP_GID=100
ARG GCP_HOME=/home/globus

ENV GCP_UID=${GCP_UID}
ENV GCP_GID=${GCP_GID}
ENV GCP_CONFIG_PATH=${GCP_HOME}/.globusonline
ENV GCP_RESTRICT_PATHS=rw/data
ENV GCP_SHARED_PATHS=rw/data

RUN adduser --uid $GCP_UID --gid $GCP_GID --disabled-password --gecos "Globus" --home ${GCP_HOME} globus
ENV PATH="/opt/gcp/:$PATH"

USER ${GCP_UID}
WORKDIR ${GCP_HOME}

ENTRYPOINT ["/opt/gcp/entrypoint.sh"]
CMD [ "start" ]