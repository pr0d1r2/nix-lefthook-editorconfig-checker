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

@test "file_size_limits.yml has sh extension" {
    run grep 'sh:' config/lefthook/file_size_limits.yml
    assert_success
}

@test "lefthook.yml has local shfmt pre-commit override with 2-space indent" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' lefthook.yml | grep 'shfmt -d -i 2 -ci'"
    assert_success
}

@test "lefthook.yml has local shfmt pre-push override with 2-space indent" {
    run bash -c "sed -n '/^pre-push:/,\$p' lefthook.yml | grep 'shfmt -d -i 2 -ci'"
    assert_success
}
