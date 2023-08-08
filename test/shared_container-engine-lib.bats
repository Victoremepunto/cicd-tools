
setup() {
    load "test_helper/common-setup"
    _common_setup
}

@test "Sets expected loaded flags" {

    assert [ -z "$CICD_TOOLS_COMMON_LOADED" ]
    assert [ -z "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" ]

    source "src/shared/container-engine-lib.sh"

    assert [ "$CICD_TOOLS_COMMON_LOADED" -eq 0 ]
    assert [ "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" -eq 0 ]
}

@test "Loading common message is displayed" {

    run bash -c "source 'src/shared/container-engine-lib.sh'"
    assert_success
    assert_output --partial "loading container engine"
}

@test "container engine cmd is set once" {

    assert [ -z "${CONTAINER_ENGINE_CMD+x}" ]
    source "src/shared/container-engine-lib.sh"
    refute [ -z "${CONTAINER_ENGINE_CMD+x}" ]
    assert [ -z "${CONTAINER_ENGINE_CMD}" ]
    source "src/shared/container-engine-lib.sh"
    assert [ -z "${CONTAINER_ENGINE_CMD}" ]
    assert container_engine_cmd version
    assert [ -n "${CONTAINER_ENGINE_CMD}" ]
    EXPECTED_VALUE="$CONTAINER_ENGINE_CMD"
    source "src/shared/container-engine-lib.sh"
    assert [ "$CONTAINER_ENGINE_CMD" = "$EXPECTED_VALUE" ]
}

@test "get container engine cmd" {

    assert [ -z "${CONTAINER_ENGINE_CMD+x}" ]
    source "src/shared/container-engine-lib.sh"
    refute [ -z "${CONTAINER_ENGINE_CMD+x}" ]
    assert [ -z "${CONTAINER_ENGINE_CMD}" ]
    source "src/shared/container-engine-lib.sh"
    assert [ -z "${CONTAINER_ENGINE_CMD}" ]
    container_engine_cmd version
    assert [ -n "${CONTAINER_ENGINE_CMD}" ]
}

@test "test container engine available" {

    source "src/shared/container-engine-lib.sh"

    refute container_engine_available "foo"
    refute container_engine_available "cat"

    OLDPATH="$PATH"
    PATH=':'
    refute container_engine_available "podman"
    refute container_engine_available "docker"
    PATH="$OLDPATH"
}

@test "supported container_engine" {

    source "src/shared/container-engine-lib.sh"
    assert _supported_container_engine "podman"
    assert _supported_container_engine "docker"
    refute _supported_container_engine "fooobar"
    refute _supported_container_engine ""
}

@test "testing docker" {

    docker() {
        echo 'docker is mocked'
    }

    source "src/shared/container-engine-lib.sh"
    assert container_engine_available "docker"

}

@test "testing podman" {

    podman() {
        echo 'podman is mocked'
    }

    source "src/shared/container-engine-lib.sh"
    assert container_engine_available "podman"
}
