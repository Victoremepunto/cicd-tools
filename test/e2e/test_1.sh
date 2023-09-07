#!/usr/bin/env bash

PREFER_CONTAINER_ENGINE='docker'
LIBRARY_TO_LOAD=${1:-all}
MAIN_SCRIPT='./src/main.sh'

source "$MAIN_SCRIPT" "$LIBRARY_TO_LOAD"

container_engine_cmd --version >/dev/null
EXPECTED_OUTPUT=$(container_engine_cmd --version)

unset PREFER_CONTAINER_ENGINE

source "$MAIN_SCRIPT" "$LIBRARY_TO_LOAD"
if ! [ "$EXPECTED_OUTPUT" = "$(container_engine_cmd --version)" ]; then
    echo "test failed"
    exit 1
fi
