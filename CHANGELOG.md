# Changelog

All notable changes to this project are documented here.

## Unreleased

### Fixed

- Refresh `nixpkgs-lock` (nixpkgs `ac588ef`); brotli stays 1.2.1. ruby is still
  3.4.11 (CVE-2026-97229) upstream, pending pr0d1r2/nixpkgs-lock#94; ruby is not
  used by this repo, so re-run `nix flake update nixpkgs-lock` once it lands.
- Pin bump: `set-and-setting` now follows this flake's `nixpkgs` and
  `nixpkgs-lock`, leaving a single nixpkgs lock node (lock-graph check).
- Restore the `lefthook-editorconfig-checker` package and its build check,
  dropped by the vendored-to-referenced migration.
- Put the packaged wrapper on every devShell PATH so the unit tests run.
