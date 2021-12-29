FROM alpine:latest as builder

# Install curl
RUN apk add --no-cache curl

ARG MX_VERSION
ARG DOWNLOAD_URL=https://download.mendix.com/runtimes/
ARG MXAGENT_DOWNLOAD_URL=https://cdn.mendix.com/mx-buildpack/mx-agent/mx-agent-v0.12.0.jar

# Download Mendix Runtime
# Download MxAgent
# Set runtime owner to root (prevent modifications during runtime)
RUN cd /opt && \
    curl -sL "${DOWNLOAD_URL}mendix-${MX_VERSION}.tar.gz" | tar xz && \
    mkdir /opt/${MX_VERSION}/mxagent && \
    curl -sL -o /opt/${MX_VERSION}/mxagent/mx-agent.jar "${MXAGENT_DOWNLOAD_URL}" && \
    chown -R 0:0 /opt/${MX_VERSION}

FROM registry.access.redhat.com/ubi8/ubi-minimal

# Set the locale
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Set the user ID and home path
ENV USER_UID=1001 \
    HOME=/opt/mendix/app

# Base layer: prerequisites

# java for the runtime
# fontconfig for generating Excel reports and other documents
RUN microdnf update -y && \
    microdnf install java-1.8.0-openjdk-headless fontconfig -y && \
    microdnf clean all && \
    rm -rf /var/cache/yum

# Mendix directories
RUN mkdir -p /opt/mendix/app && \
    mkdir -p /opt/mendix/app/data/database /opt/mendix/app/data/files /opt/mendix/app/data/model-upload /opt/mendix/app/data/tmp && \
    mkdir -p /opt/mendix/app/.java/.userPrefs

# Mendix Runtime layer: MxRuntime matching the app version
ARG MX_VERSION

# Copy downloaded runtime
COPY --from=builder /opt/${MX_VERSION} /opt/mendix/

# Startup scripts
COPY *.sh /opt/mendix/app/

# Create user (for non-OpenShift clusters) and set permissions
# chown to user 1001 for non-OpenShift clusters
# set group 0 (root) for OpenShift (we don't know what the runtime UID will be)
RUN echo "mendix:x:${USER_UID}:${USER_UID}:mendix user:${HOME}:/sbin/nologin" >> /etc/passwd && \
    chown -R ${USER_UID}:0 /opt/mendix/app && \
    chmod ug+x /opt/mendix/app/*.sh && \
    chmod -R g=u /opt/mendix/app

# App container configuration
USER ${USER_UID}
EXPOSE 8080

CMD ["/opt/mendix/app/mxruntime.sh"]
