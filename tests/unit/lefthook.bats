#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    CONFIG="$REPO_ROOT/lefthook.yml"
}

@test "lefthook.yml runs markdownlint in pre-commit" {
    run bash -c 'sed -n "/^pre-commit:/,/^pre-push:/p" "$1" | grep -c "lefthook-markdownlint {staged_files}"' -- "$CONFIG"
    assert_success
    assert_output "1"
}

@test "lefthook.yml runs markdownlint in pre-push" {
    run bash -c 'sed -n "/^pre-push:/,\$p" "$1" | grep -c "lefthook-markdownlint {push_files}"' -- "$CONFIG"
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

@test "lefthook.yml runs shfmt on staged files in pre-commit" {
    run bash -c 'sed -n "/^pre-commit:/,/^pre-push:/p" "$1" | grep -q "lefthook-shfmt {staged_files}"' -- "$CONFIG"
    assert_success
}

@test "lefthook.yml runs shfmt on pushed files in pre-push" {
    run bash -c 'sed -n "/^pre-push:/,\$p" "$1" | grep -q "lefthook-shfmt {push_files}"' -- "$CONFIG"
    assert_success
}
