<div align="center">

# 📦 packages

**Local packages for viicslen's NixOS config, with upstream-tracking bump tooling.**

[![NixOS unstable](https://img.shields.io/badge/nixpkgs-unstable-5277C3?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org)
[![x86_64-linux](https://img.shields.io/badge/system-x86__64--linux-555?style=flat-square)](#)
[![treefmt](https://img.shields.io/badge/fmt-treefmt--nix-7EBAE4?style=flat-square)](https://github.com/numtide/treefmt-nix)

</div>

Every `.nix` file under [`by-name/`](by-name) becomes a package through
`nixpkgs.lib.packagesFromDirectoryRecursive`; nothing is registered by hand.
Unfree packages are allowed.

## Outputs

| Output | Contents |
| --- | --- |
| `packages.x86_64-linux.<attr>` | Every package under `by-name/`, nested by directory |
| `formatter.x86_64-linux` | treefmt wrapper: deadnix → statix → alejandra, plus shfmt |
| `checks.x86_64-linux.treefmt` | Fails if `nix fmt` would change anything |
| `checks.x86_64-linux.statix` | `statix check`, which catches lints `statix fix` cannot (e.g. repeated keys) |

## Packages

An attr is the path under `by-name/` with `/` turned into `.`. A directory with
a `package.nix` is one package (its sibling files are helpers); otherwise each
`<name>.nix` is its own package.

| Attr | What it is |
| --- | --- |
| `app-images.{responsively,t3code,vial}` | AppImage wraps: Responsively, T3 Code, Vial |
| `awesome-vivaldi` | Vivaldi modpack (CSS/JS mods and their loader) |
| `vivaldi-stable`, `vivaldi-snapshot` | Vivaldi builds, sharing [`builders/vivaldi.nix`](builders/vivaldi.nix) |
| `betterbird` | Betterbird, the Thunderbird fork, as a wrapped binary |
| `ccstatusline` | Status line formatter for Claude Code |
| `coderabbit` | CodeRabbit CLI |
| `github.{copilot-cli,copilot-desktop}` | GitHub Copilot CLI and desktop app |
| `iris` | Inline CLI autocomplete overlay (patched for nushell) |
| `kubernetes.krr` | Robusta KRR, with a vendored `prometrix` |
| `nvim.{laravel-nvim,mcp-hub,neotest-pest,worktrees-nvim}` | Neovim plugins and `mcp-hub`, consumed by the nixvim subflake |
| `openwiki` | Agent documentation CLI (ships a generated `package-lock.json`) |
| `openwork` | OpenWork desktop app |
| `php.{laravel-lsp,phpantom-lsp}` | PHP language servers |
| `pixelflasher` | Pixel phone flashing GUI |
| `python.{browser-harness,cdp-use,fetch-use}` | browser-use's browser harness and its libraries |
| `python.jev-ultrafast` | Jev Ultrafast browser agent |
| `python.mempalace` | MemPalace local AI memory |
| `scripts.git-carve-submodule` | Split a subdirectory out into its own repo and re-add it as a submodule |
| `scripts.starship-smart-dir` | Git-aware directory segment for starship |
| `scripts.{system-install,system-update,system-upgrade}` | NixOS install / flake update / rebuild helpers |
| `superset.{cli,desktop}` | Superset CLI and desktop app |

`./scripts/packages.sh list` (or `just packages`) prints the current set.

## Usage

```nix
{
  inputs.packages = {
    url = "github:viicslen-nix/packages";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

```bash
nix build .#superset.cli
nix build .#nvim.laravel-nvim
nix flake show
```

The root config re-exports these as its own `packages.<system>.*` and reaches
them in modules as `pkgs.inputs.packages.*`.

> [!NOTE]
> There is no binary cache: every package builds from source on a bump.

## Maintenance

Recipes live in the [`Justfile`](Justfile), backed by
[`scripts/packages.sh`](scripts/packages.sh); the root repo aliases them.

| Recipe | Does |
| --- | --- |
| `just packages` | List package attrs |
| `just outdated` | Compare each package with upstream (GitHub releases, npm, PyPI, or the vendor's endpoint); read-only |
| `just bump <attr> [--version <x>\|skip]` | `nix-update --flake` one package |
| `just bump-outdated` | Bump everything `outdated` flags, to that exact version |
| `just bump-all` | Try every package carrying a src hash; list the ones nix-update can't resolve |

```bash
nix fmt          # deadnix, statix, alejandra, shfmt
nix flake check  # formatting + statix gates
```

<details>
<summary>Adding or bumping a package — the traps</summary>

- Put it at `by-name/<group>/<name>/package.nix` (or `by-name/<group>/<name>.nix`
  for a single file), then `git add` it: the flake is read through git, and an
  untracked file is simply not there.
- Interpolate the version into the tag (`tag = "v${version}"`). With a literal
  rev, nix-update rewrites `version` only and keeps building the old source.
- Keep `version` and `src` in the per-package file even when a builder holds the
  body: nix-update rewrites the file where `src` is defined. That is why the
  Vivaldi channels keep both in `vivaldi-{stable,snapshot}.nix`.
- Version autodetect covers GitHub, GitLab, PyPI, npm and crates.io. Anything
  else needs `--version <x>`; Vivaldi's channels read the newest build from
  Vivaldi's apt index instead. Multi-platform `fetchurl` needs a second pass
  with `--system aarch64-linux`.
- `openwiki`'s `package-lock.json` is generated, not upstream: regenerate it
  before `npmDepsHash` on every bump.

</details>

See [`builders/CONTEXT.md`](builders/CONTEXT.md) for why Vivaldi's
`libffmpeg` symlink must stay pointed at nixpkgs' codecs library.
