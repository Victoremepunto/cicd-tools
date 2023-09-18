#!/usr/bin/env bash

COVERAGE_DIRECTORY="$PWD/coverage"
BATS_CMD='bats'
TESTS_DIRECTORY='test'
IGNORE_TAGS='!no-kcov'

if [ -d "$COVERAGE_DIRECTORY" ]; then
  rm -rf "$COVERAGE_DIRECTORY"
fi

kcov --include-pattern cicd-tools/src \
    "$COVERAGE_DIRECTORY" \
    "$BATS_CMD" \
    --filter-tags "$IGNORE_TAGS" \
    "$TESTS_DIRECTORY"
