
setup() {
    load "test_helper/common-setup"
    _common_setup
}

@test "Sets expected loaded flags" {

    assert [ -z "$CICD_TOOLS_COMMON_LOADED" ]

    source "src/shared/common.sh"

    assert [ "$CICD_TOOLS_COMMON_LOADED" -eq 0 ]
}


@test "Loading common message is displayed" {

    run bash -c "source 'src/shared/common.sh'"
    assert_success
    assert_output "loading common"
}

@test "test command is present" {

    source "src/shared/common.sh"
    run ! command_is_present foo
    assert_failure

    run command_is_present 'cat'
    assert_success
}
