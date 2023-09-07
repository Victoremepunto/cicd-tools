#!/usr/bin/env bash

# Mock functions
podman() {
    echo "Podman version 99"
}

docker() {
    echo "Docker version 99"
}

load_cicd_helper_functions() {

    local PREFER_CONTAINER_ENGINE='docker'
    local LIBRARY_TO_LOAD=${1:-all}
    local CICD_TOOLS_REPO_BRANCH='add-container-engine-helper-tools'
    local CICD_TOOLS_REPO_ORG=Victoremepunto
    
    if [ "$CI" = "true" ]; then
        if [ "$GITHUB_ACTIONS" = "true" ]; then
            CICD_TOOLS_REPO_ORG="$GITHUB_REPOSITORY_OWNER"
            CICD_TOOLS_REPO_BRANCH="$GITHUB_HEAD_REF"
        fi
    fi

    local CICD_TOOLS_URL="https://raw.githubusercontent.com/${CICD_TOOLS_REPO_ORG}/cicd-tools/${CICD_TOOLS_REPO_BRANCH}/src/bootstrap.sh"

    source <(curl -sSL "$CICD_TOOLS_URL") "$LIBRARY_TO_LOAD"
}
load_cicd_helper_functions

container_engine_cmd

EXPECTED_OUTPUT=$(container_engine_cmd --version)

# Assert there's an actual output
if ! [ "Docker version 99" == "$EXPECTED_OUTPUT" ]; then
    echo "container preference not working!"
    exit 1
fi

load_cicd_helper_functions

# Assert output doesn't change 
if ! [ "$(container_engine_cmd --version)" == "$EXPECTED_OUTPUT" ]; then
    echo "Container command not preserved between runs!"
    exit 1
fi
