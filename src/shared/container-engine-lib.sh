#!/usr/bin/env bash

# container engine helper functions to handle both podman and docker commands

CICD_TOOLS_COMMON_LOADED=${CICD_TOOLS_COMMON_LOADED:-1}

if [ "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" -eq 0 ]; then
    return 0
fi

if [ "$CICD_TOOLS_COMMON_LOADED" -ne 0 ]; then
    source "${CICD_TOOLS_WORKDIR}/src/shared/common.sh"
fi

echo "loading container engine"

CONTAINER_ENGINE_CMD=''

container_engine_cmd() {

    if [[ -z "$CONTAINER_ENGINE_CMD" ]]; then
        if ! _set_container_engine_cmd; then
            return 1
        fi
    fi

    if [[ "$CONTAINER_ENGINE_CMD" = "podman" ]]; then
        podman "$@"
    else
        docker "--config=${DOCKER_CONF}" "$@"
    fi
}

_set_container_engine_cmd() {

    if _configured_container_engine_available; then
        CONTAINER_ENGINE_CMD="$PREFER_CONTAINER_ENGINE"
    else
        if container_engine_available 'podman'; then
            CONTAINER_ENGINE_CMD='podman'
        elif container_engine_available 'docker'; then
            CONTAINER_ENGINE_CMD='docker'
        else
            echo "ERROR, no container engine found, please install either podman or docker first"
            return 1
        fi
    fi

    echo "Container engine selected: $CONTAINER_ENGINE_CMD"
}

_configured_container_engine_available() {

    local CONTAINER_ENGINE_AVAILABLE=1

    if [ -n "$PREFER_CONTAINER_ENGINE" ]; then
        if container_engine_available "$PREFER_CONTAINER_ENGINE"; then
            CONTAINER_ENGINE_AVAILABLE=0
        else
            echo "WARNING!: specified container engine '${PREFER_CONTAINER_ENGINE}' not present, finding alternative..."
        fi
    fi

    return "$CONTAINER_ENGINE_AVAILABLE"
}

_supported_container_engine() {

    local CONTAINER_ENGINE_TO_CHECK="$1"

    [[ ( "$CONTAINER_ENGINE_TO_CHECK" = 'docker' ) || \
       ( "$CONTAINER_ENGINE_TO_CHECK" = 'podman' ) ]]
}

container_engine_available() {

    local CONTAINER_ENGINE_TO_CHECK="$1"
    local CONTAINER_ENGINE_AVAILABLE=1

    if _supported_container_engine "$CONTAINER_ENGINE_TO_CHECK" &&\
        command_is_present "$CONTAINER_ENGINE_TO_CHECK"; then
        if [[ "$CONTAINER_ENGINE_TO_CHECK" != "docker" ]] || ! _docker_seems_emulated; then
            CONTAINER_ENGINE_AVAILABLE=0
        fi
    fi
    return "$CONTAINER_ENGINE_AVAILABLE"
}

_podman_version_under_4_5_0() {
    [ "$(echo -en "4.5.0\n$(_podman_version)" | sort -V | head -1)" != "4.5.0" ]
}

_docker_seems_emulated() {
    [[ "$(docker 2>/dev/null --version)" =~ podman\ +version ]]
}

CICD_TOOLS_CONTAINER_ENGINE_LOADED=0
