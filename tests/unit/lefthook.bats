#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    CONFIG="$REPO_ROOT/lefthook-remote.yml"
}

@test "lefthook-remote.yml runs editorconfig-checker on staged files in pre-commit" {
    run bash -c 'sed -n "/^pre-commit:/,/^pre-push:/p" "$1" | grep -c "lefthook-editorconfig-checker {staged_files}"' -- "$CONFIG"
    assert_success
    assert_output "1"
}

@test "lefthook-remote.yml runs editorconfig-checker on pushed files in pre-push" {
    run bash -c 'sed -n "/^pre-push:/,\$p" "$1" | grep -c "lefthook-editorconfig-checker {push_files}"' -- "$CONFIG"
    assert_success
    assert_output "1"
}

@test "file_size_limits.yml has toml extension" {
    run grep 'toml:' "$REPO_ROOT/config/lefthook/file_size_limits.yml"
    assert_success
}

@test "file_size_limits.yml has sh extension" {
    run grep 'sh:' "$REPO_ROOT/config/lefthook/file_size_limits.yml"
    assert_success
}
