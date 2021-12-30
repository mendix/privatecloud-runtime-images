#!/bin/bash

EXITCODE=0

# Intercept SIGTERM to perform a clean shutdown of the runtime
function shutdown_runtime()
{
    PASSWORD=`echo -n $M2EE_ADMIN_PASS | base64`

    echo "Shutting down Mendix Runtime"
    RESPONSE=$(curl \
    -d '{"action":"shutdown"}' \
    -H "Content-Type: application/json" \
    -H "X-M2EE-Authentication: $PASSWORD" \
    -H "Connection: close" \
    -f -s \
    http://127.0.0.1:$M2EE_ADMIN_PORT)

    CODE=$?
    if [[ "$CODE" != "0" || ! $RESPONSE =~ '"result":0' ]]; then
        echo "Failed to perform a clean shutdown (response $RESPONSE, error $CODE), exiting"
        kill $MXRUNTIME_PID
        EXITCODE=1
    fi
}
trap shutdown_runtime SIGINT SIGTERM

MX_INSTALL_PATH=/opt/mendix \
java -Duser.home=$HOME -javaagent:/opt/mendix/mxagent/mx-agent.jar=config=/opt/mendix/mxagent/MyAgentConfig.json,instrumentation_config=/opt/mendix/mxagent/DefaultInstrumentationConfig.json -jar /opt/mendix/runtime/launcher/runtimelauncher.jar /opt/mendix/app &
MXRUNTIME_PID=$!

wait $MXRUNTIME_PID
trap - SIGINT SIGTERM
wait $MXRUNTIME_PID

exit $EXITCODE
