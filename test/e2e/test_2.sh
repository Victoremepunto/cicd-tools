#!/usr/bin/env bash

load_common_helper_cicd_tools() {

    local PREFER_CONTAINER_ENGINE='docker'
    local LIBRARY_TO_LOAD=${1:-all}
    local MAIN_SCRIPT='./src/main.sh'
    source "$MAIN_SCRIPT" "$LIBRARY_TO_LOAD"
    container_engine_cmd --version
}

load_common_helper_cicd_tools

container_engine_cmd --version
