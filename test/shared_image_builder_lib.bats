
setup() {
    load "test_helper/common-setup"
    _common_setup
}

@test "Load directly results in error" {

    run ! source "src/shared/image_builder_lib.sh"
    assert_failure
    assert_output --partial "load through main.sh"
}

@test "Does not fail sourcing the library" {

    run source main.sh image_builder
    assert_success
}

@test "Sets expected loaded flags" {

    assert [ -z "$CICD_TOOLS_COMMON_LOADED" ]
    assert [ -z "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" ]
    assert [ -z "$CICD_TOOLS_IMAGE_BUILDER_LOADED" ]

    source main.sh image_builder

    assert [ -n "$CICD_TOOLS_COMMON_LOADED" ]
    assert [ -n "$CICD_TOOLS_CONTAINER_ENGINE_LOADED" ]
    assert [ -n "$CICD_TOOLS_IMAGE_BUILDER_LOADED" ]
}

@test "Image tag outside of a change request context" {

    # git mock
    git() {
        echo "1abcdef"
    }

    source main.sh image_builder
    run cicd_tools::image_builder::get_image_tag
    assert_success
    assert_output '1abcdef'
}

@test "Image tags in a Pull Request context" {

    # git mock
    git() {
        echo "1abcdef"
    }

    ghprbPullId=123
    source main.sh image_builder

    run cicd_tools::image_builder::get_image_tag

    assert_success
    assert_output 'pr-123-1abcdef'
}

@test "Image tags in a Merge Request context" {

    # git mock
    git() {
        echo "1abcdef"
    }

    gitlabMergeRequestId=4321

    source main.sh image_builder

    run cicd_tools::image_builder::get_image_tag

    assert_success
    assert_output 'pr-4321-1abcdef'
}


@test "Image build works as expected with default values" {

    # podman mock
    podman() {
        echo "$@"
    }

    # git mock
    git() {
        echo "1abcdef"
    }

    EXPECTED_CONTAINERFILE_NAME='Dockerfile'

    source main.sh image_builder

    IMAGE_NAME='quay.io/foo/bar'
    touch "${EXPECTED_CONTAINERFILE_NAME}"

    run cicd_tools::image_builder::build

    rm "${EXPECTED_CONTAINERFILE_NAME}"

    assert_success
    assert_output --regexp "^build"
    assert_output --partial "-f Dockerfile"
    assert_output --partial "-t quay.io/foo/bar:1abcdef"
    assert_output --regexp "\.$"
}

@test "Image build works as expected with all custom values set" {

    # podman mock
    podman() {
        echo "$@"
    }

    # git mock
    git() {
        echo "1abcdef"
    }

    source main.sh image_builder

    IMAGE_NAME='quay.io/my-awesome-org/my-awesome-app'
    CICD_TOOLS_IMAGE_BUILDER_LABELS=("LABEL1=FOO" "LABEL2=bar")
    CICD_TOOLS_IMAGE_BUILDER_ADDITIONAL_TAGS=("test1" "additional-label-2" "security")
    CICD_TOOLS_IMAGE_BUILDER_BUILD_ARGS=("BUILD_ARG1=foobar" "BUILD_ARG2=bananas")
    CICD_TOOLS_IMAGE_BUILDER_BUILD_CONTEXT='another/context'
    CICD_TOOLS_IMAGE_BUILDER_CONTAINER_FILE='test/data/Containerfile.test'

    run cicd_tools::image_builder::build

    assert_success
    assert_output --regexp "^build.*"
    assert_output --regexp "another/context$"
    assert_output --partial "-f test/data/Containerfile.test"
    assert_output --regexp "-t quay.io/my-awesome-org/my-awesome-app:[0-9a-f]{7}"
    assert_output --partial "--label LABEL1=FOO"
    assert_output --partial "--label LABEL2=bar"
    assert_output --partial "-t quay.io/my-awesome-org/my-awesome-app:additional-label-2"
    assert_output --partial "-t quay.io/my-awesome-org/my-awesome-app:security"
    assert_output --partial "-t quay.io/my-awesome-org/my-awesome-app:test1"
    assert_output --partial "--build-arg BUILD_ARG1=foobar"
    assert_output --partial "--build-arg BUILD_ARG2=bananas"
}

@test "Image builds gets expiry label in change request context" {

    # podman mock
    podman() {
        echo "$@"
    }

    # git mock
    git() {
        echo "1abcdef"
    }

    source main.sh image_builder

    ghprbPullId="123"
    IMAGE_NAME="someimage"
    CONTAINER_FILE='test/data/Containerfile.test'

    run cicd_tools::image_builder::build

    assert_success
    assert_output --partial "-t someimage:pr-123-1abcdef"
    assert_output --partial "--label quay.expires-after=3d"
}

@test "Image build failures are caught" {

    # podman mock
    podman() {
        echo "something went really wrong" >&2
        return 1
    }

    # git mock
    git() {
        echo "1abcdef"
    }

    source main.sh image_builder

    IMAGE_NAME="someimage"
    CONTAINER_FILE='test/data/Containerfile.test'

    run cicd_tools::image_builder::build

    assert_failure
    assert_output --partial "went really wrong"
    assert_output --partial "Error building image"

}

