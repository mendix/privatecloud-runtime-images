ARG MX_VERSION
FROM mendix/runtime-base:${MX_VERSION}-rhel

COPY . /opt/mendix/app
