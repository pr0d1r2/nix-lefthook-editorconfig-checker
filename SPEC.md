## §D — Description

nix-lefthook-editorconfig-checker is a Nix flake that packages a lefthook-compatible wrapper around editorconfig-checker. It filters non-existent files from lefthook's staged/pushed file arguments, runs editorconfig-checker on the remaining real files, and exits cleanly when no files need checking. The wrapper can be consumed as a lefthook remote (zero-config YAML import) or as a flake input added to a project's devShell. It targets Nix-based development workflows on Linux and macOS (arm64 and x86_64) where editorconfig compliance is enforced via git hooks.

## §V — Invariants

1. Calling `lefthook-editorconfig-checker` with no arguments exits 0.
2. Non-existent files in the argument list are silently skipped.
3. When all arguments resolve to non-existent files, exit code is 0.
4. Files conforming to `.editorconfig` rules pass (exit 0).
5. Files violating `.editorconfig` rules (wrong indent, trailing whitespace, missing final newline) cause a non-zero exit.
6. Multiple files where at least one violates rules cause a non-zero exit.
7. The flake builds on all four supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
8. `dev.sh` exports `BATS_LIB_PATH` from the `@BATS_LIB_PATH@` placeholder substituted at build time.
9. `dev.sh` runs `lefthook install` only when `$HOME` is set and `.git/hooks/pre-commit` is absent.
10. Every lefthook command has a timeout (default 30 seconds via `LEFTHOOK_EDITORCONFIG_CHECKER_TIMEOUT`).
11. Every lefthook check runs in both `pre-commit` and `pre-push`.
12. No embedded shell code exists in nix files; shell is read from external `.sh` files via `builtins.readFile`.
13. `.editorconfig` enforces: LF line endings, final newline, no trailing whitespace, UTF-8 charset, space indentation (size 2).
14. CI passes on both Linux (`ubuntu-latest`) and macOS (`macos-latest`).
15. Shell scripts are invoked with `bash script.sh`, never `./script.sh` (noexec volume compatibility).

## §I — Interfaces

### CLI

```
lefthook-editorconfig-checker [file ...]
```

Accepts zero or more file paths. Filters to existing files, runs `editorconfig-checker` on them. Exit 0 if no files remain or all pass; non-zero on any violation.

### Nix flake outputs

- `packages.<system>.default` — `writeShellApplication` wrapping `lefthook-editorconfig-checker.sh` with `editorconfig-checker` on PATH.
- `devShells.<system>.default` — development shell with the package, bats test runner, lefthook, and all linter tooling.
- `devShells.<system>.ci` — CI-oriented shell (via `nix-dev-shell-agentic`).

### Lefthook remote config (`lefthook-remote.yml`)

```yaml
pre-commit:
  commands:
    editorconfig-checker:
      run: timeout ${LEFTHOOK_EDITORCONFIG_CHECKER_TIMEOUT:-30} lefthook-editorconfig-checker {staged_files}

pre-push:
  commands:
    editorconfig-checker:
      run: timeout ${LEFTHOOK_EDITORCONFIG_CHECKER_TIMEOUT:-30} lefthook-editorconfig-checker {push_files}
```

### Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `LEFTHOOK_EDITORCONFIG_CHECKER_TIMEOUT` | `30` | Seconds before the check is killed |
| `BATS_LIB_PATH` | Set by dev shell | Path to bats support/assert libraries |

### Config files

| File | Format | Purpose |
|---|---|---|
| `.editorconfig` | INI-like | editorconfig rules applied to all files |
| `lefthook.yml` | YAML | Local lefthook hooks (16 remotes + 1 local command) |
| `lefthook-remote.yml` | YAML | Config consumed by other projects via lefthook remote |
| `.yamllint.yml` | YAML | yamllint configuration (truthy keys unchecked, line-length disabled) |
| `.markdownlint.yml` | YAML | markdownlint configuration (MD013/line-length disabled) |
| `config/lefthook/file_size_limits.yml` | YAML | Per-extension file size limits for file-size-check |

## §T — Tasks

| status | id | goal |
|---|---|---|
| `.` | T1 | Add `watch_file` entries to `.envrc` for `flake.nix`, `flake.lock`, and `dev.sh` per direnv skill |
| `.` | T2 | Add markdownlint lefthook remote — `.markdownlint.yml` config exists but no linter runs on `.md` files |
| `.` | T3 | Add test for files with spaces in their names |
| `.` | T4 | Add test for binary/non-text file handling |
| `.` | T5 | Add test for mixed existing and non-existing files where existing files all pass |
| `x` | T6 | Add `md` extension entry to `config/lefthook/file_size_limits.yml` |
| `.` | T7 | Add `toml` extension entry to `config/lefthook/file_size_limits.yml` and a TOML linter lefthook remote for `.rtk/filters.toml` |
| `.` | T8 | Add test for single existing conforming file among multiple non-existent files |
| `.` | T9 | Add `sh` extension entry to `config/lefthook/file_size_limits.yml` |

## §B — Bugs / Known Issues

1. **`.envrc` missing `watch_file` entries.** The direnv skill requires watching `flake.nix`, `flake.lock`, and shell files for automatic reload. Currently `.envrc` contains only `use flake`, so changes to `dev.sh` or `flake.nix` do not trigger a direnv reload.
2. **No markdownlint lefthook remote.** The project has a `.markdownlint.yml` configuration and 19 markdown files (README, CLAUDE.md, agent skills), but no markdownlint remote is listed in `lefthook.yml`. Per the linter skill, every tracked file type must have an assigned linter.
3. **No TOML linter.** `.rtk/filters.toml` is tracked in git but has no corresponding linter in `lefthook.yml`.
4. **Incomplete `file_size_limits.yml`.** The config covers `.lock`, `.nix`, `.bats`, `.yml`, and `.md` extensions but omits `.sh` and `.toml` files tracked in the repo.
5. **CI `fatal: $HOME not set` (2026-07-04).** `dev.sh` ran `lefthook install` unconditionally; in the CI nix shell `$HOME` is unset, causing git (called by lefthook) to fail. Fixed by guarding the call with `[ -z "${HOME:-}" ]`.
