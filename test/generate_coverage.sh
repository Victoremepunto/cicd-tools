#!/usr/bin/env bash

COVERAGE_DIRECTORY="$PWD/coverage"
BATS_CMD='bats'
TESTS_DIRECTORY='test'

kcov --include-pattern cicd-tools/src \
    "$COVERAGE_DIRECTORY" \
    "$BATS_CMD" \
    "$TESTS_DIRECTORY"
