{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}: let
  pname = "openwork";
  version = "0.18.26";

  # upstream dropped the .deb after 0.2.x; releases are AppImages now
  src = fetchurl {
    url = "https://github.com/different-ai/openwork/releases/download/v${version}/openwork-linux-x86_64-${version}.AppImage";
    hash = "sha256-aTCIZjszs4d5K7Aocyoyp1OXkZi3BV4QfLR/gIOiJJ4=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "OpenWork";
    comment = "AI-powered productivity application";
    categories = ["Office" "Utility"];
    startupWMClass = "openwork";
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
      description = "OpenWork - AI-powered productivity application";
      homepage = "https://github.com/different-ai/openwork";
      changelog = "https://github.com/different-ai/openwork/releases/tag/v${version}";
      license = lib.licenses.unfree;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
