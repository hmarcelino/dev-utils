#!/bin/bash

echo "Stopping {{APP_NAME}} application"

installerDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Add your own shutdown process here
# What cames next is just a sample
pkill -f 'java.*{{BUILD.File}}'
