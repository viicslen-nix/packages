# CONTEXT

## `nightly`

llm-agents' `t3code` (wrapper + `unwrapped`), rebuilt from an upstream
`v<version>-nightly.*` tag instead of the stable release. It overrides the same
derivation rather than copying it: `src` and `pnpmDeps` through their own
`.override`, the resource monitor through `overrideAttrs`, and two string
splices into the unwrapped build — the version `preBuild` passes to
`update-release-package-versions.ts`, and the resource-monitor store path baked
into `installPhase`. Both splices throw if their anchor disappears, so an
llm-agents rewrite fails the eval instead of silently building stable bits.

**The `t3code-unwrapped ? null` argument is load-bearing.** `by-name/` goes
through `callPackage`, which replaces the result's `.override` with one that
re-calls *this* file. The t3code home-manager module patches the package with
`.override {t3code-unwrapped = …;}`, so this file has to accept that argument
and forward it to llm-agents' wrapper; without it the eval fails with
`called with unexpected argument 't3code-unwrapped'`.

**Installs beside stable.** Everything that would collide with a stable t3code
in one profile is renamed: commands `t3-nightly` / `t3code-desktop-nightly`,
launcher `t3code-nightly.desktop` ("T3 Code (Nightly)"), icon `t3code-nightly`,
and the shell completions (registered for `t3-nightly`, with the `_t3*`
functions renamed to `_t3_nightly*` so sourcing both does not redefine one with
the other). The new names are in `passthru.{cliProgram,desktopProgram,iconName}`,
which the home-manager module reads. Renaming happens on the outer wrapper, so
the unwrapped build — which the module patches — keeps upstream's names.

The Electron profile is patched from `t3code-v2` to `t3code-nightly`: once
stable reaches 0.0.46 it uses `t3code-v2` too, and two apps on one Chromium
profile fight over its lock. `StartupWMClass` stays `t3code`: the app hardcodes
that WM class, and the niri window rules match it.

What cannot be split: the SnapShot D-Bus name (`com.t3tools.T3Code.SnapShot`,
first app to start owns it), and the `t3code://` handler the app rewrites into
`~/.local/share/applications/com.t3tools.T3Code.desktop` on every launch, so
OAuth callbacks go to whichever app started last.

**Bumping.** `just bump t3code.nightly` reads `nix-update-args`: releases
(not the tag feed, which mixes in "Preview" maintainer builds that must not be
installed), unstable allowed, filtered to `-nightly.` tags, and
`--override-filename` because nix-update would otherwise try to edit
llm-agents' read-only files, where `src` is defined. It rewrites `version`, the
src hash and the `pnpmDeps` hash here.

**`pnpmDeps` is host-platform only.** Stock `fetchPnpmDeps` installs with
`--force`, which pulls every OS/CPU's optional deps so that one hash fits all
systems. For t3code that was a 1.3 GB archive, unpacked in every build's
configure phase (55s). `pnpmConfigHook` installs offline for the host platform
only, so the foreign half was never read. The nightly strips `--force` from
the fetcher's `installPhase` (`replaceOrThrow`, so a fetcher rewrite fails the
eval). The archive is now ~344 MB and configure is under 30s; the built
outputs have the same file trees as before. Upstream sets no
`supportedArchitectures` in `pnpm-workspace.yaml`; if it ever does, pnpm
fetches what it lists. The cost: the hash is per-system, and the one here is
x86_64-linux's. An aarch64 build needs its own hash.

The `pnpmDeps` step is still most of a bump's time. About half of the
nightlies leave `pnpm-lock.yaml` and `pnpm-workspace.yaml` alone, so when both
blobs match between the old and new tag, `bump` passes `--src-only` and keeps the hash. That reasoning breaks if a
llm-agents bump changes pnpm itself. If the build then fails on a `pnpmDeps`
hash mismatch, run `just bump t3code.nightly --no-src`.

A stable release published after the last nightly (and not behind its base
version) wins: upstream cuts `v0.1.5` *after* `v0.1.5-nightly.*`, and that
stable tag is then the newest code. nix-update cannot choose it — it ranks
`0.1.5` below `0.1.5-nightly.*`, as `builtins.compareVersions` does — so
`scripts/packages.sh` picks the version itself (`nightly_or_stable`, by
publish date) for both `bump` and `outdated`, and hands nix-update an explicit
`--version`. The next nightly moves it back to the nightly channel. The build
is the same either way, still renamed to `t3-nightly`.

**The llm-agents pin must match the root's.** The root makes this flake's
`llm-agents` follow its own, so hosts build against the root pin — but
`nix-update` evaluates this subflake standalone, with *its* lock. The `pnpmDeps`
hash depends on llm-agents' pnpm, so a drifted pin can produce a hash the host
build then rejects. After `just update-input llm-agents` in the root, re-lock
here to the same rev.

**Node 26 / pnpm 12, from llm-agents' nixpkgs.** Upstream declares
`engines.node` 26 and `packageManager` pnpm 12 (nixpkgs' own t3code builds with
both); llm-agents still passes `nodejs_24` / `pnpm_11`, so the nightly
overrides those two arguments. They come from `llm-agents-pkgs`
(`llm-agents.inputs.nixpkgs`, exposed in `flake.nix`), not this flake's
nixpkgs: hosts make this flake's nixpkgs follow the root's, which differs from
the lock `bump` hashes against, so a pnpm taken from there would give hosts a
different `pnpmDeps` hash. llm-agents' nixpkgs is left un-overridden, so the
pin rule above covers it. pnpm 12's `deploy` adds per-package `.bin` shims;
nothing else in the outputs changed.

Not absorbed from nixpkgs' t3code: `fetcherVersion = 5` only keeps a virtual
store out of the archive, and ours has none (`v11/files` + `index.db.sql`).
Newer nixpkgs exports `pnpm_config_force_ignores_platform=true` because pnpm
≥12.7 made `--force` skip foreign deps; dropping `--force` above is unaffected.

Nightlies build from source; there is no cache for them. Of a ~3 min build,
the stock fixup took ~54s: `stripDirs` runs `strip` once per regular file
(`xargs -n1`) and `noBrokenSymlinks` walks every link, across ~47k
`node_modules` files that hold only a few ELFs. Those ELFs are prebuilt addons
and small binaries that are already stripped.
`installPhase` already deletes broken links. So the nightly sets `dontStrip` and
`dontCheckForBrokenSymlinks`, and fixup drops below stdenv's 30s reporting
threshold. vite-plus's "cache disabled" is not worth chasing: each `vp` task
runs once in a fresh sandbox, so a cache could never hit.

## `app-image`

Stable release AppImage. Its desktop id is `t3code-appimage` for the same
reason as above: the source builds own `t3code.desktop` / `t3code-nightly.desktop`,
and the home profile sorts ahead of the system one in `XDG_DATA_DIRS`.
