#!/bin/bash

# Intercept SIGTERM to allow the sidecar to shut down the runtime gracefully
trap 'echo "Shutdown signal received"' TERM

MX_INSTALL_PATH=/opt/mendix \
java -jar /opt/mendix/runtime/launcher/runtimelauncher.jar /opt/mendix/app
