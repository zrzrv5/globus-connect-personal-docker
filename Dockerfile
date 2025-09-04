FROM ubuntu:22.04

# Metadata
LABEL maintainer="Rui Zhou <ruizhou@iastate.edu>" \
      description="Minimal headless Globus Connect Personal container"

# -----------------------------------------------------------------------------
# Arguments and environment
# -----------------------------------------------------------------------------
ARG TARGETARCH
ARG GCP_URL_AMD64=https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz
ARG GCP_URL_ARM64=https://downloads.globus.org/globus-connect-personal/linux_aarch64/stable/globusconnectpersonal-aarch64-latest.tgz
ARG USERNAME=gcp
ARG UID=10001

ENV HOME=/home/${USERNAME}

# -----------------------------------------------------------------------------
# Install minimal runtime dependencies
# -----------------------------------------------------------------------------
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        python3 \
        python3-tk \
        tini && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python

# -----------------------------------------------------------------------------
# Add dedicated non-root user
# -----------------------------------------------------------------------------
RUN useradd -m -u ${UID} -s /bin/bash ${USERNAME}

# -----------------------------------------------------------------------------
# Download and unpack Globus Connect Personal
# -----------------------------------------------------------------------------
WORKDIR /opt
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        GCP_URL=${GCP_URL_ARM64}; \
        GCP_TARBALL=globusconnectpersonal-aarch64-latest.tgz; \
    else \
        GCP_URL=${GCP_URL_AMD64}; \
        GCP_TARBALL=globusconnectpersonal-latest.tgz; \
    fi && \
    curl -fsSL ${GCP_URL} -o ${GCP_TARBALL} && \
    tar xzf ${GCP_TARBALL} && \
    rm ${GCP_TARBALL} && \
    mv globusconnectpersonal-* globusconnectpersonal && \
    ln -s /opt/globusconnectpersonal/globusconnectpersonal /usr/local/bin/gcp

# -----------------------------------------------------------------------------
# Copy entrypoint script
# -----------------------------------------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# -----------------------------------------------------------------------------
# Switch to unprivileged user
# -----------------------------------------------------------------------------
USER ${USERNAME}
WORKDIR ${HOME}

# -----------------------------------------------------------------------------
# Default command
# -----------------------------------------------------------------------------
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
CMD ["gcp", "-help"]
