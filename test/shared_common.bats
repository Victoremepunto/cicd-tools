setup() {
    load "test_helper/common-setup"
    _common_setup
}

@test "Sets expected loaded flags" {

    assert [ -z "$CICD_TOOLS_COMMON_LOADED" ]
    assert [ -z "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" ]

    source "src/shared/all.sh"

    assert [ "$CICD_TOOLS_COMMON_LOADED" -eq 0 ]
    assert [ "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" -eq 0 ]
    assert [ -n "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" ]
}
