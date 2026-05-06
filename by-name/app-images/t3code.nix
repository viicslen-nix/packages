{
  lib,
  fetchurl,
  appimageTools,
}: let
  version = "0.0.22";
  pname = "t3code";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-JUlF9G6KkvOy550HwndsnfYQBUlReRWCJUe6cqx/9Xc=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/t3code.desktop -t $out/share/applications
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

    meta = {
      description = "AI-powered coding assistant from the creators of t3.chat";
      homepage = "https://github.com/pingdotgg/t3code";
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
      license = lib.licenses.unfree;
      mainProgram = "t3code";
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
