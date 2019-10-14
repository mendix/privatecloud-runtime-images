FROM registry.access.redhat.com/ubi8/ubi-minimal

# Base layer: prerequisites
# tar & gzip to download the runtime
# java for the runtime
# Mendix directories

RUN microdnf install tar gzip java-1.8.0-openjdk-headless && \
    microdnf clean all && \
    mkdir -p /opt/mendix/app && \
    mkdir -p /opt/mendix/app/data/database /opt/mendix/app/data/files /opt/mendix/app/data/model-upload /opt/mendix/app/data/tmp && \
    mkdir -p /opt/mendix/app/.java && \
    chmod g+rw /etc/passwd && \
    chgrp -R 0 /opt/mendix/app && \
    chmod -R g=u /opt/mendix/app

# Mendix Runtime layer: MxRuntime matching the app version
ARG MX_VERSION
ARG DOWNLOAD_URL=https://download.mendix.com/runtimes/

# Startup scripts
COPY *.sh /opt/mendix/app/

# Download Mendix runtime
# Set permissions
RUN mkdir -p /opt/mendix/runtime && \
    cd /opt/mendix/runtime && \
    curl -sL "${DOWNLOAD_URL}mendix-${MX_VERSION}.tar.gz" | tar xz --strip-components=2 && \
    chown -R root:root /opt/mendix/runtime && \
    chmod u+x /opt/mendix/app/*.sh && \
    chgrp -R 0 /opt/mendix/app && \
    chmod -R g=u /opt/mendix/app