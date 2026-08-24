{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  nodejs,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ccstatusline";
  version = "2.2.27";

  # `bun build --target=node` emits one self-contained file and the package
  # declares no runtime dependencies, so the registry tarball is the whole
  # thing -- no lockfile to pin and no node_modules to vendor.
  src = fetchurl {
    url = "https://registry.npmjs.org/ccstatusline/-/ccstatusline-${finalAttrs.version}.tgz";
    hash = "sha256-T2Cb3tENjBBkUWzvuQLtWTkasru6l9WT6KEtB+LaWMI=";
  };

  nativeBuildInputs = [makeWrapper];

  # The bundle ships a `#!/usr/bin/env node` shebang; wrap it against the
  # store's node instead of leaving it to whatever PATH the caller has.
  installPhase = ''
    runHook preInstall

    install -Dm644 dist/ccstatusline.js $out/share/ccstatusline/ccstatusline.js
    makeWrapper ${lib.getExe nodejs} $out/bin/ccstatusline \
      --add-flags $out/share/ccstatusline/ccstatusline.js

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Customizable status line formatter for the Claude Code CLI";
    homepage = "https://github.com/sirmalloc/ccstatusline";
    license = lib.licenses.mit;
    mainProgram = "ccstatusline";
    platforms = lib.platforms.all;
    sourceProvenance = [lib.sourceTypes.binaryBytecode];
  };
})
