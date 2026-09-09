{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  glibc,
}: let
  version = "1.0.83";
in
  stdenv.mkDerivation {
    pname = "github-copilot-cli";
    inherit version;

    src = fetchurl (
      if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64
      then {
        url = "https://github.com/github/copilot-cli/releases/download/v${version}/copilot-linux-x64.tar.gz";
        hash = "sha256-/74cQpZkuKBe/tZ+zbRnEj5A/Ko8bBTvmpi6dNpGh7c=";
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
