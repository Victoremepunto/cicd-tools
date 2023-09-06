# CI/CD Tools

## Description
Utilities used to run smoke tests in an ephemeral environment within a CI/CD pipeline

## Getting Started
Grab the [Jenkinsfile template](templates/Jenkinsfile) and cater it to your specific needs. This file should reside in your git repositories root directory. That Jenkinsfile will 
download the necessary files from this repository. It does not have a unit test file so that will need to be made in your repository. You can find a 
unit test template file [here](templates/unit_test_example.sh).

## Scripts

| Script                  | Description |  
| ----------------------- | ----------- | 
| bootstrap.sh            | Clone bonfire into workspace, setup python venv, modify PATH, login to container registries, login to Kube/OCP,  and set envvars used by following scripts. |
| build.sh                | Using docker (rhel7) or podman (else) build, tag, and push an image to Quay and Red Hat registries. If its a GitHub or GitLab PR/MR triggered script execution, tag image with `pr-123-SHA` and `pr-123-testing`, else use a short SHA for the target repo HEAD. |
| deploy_ephemeral_db.sh  | Deploy using `bonfire process` and `<oc_wrapper> apply`, removing dependencies and setting up database envvars. |
| deploy_ephemeral_env.sh | Deploy using `bonfire deploy` into ephemeral, specifying app, component, and relevant image tag args.  Passes `EXTRA_DEPLOY_ARGS` which can be set by the caller via pr_checks.sh.
| cji_smoke_test.sh       | Run iqe-tests container for the relevant app plugin using `bonfire deploy-iqe-cji`. Waits for tests to complete, and fetches artifacts using minio.
| post_test_results.sh    | Using artifacts fetched from `cji_smoke_test.sh`, add a GitHub status or GitLab comment linking to the relevant test results in Ibutsu.
| smoke_test.sh           | **DEPRECATED**, use [cji_smoke_test.sh](cji_smoke_test.sh) |
| iqe_pod                 | **DEPRECATED**, use [cji_smoke_test.sh](cji_smoke_test.sh) |

## Bash script helper scripts usage

The collection of helper scripts are expected to be loaded using the provided [src/bootstrap.sh](bootstrap) script.

Currently there is 1 collection available:

- Container helper scripts: provides wrapper functions for invoking container engine agnostic commands

To use any of the provided libraries, one can simply either source the [src/bootstrap.sh](bootstrap) script directly

```
source  bla bla bla
```

or use the collection it needs to load independently as a parameter:

```
source bla bla bla collection 1
```

The bootstrap script will download the selected version of the CICD scripts (or `latest` if none specified) into the directory defined by
the `CICD_TOOLS_WORKDIR` variable (defaults to `.cicd_tools` in the current directory). 

**Please note** that the directory defined by the `CICD_TOOLS_WORKDIR` will be deleted !
You can disable recreation feature by setting the `CICD_TOOLS_SKIP_RECREATE` variable (this is [what the tests do](test/test_helper/common-setup.bash))


## Template Scripts
| Script                  | Description |  
| ----------------------- | ----------- | 
| example/Jenkinsfile                       |  |
| example/pr_check_template.sh              |  |
| example/unit_test_example.sh              |  |
| example/unit_test_example_ephemeral_db.sh |  |

## Contributing

Suggested method for testing changes to these scripts:
- Modify `bootstrap.sh` to `git clone` your fork and branch of bonfire.
- Open a PR in a repo using bonfire pr_checks and the relevant scripts, modifying `pr_check` script to clone your fork and branch of bonfire.
- Observe modified scripts running in the relevant CI/CD pipeline.
# 
