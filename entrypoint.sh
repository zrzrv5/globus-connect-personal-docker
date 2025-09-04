#!/bin/bash

if [ "$1" = 'start' ]; then
    echo "Starting Globus Connect..."
    exec globusconnectpersonal -start -dir ${GCP_CONFIG_PATH} -restrict-paths $GCP_RESTRICT_PATHS -shared-paths $GCP_SHARED_PATHS
elif [ "$1" = 'debug' ]; then
    echo "Starting Globus Connect with verbose output..."
    exec globusconnectpersonal -debug -dir ${GCP_CONFIG_PATH} -restrict-paths $GCP_RESTRICT_PATHS -shared-paths $GCP_SHARED_PATHS
else
    # Execute any other commands (e.g. bash)
    echo "Launching $@ ..."
    exec $@
fi