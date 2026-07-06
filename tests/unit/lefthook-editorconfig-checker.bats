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

@test "conforming file with spaces in name passes" {
    printf 'name: test\nvalue: 42\n' > "$TMP/my file.txt"
    run lefthook-editorconfig-checker "$TMP/my file.txt"
    assert_success
}

@test "violating file with spaces in name fails" {
    printf 'trailing   \n' > "$TMP/my file.txt"
    run lefthook-editorconfig-checker "$TMP/my file.txt"
    assert_failure
}

@test "non-existent file with spaces in name is skipped" {
    run lefthook-editorconfig-checker "$TMP/no such file.txt"
    assert_success
}

@test "binary file is skipped" {
    printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR' > "$TMP/image.png"
    run lefthook-editorconfig-checker "$TMP/image.png"
    assert_success
}

@test "binary file among conforming text files passes" {
    printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR' > "$TMP/image.png"
    printf 'name: test\nvalue: 42\n' > "$TMP/good.txt"
    run lefthook-editorconfig-checker "$TMP/image.png" "$TMP/good.txt"
    assert_success
}

@test "binary file among violating text files fails" {
    printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR' > "$TMP/image.png"
    printf 'bad\t \n' > "$TMP/bad.txt"
    run lefthook-editorconfig-checker "$TMP/image.png" "$TMP/bad.txt"
    assert_failure
}

@test "mixed existing and non-existing files where existing files all pass" {
    printf 'name: test\n' > "$TMP/good1.txt"
    printf 'value: 42\n' > "$TMP/good2.txt"
    run lefthook-editorconfig-checker "$TMP/good1.txt" /nonexistent/a.txt "$TMP/good2.txt" /nonexistent/b.txt
    assert_success
}
