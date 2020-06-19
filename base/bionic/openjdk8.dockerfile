FROM alpine:latest as builder

# Install curl
RUN apk add --no-cache curl

ARG MX_VERSION
ARG DOWNLOAD_URL=https://download.mendix.com/runtimes/

# Download Mendix Runtime
RUN cd /opt && \
    curl -sL "${DOWNLOAD_URL}mendix-${MX_VERSION}.tar.gz" | tar xz && \
    chown -R root:root /opt/${MX_VERSION}

FROM adoptopenjdk:8-jre-hotspot-bionic

# Base layer: prerequisites
# Mendix directories
RUN mkdir -p /opt/mendix/app/data/database /opt/mendix/app/data/files /opt/mendix/app/data/model-upload /opt/mendix/app/data/tmp && \
    mkdir -p /opt/mendix/app/.java && \
    chmod g+rw /etc/passwd && \
    chgrp -R 0 /opt/mendix/app && \
    chmod -R g=u /opt/mendix/app

# Mendix Runtime layer: MxRuntime matching the app version
ARG MX_VERSION

# Copy downloaded runtime
COPY --from=builder /opt/${MX_VERSION} /opt/mendix/

# Startup scripts
COPY *.sh /opt/mendix/app/

# Set permissions
RUN chown root:root /opt/mendix/runtime && \
    chmod u+x /opt/mendix/app/*.sh && \
    chgrp -R 0 /opt/mendix/app && \
    chmod -R g=u /opt/mendix/app

# App container configuration
USER 1001
ENV HOME /opt/mendix/app
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=utf-8
EXPOSE 8080

ENTRYPOINT ["/opt/mendix/app/entrypoint.sh"]
CMD ["/opt/mendix/app/mxruntime.sh"]
