setup() {
    load "test_helper/common-setup"
    _common_setup
}

@test "Load directly results in error" {

    run ! source "src/shared/all.sh"
    assert_failure
    assert_output --partial "load through main.sh"
}

@test "Sets expected loaded flags" {

    assert [ -z "$CICD_TOOLS_COMMON_LOADED" ]
    assert [ -z "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" ]

    source main.sh all

    assert [ "$CICD_TOOLS_COMMON_LOADED" -eq 0 ]
    assert [ "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" -eq 0 ]
    assert [ -n "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" ]
}
