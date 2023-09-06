setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "Unsupported libraries fail bootstrap sequence" {

    run ! source bootstrap.sh unsupported-foo-library
    assert_failure 1
    assert_output --partial "Unsupported library: 'unsupported-foo-library'"
}

@test "Default bootstrap sequence runs successfully" {

    run bash -c "CICD_TOOLS_DEBUG=1 source bootstrap.sh"
    assert_success
    assert_output --partial "loading common"
    assert_output --partial "loading container engine"
}

@test "loading all work successfully" {

    run bash -c "CICD_TOOLS_DEBUG=1 source bootstrap.sh all"
    assert_success
    assert_output --partial "loading common"
    assert_output --partial "loading container engine"
}

@test "loading container helper functions work successfully" {

    run ! container_engine_cmd
    assert_failure 127
    CICD_TOOLS_DEBUG=1
    source bootstrap.sh container_engine
    assert_success
    assert_output --partial "loading container engine"
    source bootstrap.sh container_engine
    container_engine_cmd
    assert_success
}

@test "Loading multiple bootstraps don't reload multiple times" {

    assert [ -z "$CICD_TOOLS_COMMON_LOADED" ]
    source bootstrap.sh
    assert [ "$CICD_TOOLS_COMMON_LOADED" -eq 0 ]
    run bash -c "source bootstrap.sh"
    refute_output --partial "loading common"
    run bash -c "source bootstrap.sh all"
    refute_output --partial "loading common"
    run bash -c "source bootstrap.sh container_engine"
    refute_output --partial "loading container engine"
}
