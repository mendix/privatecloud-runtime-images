FROM alpine:latest as builder

ARG MX_VERSION
ARG DOWNLOAD_URL=https://download.mendix.com/runtimes/

RUN cd /opt && \
    apk add curl && \
    curl -sL "${DOWNLOAD_URL}mendix-${MX_VERSION}.tar.gz" | tar xz

FROM adoptopenjdk/openjdk8:latest

RUN mkdir -p /opt/mendix/app/data/database /opt/mendix/app/data/files /opt/mendix/app/data/model-upload /opt/mendix/app/data/tmp && \
    mkdir -p /opt/mendix/app/.java && \
    chmod g+rw /etc/passwd && \
    chgrp -R 0 /opt/mendix/app && \
    chmod -R g=u /opt/mendix/app

ARG MX_VERSION

COPY --from=builder /opt/${MX_VERSION} /opt/mendix/
COPY *.sh /opt/mendix/app/

RUN chown -R root:root /opt/mendix/runtime && \
    chmod u+x /opt/mendix/app/*.sh && \
    chgrp -R 0 /opt/mendix/app && \
    chmod -R g=u /opt/mendix/app
