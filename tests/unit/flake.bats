#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
}

@test "flake exports the default package" {
    run nix --extra-experimental-features 'nix-command flakes' eval \
        .#packages.aarch64-darwin --apply builtins.attrNames
    assert_success
    assert_output --partial '"default"'
}
