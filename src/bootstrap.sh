#!/usr/bin/env bash

CICD_TOOLS_REPO_ORG="${CICD_TOOLS_REPO_ORG:-RedHatInsights}"
CICD_TOOLS_REPO_BRANCH="${CICD_TOOLS_REPO_BRANCH:-main}"
CICD_TOOLS_WORKDIR="${CICD_TOOLS_WORKDIR:-${PWD}/.cicd_tools}"
CICD_TOOLS_COMMON_LOADED=${CICD_TOOLS_COMMON_LOADED:-1}
CICD_TOOLS_CONTAINER_ENGINE_LOADED=${CICD_TOOLS_CONTAINER_ENGINE_LOADED:-1}
CICD_TOOLS_SKIP_CLONE_REPO=${CICD_TOOLS_SKIP_CLONE_REPO}

LIB_TO_LOAD=${1:-all}

setup() {
    if [ -z "$CICD_TOOLS_SKIP_CLONE_REPO" ]; then
        _clone_cicd_tools_repo
    fi
}

_clone_cicd_tools_repo() {

    if [ -d "${CICD_TOOLS_WORKDIR}" ]; then
        echo "Removing existing CICD tools workdir: '${CICD_TOOLS_WORKDIR}'"
        rm -rf "${CICD_TOOLS_WORKDIR}"
    fi

    git clone -q \
        --branch "$CICD_TOOLS_REPO_BRANCH" \
        "https://github.com/${CICD_TOOLS_REPO_ORG}/cicd-tools.git" "$CICD_TOOLS_WORKDIR"
}

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
    source "${CICD_TOOLS_WORKDIR}/src/shared/common.sh"
    source "${CICD_TOOLS_WORKDIR}/src/shared/container-engine-lib.sh"
}

set -e
setup
load_library "$LIB_TO_LOAD"
set +e