@test "Image builder tries to login to registries" {

    # podman mock
    podman() {
        echo "$@"
    }

    CICD_TOOLS_IMAGE_BUILDER_QUAY_USER="username1"
    CICD_TOOLS_IMAGE_BUILDER_QUAY_PASSWORD="secr3t"

    run source main.sh image_builder

    assert_success
    assert_output --regexp "^login.*quay.io"
    assert_output --partial "-u=username1"

    CICD_TOOLS_IMAGE_BUILDER_REDHAT_USER="username2"
    CICD_TOOLS_IMAGE_BUILDER_REDHAT_PASSWORD="secr3t"

    run source main.sh image_builder
    assert_success
    assert_output --regexp "^login.*registry.redhat.io"
    assert_output --partial "-u=username2"
}

@test "Image builder logs failure on logging in to Quay.io" {

    # podman mock
    podman() {
        return 1
    }

    CICD_TOOLS_IMAGE_BUILDER_QUAY_USER="wrong-user"
    CICD_TOOLS_IMAGE_BUILDER_QUAY_PASSWORD="secr3t"

    run ! source main.sh image_builder

    assert_failure
    assert_output --partial "Image builder setup failed!"
    assert_output --partial "Error logging in to Quay.io"
}

@test "Image builder logs failure on logging in to Red Hat Registry" {

    # podman mock
    podman() {
        return 1
    }

    CICD_TOOLS_IMAGE_BUILDER_REDHAT_USER="wrong-user"
    CICD_TOOLS_IMAGE_BUILDER_REDHAT_PASSWORD="wrong-password"

    run ! source main.sh image_builder

    assert_failure
    assert_output --partial "Image builder setup failed!"
    assert_output --partial "Error logging in to Red Hat Registry"
}


@test "Get all image tags" {

    # git mock
    git() {
        echo "1abcdef"
    }

    source main.sh image_builder

    IMAGE_NAME="someimage"
    ADDITIONAL_TAGS=("foo" "bar" "baz")

    run cicd_tools::image_builder::get_image_tag

    assert_success
    assert_output "1abcdef"


    run cicd_tools::image_builder::get_additional_tags
    assert_output "foo bar baz"
}

@test "tag all images" {

    # git mock
    git() {
        echo "source"
    }
    # podman mock
    podman() {
        echo "$@"
    }

    source main.sh image_builder

    IMAGE_NAME="someimage"
    ADDITIONAL_TAGS=("target1" "target2" "target3")

    run cicd_tools::image_builder::tag

    refute_output --partial "tag someimage:source someimage:source"
    assert_output --partial "tag someimage:source someimage:target1"
    assert_output --partial "tag someimage:source someimage:target2"
    assert_output --partial "tag someimage:source someimage:target3"
}

@test "tag error is caught" {

    # git mock
    git() {
        echo "source"
    }
    # podman mock
    podman() {
      echo "$@"
      return 1
    }

    source main.sh image_builder

    IMAGE_NAME="someimage"
    ADDITIONAL_TAGS=("target1")

    run ! cicd_tools::image_builder::tag

    assert_failure
    assert_output --partial "tag someimage:source someimage:target1"
    assert_output --regexp "Error tagging.*someimage:source.*someimage:target1"
}

@test "push all images" {

    # git mock
    git() {
        echo "abcdef1"
    }
    # podman mock
    podman() {
        echo "$@"
    }

    source main.sh image_builder

    IMAGE_NAME="someimage"
    ADDITIONAL_TAGS=("tag1" "tag2")

    run cicd_tools::image_builder::push

    assert_output --partial "push someimage:abcdef1"
    assert_output --partial "push someimage:tag1"
    assert_output --partial "push someimage:tag2"
}

@test "push only one image on change-request-context" {

    # git mock
    git() {
        echo "abcdef1"
    }
    # podman mock
    podman() {
        echo "$@"
    }

    source main.sh image_builder

    IMAGE_NAME="someimage"
    ghprbPullId="123"
    ADDITIONAL_TAGS=("tag1" "tag2")

    run cicd_tools::image_builder::push

    assert_output --partial "push someimage:pr-123-abcdef1"
    refute_output --partial "push someimage:tag1"
    refute_output --partial "push someimage:tag2"
}

@test "push error is caught" {

    # git mock
    git() {
      echo "source"
    }
    # podman mock
    podman() {
      echo "$@"
      return 1
    }

    source main.sh image_builder

    IMAGE_NAME="someimage"
    ADDITIONAL_TAGS=("target1")

    run ! cicd_tools::image_builder::push

    assert_failure
    assert_output --partial "push someimage:source"
    assert_output --partial "Error pushing image"
}

@test "build deploy does not push if not on change request context" {

    # git mock
    git() {
      echo "source"
    }
    # podman mock
    podman() {
      echo "$@"
    }

    source main.sh image_builder

    IMAGE_NAME="someimage"
    ADDITIONAL_TAGS=("target1")
    CONTAINER_FILE='test/data/Containerfile.test'

    run cicd_tools::image_builder::build_deploy

    assert_success
    assert_output --regexp "^build.*?-t someimage:source -t someimage:target1"
    refute_output --partial "push"
}

@test "build deploy pushes only default tag if on change request context" {

    # git mock
    git() {
      echo "source"
    }
    # podman mock
    podman() {
      echo "$@"
    }

    source main.sh image_builder

    ghprbPullId='123'
    IMAGE_NAME="someimage"
    ADDITIONAL_TAGS=("target1")
    CONTAINER_FILE='test/data/Containerfile.test'

    run cicd_tools::image_builder::build_deploy

    assert_success 
    assert_output --regexp "^build.*?-t someimage:pr-123-source"
    refute_output --regexp "^build.*?-t someimage:target1"
    assert_output --regexp "^build.*?--label quay.expires-after"
    assert_output --partial "push someimage:pr-123-source"
    refute_output --partial "push someimage:target1"
}
