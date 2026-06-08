{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}: let
  version = "1.12.4";
  pname = "superset";

  src = fetchurl {
    url = "https://github.com/superset-sh/superset/releases/download/desktop-v${version}/Superset-x86_64.AppImage";
    hash = "sha256-uONFYMJcCl5mKVw5c/HTMrQgrjyphmr3UCSvTdgtS94=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "Superset";
    comment = "Code editor for the AI agents era";
    categories = ["Development" "IDE"];
    startupWMClass = "Superset";
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
        $out/share/applications/${pname}.desktop

      if [ -d ${appimageContents}/usr/share/icons ]; then
        cp -r ${appimageContents}/usr/share/icons $out/share
      fi
    '';

    meta = {
      description = "Code editor for the AI agents era";
      homepage = "https://github.com/superset-sh/superset";
      changelog = "https://github.com/superset-sh/superset/releases/tag/desktop-v${version}";
      license = lib.licenses.unfree;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
