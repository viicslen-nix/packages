# Package maintenance for this subflake. The root repo aliases these recipes.
# An attr is a package's path under by-name/ with slashes turned into dots
# (app-images.t3code, superset.cli, bare coderabbit).

# List the local package attrs (as `just bump` takes them)
packages:
  @./scripts/packages.sh list

# Compare each GitHub-sourced package against the latest release upstream
# Read-only: no downloads, no file edits — feed the results to `just bump <attr>`
outdated:
  @./scripts/packages.sh outdated

# Bump version + hash of a package
# Usage: just bump coderabbit --version 0.4.5   (or --version skip for hash only)
bump ATTR *ARGS:
  @./scripts/packages.sh bump {{ATTR}} {{ARGS}}

# Bump every package `just outdated` reports as behind, to that exact version
# Usage: just bump-outdated [--commit]
bump-outdated *ARGS:
  @./scripts/packages.sh bump-outdated {{ARGS}}

# Try to bump every package; prints the ones nix-update can't resolve
bump-all *ARGS:
  @./scripts/packages.sh bump-all {{ARGS}}
