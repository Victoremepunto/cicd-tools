
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

    podman() {
        echo 'podman version 1'
    }
    docker() {
        echo 'docker version 1'
    }
    assert container_engine_available "podman"
    assert container_engine_available "docker"
}

@test "supported container_engine" {

    skip 'no testing private functions'

    source "src/shared/container-engine-lib.sh"
    assert _supported_container_engine "podman"
    assert _supported_container_engine "docker"
    refute _supported_container_engine "fooobar"
    refute _supported_container_engine ""
}

@test "If docker is emulated doesn't qualifies as available" {

    docker() {
        echo 'podman version 1'
    }
    source "src/shared/container-engine-lib.sh"

    refute container_engine_available "docker"
}

@test "if forcing docker as container engine but is emulated, keeps looking and uses podman if found" {

    PREFER_CONTAINER_ENGINE="docker"

    docker() {
        podman
    }
    podman() {
        echo 'podman version 1'
    }
    source "src/shared/container-engine-lib.sh"
    run container_engine_cmd --version
    assert_output --regexp "WARNING.*docker.*not present"
    assert_output --partial "podman"
}

@test "if no container engine found, fails" {

    source "src/shared/container-engine-lib.sh"

    OLDPATH="$PATH"
    PATH=':'
    run ! container_engine_cmd --version
    PATH="$OLDPATH"
    assert_failure
    assert_output --partial "ERROR, no container engine found"
}

@test "if forcing podman but not found, uses docker if found and not emulated" {

    PREFER_CONTAINER_ENGINE="podman"

    docker() {
        echo 'docker version 1'
    }
    source "src/shared/container-engine-lib.sh"

    OLDPATH="$PATH"
    PATH=':'
    run container_engine_cmd --version
    PATH="$OLDPATH"
    assert_output --regexp "WARNING.*podman.*not present"
    assert_output --partial "docker version 1"
}

@test "if forcing podman but not found and docker is emulated it fails" {

    PREFER_CONTAINER_ENGINE="podman"

    docker() {
        echo 'podman version 1'
    }
    source "src/shared/container-engine-lib.sh"

    OLDPATH="$PATH"
    PATH=':'
    run container_engine_cmd --version
    PATH="$OLDPATH"
    assert [ $status -eq 1 ]
    assert_output --regexp "WARNING.*podman.*not present"
    assert_output --partial "no container engine found"
}

@test "Podman is used by default if no container engine preference defined" {

    podman() {
        echo 'podman version 1'
    }
    docker() {
        echo 'docker version 1'
    }
    source "src/shared/container-engine-lib.sh"

    run container_engine_cmd --version
    assert_output --partial "podman version 1"
}

@test "Docker can be set as preferred over podman if both are available" {

    PREFER_CONTAINER_ENGINE='docker'

    podman() {
        echo 'podman version 1'
    }
    docker() {
        echo 'docker version 1'
    }
    source "src/shared/container-engine-lib.sh"
    run container_engine_cmd --version
    assert_success
    assert_output --partial "docker version 1"
}

@test "top level preference" {

    podman() {
        echo 'podman version 1'
    }

    docker() {
        echo 'docker version 1'
    }

    export -f podman docker
    run bash -c "PREFER_CONTAINER_ENGINE='docker' && source src/bootstrap.sh && container_engine_cmd --version"
    assert_success
    assert_output --partial "docker version 1"
}
