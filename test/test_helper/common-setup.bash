#!/usr/bin/env bash

_common_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    bats_require_minimum_version 1.5.0
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$PROJECT_ROOT/src:$PATH"

    # Required for testing current checked out project
    export CICD_TOOLS_SKIP_RECREATE='true'
    export CICD_TOOLS_WORKDIR="$PROJECT_ROOT"
}

