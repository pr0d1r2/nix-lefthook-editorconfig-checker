# Changelog

All notable changes to this project are documented here.

## Unreleased

### Fixed

- Pin bump: `set-and-setting` now follows this flake's `nixpkgs` and
  `nixpkgs-lock`, leaving a single nixpkgs lock node (lock-graph check).
- Restore the `lefthook-editorconfig-checker` package and its build check,
  dropped by the vendored-to-referenced migration.
- Put the packaged wrapper on every devShell PATH so the unit tests run.
