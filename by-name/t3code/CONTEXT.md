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
src hash and the `pnpmDeps` hash here. `just outdated` tracks only the nightly
channel for any version pinned to one.

**The llm-agents pin must match the root's.** The root makes this flake's
`llm-agents` follow its own, so hosts build against the root pin — but
`nix-update` evaluates this subflake standalone, with *its* lock. The `pnpmDeps`
hash depends on llm-agents' pnpm, so a drifted pin can produce a hash the host
build then rejects. After `just update-input llm-agents` in the root, re-lock
here to the same rev.

Nightlies build from source; there is no cache for them.

## `app-image`

Stable release AppImage. Its desktop id is `t3code-appimage` for the same
reason as above: the source builds own `t3code.desktop` / `t3code-nightly.desktop`,
and the home profile sorts ahead of the system one in `XDG_DATA_DIRS`.
