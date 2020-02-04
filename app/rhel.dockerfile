ARG MX_VERSION
FROM mendix/runtime-base:${MX_VERSION}-rhel

COPY . /opt/mendix/app

# Container configuration
USER 1001
ENV HOME /opt/mendix/app

EXPOSE 8080

ENTRYPOINT ["/opt/mendix/app/entrypoint.sh"]

CMD ["/opt/mendix/app/mxruntime.sh"]
