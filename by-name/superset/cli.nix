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
  version = "1.22.0";

  src = fetchurl (
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64
    then {
      url = "https://github.com/superset-sh/superset/releases/download/cli-v${finalAttrs.version}/superset-linux-x64.tar.gz";
      hash = "sha256-PUMdKqYTwyF8muL8F1XRNhmtqK7Z9spGT7+ZrbOC7SM=";
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

    install -d $out
    cp -r bin lib share $out/

    runHook postInstall
  '';

  meta = {
    description = "Terminal CLI for Superset";
    homepage = "https://github.com/superset-sh/superset";
    changelog = "https://github.com/superset-sh/superset/releases/tag/cli-v${finalAttrs.version}";
    license = lib.licenses.unfree;
    mainProgram = "superset";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
