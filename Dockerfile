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
        python3-dev \
        libpython3.6 \
        libssl1.1 \
        libssl-dev \
        libffi6 \
        libffi-dev \
        libglib2.0-0 \
        libgobject-2.0-0 \
        libgio-2.0-0 \
        libgmodule-2.0-0 \
        libpcre3 \
        libgtk2.0-0 \
        libgdk-pixbuf2.0-0 \
        libcairo2 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libpangoft2-1.0-0 \
        libatk1.0-0 \
        libx11-6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxcursor1 \
        libxcomposite1 \
        libxdamage1 \
        libxinerama1 \
        libice6 \
        libgl1-mesa-glx \
        libegl1-mesa \
        libpng16-16 \
        libreadline8 \
        libncurses5 \
        libtinfo5 \
        libgraphite2-3 \
        libthai0 \
        libfribidi0 \
        libharfbuzz0b \
        libpixman-1-0 \
        libxcb-shm0 \
        libxcb-render0 \
        libjbig0 \
        libjpeg62-turbo \
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
