{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}: let
  version = "0.0.34-nightly.20260821.1151";
  pname = "t3code";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-asDSHhlKSoQsou6n1RY/FfrPbVLdYLQDbuRoOrSVKpQ=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};

  # The t3code home-manager module installs the source build, which owns
  # `t3code.desktop` and `bin/t3code-desktop`. The binaries already differ, but
  # the desktop ids don't — and the home profile sorts ahead of the system one
  # in XDG_DATA_DIRS, so a shared id means this entry never reaches the
  # launcher. Take a distinct one.
  desktopId = "${pname}-appimage";

  desktopItem = makeDesktopItem {
    name = desktopId;
    exec = pname;
    icon = pname;
    desktopName = "T3 Code (AppImage)";
    comment = "AI-powered coding assistant from the creators of t3.chat";
    categories = ["Development"];
    startupWMClass = "t3code";
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${desktopItem}/share/applications/${desktopId}.desktop \
        $out/share/applications/${desktopId}.desktop
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
