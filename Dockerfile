FROM ubuntu:22.04

# Metadata
LABEL maintainer="Rui Zhou <ruizhou@iastate.edu>" \
      description="Minimal headless Globus Connect Personal container"

# -----------------------------------------------------------------------------
# Arguments and environment
# -----------------------------------------------------------------------------
ARG GCP_URL=https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz
ARG GCP_TARBALL=globusconnectpersonal-latest.tgz
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
        tini && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Add dedicated non-root user
# -----------------------------------------------------------------------------
RUN useradd -m -u ${UID} -s /bin/bash ${USERNAME}

# -----------------------------------------------------------------------------
# Download and unpack Globus Connect Personal
# -----------------------------------------------------------------------------
WORKDIR /opt
RUN curl -fsSL ${GCP_URL} -o ${GCP_TARBALL} && \
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
