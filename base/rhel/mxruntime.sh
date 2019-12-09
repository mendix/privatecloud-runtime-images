#!/bin/bash

# Intercept SIGTERM to allow the sidecar to shut down the runtime gracefully
function shutdown_runtime()
{
    PASSWORD=`echo -n $M2EE_ADMIN_PASS | base64`

    echo "Shutting down Mendix Runtime"
    curl \
    -d '{"action":"shutdown"}' \
    -H "Content-Type: application/json" \
    -H "X-M2EE-Authentication: $PASSWORD" \
    -H "Connection: close" \
    -f -s \
    http://127.0.0.1:$M2EE_ADMIN_PORT

    res=$?
    if test "$res" != "0"; then
        echo "Failed to perform a clean shutdown (error $res), exiting"
        exit 1
    fi
    exit 0
}
trap shutdown_runtime SIGINT SIGTERM

MX_INSTALL_PATH=/opt/mendix \
java -jar /opt/mendix/runtime/launcher/runtimelauncher.jar /opt/mendix/app
