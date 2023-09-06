#!/usr/bin/env bash

load_cicd_helper_functions() {

    local LIBRARY_TO_LOAD=${1:-all}
    local CICD_TOOLS_REPO_BRANCH='add-container-engine-helper-tools'
    local CICD_TOOLS_REPO_ORG=Victoremepunto
    local CICD_TOOLS_URL="https://raw.githubusercontent.com/${CICD_TOOLS_REPO_ORG}/cicd-tools/${CICD_TOOLS_REPO_BRANCH}/src/bootstrap.sh"
    set -e
    source <(curl -sSL "$CICD_TOOLS_URL") "$LIBRARY_TO_LOAD"
    set +e
}

# Mock functions
podman() {
    echo "Podman version 99"
}

docker() {
    echo "Docker version 99"
}

PREFER_CONTAINER_ENGINE='docker'

load_cicd_helper_functions

EXPECTED_OUTPUT=$(container_engine_cmd --version)

# Assert there's an actual output
if ! [ "Docker version 99" == "$EXPECTED_OUTPUT" ]; then
    echo "container preference not working!"
    exit 1
fi

unset PREFER_CONTAINER_ENGINE
load_cicd_helper_functions

# Assert output doesn't change 
if ! [ "$(container_engine_cmd --version)" == "$EXPECTED_OUTPUT" ]; then
    echo "Container command not preserved between runs!"
    exit 1
fi
