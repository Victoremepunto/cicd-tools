#!/usr/bin/env bash

CICD_TOOLS_COMMON_LOADED=1
CICD_TOOLS_CONTAINER_ENGINE_LOADED=1

if [ -z "$CICD_TOOLS_SCRIPTS_DIR" ]; then
    echo "scripts directory not defined, please load through main.sh script"
    return 1
fi

source "${CICD_TOOLS_SCRIPTS_DIR}/shared/common.sh"
source "${CICD_TOOLS_SCRIPTS_DIR}/shared/container-engine-lib.sh"
