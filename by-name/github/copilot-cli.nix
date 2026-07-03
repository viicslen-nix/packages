{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  glibc,
}: let
  version = "1.0.67";
in
  stdenv.mkDerivation {
    pname = "github-copilot-cli";
    inherit version;

    src = fetchurl (
      if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64
      then {
        url = "https://github.com/github/copilot-cli/releases/download/v${version}/copilot-linux-x64.tar.gz";
        hash = "sha256-xtJR3iDRRBXr1q8Av7ao44VAlLSfpJ+3898r+mT22zs=";
      }
      else throw "Unsupported platform: ${stdenv.hostPlatform.system}"
    );

    nativeBuildInputs = [autoPatchelfHook];

    buildInputs = [
      glibc
      stdenv.cc.cc.lib
    ];

    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 copilot $out/bin/copilot

      runHook postInstall
    '';

    meta = {
      description = "GitHub Copilot CLI";
      homepage = "https://github.com/github/copilot-cli";
      changelog = "https://github.com/github/copilot-cli/releases/tag/v${version}";
      license = lib.licenses.unfree;
      mainProgram = "copilot";
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
