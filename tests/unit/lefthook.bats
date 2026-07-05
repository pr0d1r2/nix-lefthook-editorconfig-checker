#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "lefthook.yml has markdownlint remote" {
    run grep 'nix-lefthook-markdownlint' lefthook.yml
    assert_success
}
