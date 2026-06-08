{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libgcc,
  glibc,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "superset-cli";
  version = "0.2.22";

  src = fetchurl (
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64
    then {
      url = "https://github.com/superset-sh/superset/releases/download/cli-v${finalAttrs.version}/superset-linux-x64.tar.gz";
      hash = "sha256-5iRiVBuB7ZWYT9rrRiLFMxwn+yoUVkiu7PFJALeB0ZU=";
    }
    else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64
    then {
      url = "https://github.com/superset-sh/superset/releases/download/cli-v${finalAttrs.version}/superset-linux-arm64.tar.gz";
      hash = "sha256-g9xlgwB+XcX9WQD3+0gq6kom1yWrb2iND3NKf1sl6Qw=";
    }
    else throw "Unsupported platform: ${stdenv.hostPlatform.system}"
  );

  nativeBuildInputs = [autoPatchelfHook];

  buildInputs = [
    glibc
    libgcc
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./* $out/

    runHook postInstall
  '';

  meta = {
    description = "Terminal CLI for Superset";
    homepage = "https://github.com/superset-sh/superset";
    changelog = "https://github.com/superset-sh/superset/releases/tag/cli-v${finalAttrs.version}";
    license = lib.licenses.unfree;
    mainProgram = "superset";
    platforms = ["x86_64-linux" "aarch64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
