{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}: let
  version = "1.20.1";
  pname = "superset";
  executableName = "superset-desktop";

  src = fetchurl {
    url = "https://github.com/superset-sh/superset/releases/download/desktop-v${version}/Superset-x86_64.AppImage";
    hash = "sha256-5yY1E7nWQiSx04PVhKivWUrt7dFyIPnjwc8F5kB7Sxw=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};

  desktopItem = makeDesktopItem {
    name = pname;
    exec = executableName;
    icon = pname;
    desktopName = "Superset";
    comment = "Code editor for the AI agents era";
    categories = ["Development" "IDE"];
    startupWMClass = "Superset";
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = _: [];

    extraInstallCommands = ''
      if [ -e $out/bin/${pname} ]; then
        mv $out/bin/${pname} $out/bin/${executableName}
      fi

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
      mainProgram = executableName;
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
