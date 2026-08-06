#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "lefthook.yml runs markdownlint in both hooks" {
    run grep -c 'lefthook-markdownlint' lefthook.yml
    assert_success
    assert_output "4"
}

@test "lefthook.yml runs the repository guardrails" {
    run grep -E 'lefthook-(gitleaks|git-conflict-markers|git-no-local-paths|yamllint)' lefthook.yml
    assert_success
}

@test "file_size_limits.yml has toml extension" {
    run grep 'toml:' config/lefthook/file_size_limits.yml
    assert_success
}

@test "file_size_limits.yml has sh extension" {
    run grep 'sh:' config/lefthook/file_size_limits.yml
    assert_success
}

@test "lefthook commands use staged or pushed file arguments" {
    run grep -E '\{(staged|push)_files\}' lefthook.yml
    assert_success
}
