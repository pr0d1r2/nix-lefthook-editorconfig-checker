#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
}

@test ".envrc watches flake.nix" {
    run grep 'watch_file flake.nix' .envrc
    assert_success
}

@test ".envrc watches flake.lock" {
    run grep 'watch_file flake.lock' .envrc
    assert_success
}

@test ".envrc watches dev.sh" {
    run grep 'watch_file dev.sh' .envrc
    assert_success
}

@test ".envrc watches lefthook-editorconfig-checker.sh" {
    run grep 'watch_file lefthook-editorconfig-checker.sh' .envrc
    assert_success
}

@test ".envrc uses flake" {
    run grep 'use flake' .envrc
    assert_success
}
