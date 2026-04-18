#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"

    cat > "$TMP/.editorconfig" <<'EOF'
root = true

[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
charset = utf-8
indent_style = space
indent_size = 2
EOF
}

@test "no args exits 0" {
    run lefthook-editorconfig-checker
    assert_success
}

@test "non-existent file is skipped" {
    run lefthook-editorconfig-checker /nonexistent/file.txt
    assert_success
}

@test "conforming file passes" {
    printf 'name: test\nvalue: 42\n' > "$TMP/good.txt"
    run lefthook-editorconfig-checker "$TMP/good.txt"
    assert_success
}

@test "file with wrong indentation fails" {
    printf 'root:\n\tindented with tab\n' > "$TMP/tabs.txt"
    run lefthook-editorconfig-checker "$TMP/tabs.txt"
    assert_failure
}

@test "file with trailing whitespace fails" {
    printf 'trailing   \n' > "$TMP/trailing.txt"
    run lefthook-editorconfig-checker "$TMP/trailing.txt"
    assert_failure
}

@test "file missing final newline fails" {
    printf 'no newline' > "$TMP/nonewline.txt"
    run lefthook-editorconfig-checker "$TMP/nonewline.txt"
    assert_failure
}

@test "multiple files: one bad causes failure" {
    printf 'good\n' > "$TMP/good.txt"
    printf 'bad\t \n' > "$TMP/bad.txt"
    run lefthook-editorconfig-checker "$TMP/good.txt" "$TMP/bad.txt"
    assert_failure
}
