#!/usr/bin/env bash

CICD_TOOLS_COMMON_LOADED=1
CICD_TOOLS_CONTAINER_ENGINE_LOADED=1
CICD_TOOLS_WORKDIR=${CICD_TOOLS_WORKDIR:-$(pwd)}

source "${CICD_TOOLS_WORKDIR}/src/shared/common.sh"
source "${CICD_TOOLS_WORKDIR}/src/shared/container-engine-lib.sh"
