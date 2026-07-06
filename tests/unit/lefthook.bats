#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "lefthook.yml has markdownlint remote" {
    run grep 'nix-lefthook-markdownlint' lefthook.yml
    assert_success
}

@test "lefthook.yml has taplo remote" {
    run grep 'nix-lefthook-taplo' lefthook.yml
    assert_success
}

@test "file_size_limits.yml has toml extension" {
    run grep 'toml:' config/lefthook/file_size_limits.yml
    assert_success
}
