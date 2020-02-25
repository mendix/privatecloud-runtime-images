ARG MX_VERSION
FROM mendix/runtime-base:${MX_VERSION}-bionic

COPY . /opt/mendix/app
