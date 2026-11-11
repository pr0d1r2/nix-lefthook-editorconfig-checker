#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
}

@test "flake exports the default package on every supported system" {
    run nix --extra-experimental-features 'nix-command flakes' eval --json \
        .#packages --apply 'p: builtins.all (s: builtins.hasAttr s p && builtins.getAttr s p ? default) [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ]'
    assert_success
    assert_line 'true'
}

@test "default package provides the lefthook-editorconfig-checker binary" {
    run nix --extra-experimental-features 'nix-command flakes' eval --raw \
        .#packages.x86_64-linux.default.meta.mainProgram
    assert_success
    assert_line 'lefthook-editorconfig-checker'
}
