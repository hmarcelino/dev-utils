#!/bin/bash

echo "Starting {{APP_NAME}} application"

installerDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Add your own shutdown process here
# What cames next is just a sample
nohup java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
    {{EXTRA_STARTUP_ARGS}}
    -jar $installerDir/lib/{{BUILD_FILE}} > $installerDir/nohup.log 2>&1 &
