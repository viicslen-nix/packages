{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}: let
  pname = "github-copilot-desktop";
  version = "1.1.14";
  executableName = "github-copilot";

  src = fetchurl {
    url = "https://github.com/github/app/releases/download/v${version}/GitHub-Copilot-linux-x64.AppImage";
    hash = "sha256-qdvre3k4W9mCPMyrsCUpU/zQ9kgg3s44faueA+5QHEQ=";
  };

  appimageContents = appimageTools.extract {inherit pname version src;};

  desktopItem = makeDesktopItem {
    name = pname;
    exec = executableName;
    icon = "github-copilot";
    desktopName = "GitHub Copilot";
    comment = "Agent-native desktop experience for GitHub Copilot";
    categories = ["Development" "IDE"];
    startupWMClass = "GitHub Copilot";
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      if [ -e $out/bin/${pname} ]; then
        mv $out/bin/${pname} $out/bin/${executableName}
      fi

      install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
        $out/share/applications/${pname}.desktop

      if [ -f ${appimageContents}/github-copilot.png ]; then
        install -m 444 -D ${appimageContents}/github-copilot.png \
          $out/share/icons/hicolor/512x512/apps/github-copilot.png
      fi

      if [ -d ${appimageContents}/usr/share/icons ]; then
        cp -r ${appimageContents}/usr/share/icons $out/share
      fi
    '';

    meta = {
      description = "GitHub Copilot desktop app";
      homepage = "https://github.com/github/app";
      changelog = "https://github.com/github/app/releases/tag/v${version}";
      license = lib.licenses.unfree;
      mainProgram = executableName;
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
