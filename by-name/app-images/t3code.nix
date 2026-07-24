{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}: let
  version = "0.0.29-nightly.20260723.885";
  pname = "t3code";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-pzVvKxca5sBDHthqZlYDLSzF9vQ+7mGt9Rsm9phnRxA=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "T3 Code";
    comment = "AI-powered coding assistant from the creators of t3.chat";
    categories = ["Development"];
    startupWMClass = "t3code";
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
        $out/share/applications/${pname}.desktop
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
