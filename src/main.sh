#!/usr/bin/env bash

CICD_TOOLS_COMMON_LOADED=${CICD_TOOLS_COMMON_LOADED:-1}
CICD_TOOLS_CONTAINER_ENGINE_LOADED=${CICD_TOOLS_CONTAINER_ENGINE_LOADED:-1}
CICD_TOOLS_DEBUG="${CICD_TOOLS_DEBUG:-}"
CICD_TOOLS_SCRIPTS_DIR="${CICD_TOOLS_SCRIPTS_DIR:-${PWD}/src}"
LIB_TO_LOAD=${1:-all}

load_library() {

    case $LIB_TO_LOAD in

        all)
            _load_all
            ;;
        container_engine)
            _load_container_engine
            ;;
        *) echo "Unsupported library: '"$LIB_TO_LOAD"'"
            return 1

    esac
}

_load_all() {
    _load_container_engine
}

_load_container_engine() {
    source "${CICD_TOOLS_SCRIPTS_DIR}/shared/common.sh"
    source "${CICD_TOOLS_SCRIPTS_DIR}/shared/container-engine-lib.sh"
}

load_library "$LIB_TO_LOAD"
