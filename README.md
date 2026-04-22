# Packages Subflake

This subflake provides a standalone local package set that can be shared across other local subflakes.

## Purpose

- Keep custom package definitions in one place
- Expose packages through a dedicated flake
- Organize related packages by domain under `by-name/`

### Current grouped areas

- `by-name/nvim/`: Neovim/Nixvim plugin-related packages (for example `laravel-nvim`, `mcp-hub`)
- `by-name/php/`: PHP tooling packages (for example `mago`, `phpantom-lsp`)

## How packages are exported

This flake uses `nixpkgs.lib.packagesFromDirectoryRecursive` over `./by-name`, so all package definitions under this directory are exported automatically.

## Build and inspect

From repository root:

```bash
# Inspect exported outputs
nix flake show .

# Build an example package
nix build .#php.mago

# Build an example nvim package
nix build .#nvim-plugins.laravel-nvim
```

## Add a new package

1. Create a folder under `by-name/<group>/<package-name>/`
2. Add `package.nix` in that folder
3. Confirm it appears in `nix flake show .`
4. Build it to validate

Example:

```text
by-name/php/my-tool/package.nix
```

## Notes

- Keep package names and metadata aligned with nixpkgs conventions
- Prefer grouping by domain (`php`, `nvim`, etc.) for discoverability
