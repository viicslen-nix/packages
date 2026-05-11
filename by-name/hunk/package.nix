{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  libgcc,
  glibc,
  libX11,
  zlib,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hunk";
  version = "0.10.0";

  src = fetchurl (
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64
    then {
      url = "https://github.com/modem-dev/hunk/releases/download/v${finalAttrs.version}/hunkdiff-linux-x64.tar.gz";
      hash = "sha256-ND3Kb1u0B5O+joNCvE4LzJjYpSFnt5QWDFGmuAmYns8=";
    }
    else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64
    then {
      url = "https://github.com/modem-dev/hunk/releases/download/v${finalAttrs.version}/hunkdiff-linux-arm64.tar.gz";
      hash = "sha256-epaG0urTx3nqr2mIClkDLzrxf+gOZE4EDyC0YyEPq8M=";
    }
    else throw "Unsupported platform: ${stdenv.hostPlatform.system}"
  );

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libgcc
    glibc
    libX11
    zlib
  ];

  sourceRoot =
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64
    then "hunkdiff-linux-x64"
    else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64
    then "hunkdiff-linux-arm64"
    else ".";

  # Hunk ships as a Bun single-file executable; stripping mutates the ELF and
  # causes it to fall back to generic Bun mode instead of running Hunk.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 hunk $out/libexec/hunk
    makeWrapper $out/libexec/hunk $out/bin/hunk

    runHook postInstall
  '';

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;

  meta = {
    description = "Review-first terminal diff viewer for agentic coders";
    homepage = "https://github.com/modem-dev/hunk";
    changelog = "https://github.com/modem-dev/hunk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "hunk";
    platforms = ["x86_64-linux" "aarch64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
