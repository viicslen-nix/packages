#!/usr/bin/env bash
#
# Package maintenance for this subflake.
#
# Backs the `just packages / outdated / bump / bump-outdated / bump-all`
# recipes (aliased from the root repo); run it directly the same way:
#
#   ./scripts/packages.sh list
#   ./scripts/packages.sh outdated
#   ./scripts/packages.sh bump coderabbit --version 0.4.5
#
# An attr is a package's path under by-name/ with slashes turned into dots
# (`app-images.t3code`, `superset.cli`, bare `coderabbit`).
set -euo pipefail

# the subflake root, wherever it is checked out
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# by-name/<dir>/package.nix -> <dir>; by-name/<dir>/<name>.nix -> <dir>/<name>
attr_of() {
  local f=$1 d=${1%/*} a
  if [[ -f $d/package.nix ]]; then a=${d#by-name/}; else a=${f#by-name/}; a=${a%.nix}; fi
  echo "${a//\//.}"
}

# every package file, one per attr (a dir with package.nix owns the whole dir)
package_files() {
  local f d
  while read -r f; do
    d=${f%/*}
    if [[ $f == */package.nix || ! -f $d/package.nix ]]; then echo "$f"; fi
  done < <(find by-name -name '*.nix' "$@" | sort)
}

list() {
  local f
  while read -r f; do attr_of "$f"; done < <(package_files)
}

# Read-only: no downloads, no file edits — feed the results to `bump <attr>`
outdated() {
  local f attr owner repo current tag prefix latest mark other=()
  printf '%-24s %-14s %-14s\n' ATTR CURRENT LATEST
  while read -r f; do
    attr=$(attr_of "$f")

    owner=$(sed -n 's/.*owner = "\([^"]*\)".*/\1/p' "$f" | head -1)
    repo=$(sed -n 's/.*repo = "\([^"]*\)".*/\1/p' "$f" | head -1)
    if [[ -z $owner || -z $repo ]]; then
      read -r owner repo < <(sed -n 's|.*github\.com/\([^/"]*\)/\([^/"]*\)/releases/download.*|\1 \2|p' "$f" | head -1) || true
    fi
    if [[ -z $owner || -z $repo ]]; then other+=("$attr"); continue; fi

    current=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$f" | head -1)

    # tag template -> release-tag prefix ("cli-v${version}" -> "cli-v"); ignore pinned revs
    tag=$(sed -n -e 's|.*releases/download/\([^/]*\)/.*|\1|p' -e 's/.*\(rev\|tag\) = "\([^"]*\)".*/\2/p' "$f" | head -1)
    if [[ $tag =~ ^[0-9a-f]{40}$ ]]; then tag=''; fi
    prefix=${tag%%[0-9$]*}

    # newest tag with that prefix followed by a digit; stable preferred, prerelease as fallback
    latest=$(gh api "repos/$owner/$repo/releases?per_page=50" --jq "
      (\"$prefix\") as \$p
      | [.[] | select(.tag_name | startswith(\$p)) | select(.tag_name[(\$p | length):] | test(\"^[0-9]\"))] as \$c
      | (([\$c[] | select(.prerelease == false)] | .[0]) // \$c[0]).tag_name // \"-\"" 2>/dev/null) || latest='?'
    latest=${latest#"$prefix"}

    # only flag a real forward move (upstream's newest stable can be behind a pinned prerelease)
    mark=''
    if [[ $latest != "$current" && $latest != - && $latest != '?' ]] &&
       [[ $(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -1) == "$latest" ]]; then
      mark='  <- update'
    fi
    printf '%-24s %-14s %-14s%s\n' "$attr" "$current" "$latest" "$mark"
  done < <(package_files ! -path 'by-name/scripts/*')
  # ponytail: '-' means the repo publishes no matching release (rev-pinned or tagless)
  [[ ${#other[@]} -eq 0 ]] || printf 'not GitHub-sourced: %s\n' "${other[*]}"
}

# Newest build of a vivaldi channel, from Vivaldi's apt index (it lists both
# channels, unsorted). No git forge for nix-update to read a version off.
vivaldi_latest() {
  curl -fsSL https://repo.vivaldi.com/stable/deb/dists/stable/main/binary-amd64/Packages |
    awk -v p="vivaldi-$1" '$1=="Package:"{c=$2} $1=="Version:" && c==p {sub(/-[0-9]+$/,"",$2); print $2}' |
    sort -V | tail -1
}

bump() {
  local attr=$1; shift
  local args=("$@")
  if [[ $attr == vivaldi-* && ! " ${args[*]-} " =~ " --version " ]]; then
    args+=(--version "$(vivaldi_latest "${attr#vivaldi-}")")
  fi
  nix run nixpkgs#nix-update -- --flake "$attr" ${args[@]+"${args[@]}"}
}

# Bump every package `outdated` reports as behind, to that exact version
bump_outdated() {
  local rows attr latest failed=()
  mapfile -t rows < <(outdated | awk '/<- update/ {print $1, $3}')
  if [[ ${#rows[@]} -eq 0 ]]; then echo 'everything up to date'; return 0; fi
  printf 'bumping %d package(s)\n' "${#rows[@]}"
  for row in "${rows[@]}"; do
    read -r attr latest <<<"$row"
    echo "==> $attr -> $latest"
    bump "$attr" --version "$latest" "$@" || failed+=("$attr")
  done
  [[ ${#failed[@]} -eq 0 ]] || printf 'failed: %s\n' "${failed[*]}"
}

# Try every package carrying a src hash; print the ones nix-update can't resolve
bump_all() {
  local f attr skipped=()
  while read -r f; do
    grep -qE '(hash|sha256|sha512) = "' "$f" || continue
    attr=$(attr_of "$f")
    echo "==> $attr"
    bump "$attr" "$@" || skipped+=("$attr")
  done < <(package_files)
  # ponytail: no auto-retry with --version skip; run `bump <attr> --version <x>` for these
  [[ ${#skipped[@]} -eq 0 ]] || printf 'skipped (no version detected): %s\n' "${skipped[*]}"
}

cmd=${1:-list}; shift || true
case $cmd in
  list) list ;;
  outdated) outdated ;;
  vivaldi-latest) vivaldi_latest "$@" ;;
  bump) bump "$@" ;;
  bump-outdated) bump_outdated "$@" ;;
  bump-all) bump_all "$@" ;;
  *) echo "usage: ${0##*/} {list|outdated|bump <attr> [args]|bump-outdated|bump-all|vivaldi-latest <channel>}" >&2; exit 2 ;;
esac
