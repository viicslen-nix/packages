{
  lib,
  fetchurl,
  jetbrains,
}:
# ponytail: reuse nixpkgs' JetBrains builder, only swap the source tarball.
# Renaming `pname` is what lets this sit next to `jetbrains.phpstorm` in a
# profile: the launcher, the install dir and the desktop entry all follow it.
jetbrains.phpstorm.overrideAttrs (old: {
  pname = "phpstorm-light";
  version = "262.9024";

  src = fetchurl {
    url = "https://download.jetbrains.com/webide/nightly/PhpStorm-262.9024.tar.gz";
    hash = "sha256-s44pF9JulhXMCPt56paQS5jxTNJ9eaPXujntB3KFVG8=";
  };

  # The builder bakes the *original* pname into the icon file names and the
  # `Icon=` key, which would collide with jetbrains.phpstorm. Rename them.
  postInstall = ''
    for icon in $out/share/icons/hicolor/*/apps/phpstorm.*; do
      mv "$icon" "''${icon%/*}/$pname.''${icon##*.}"
    done

    item=$(readlink $out/share/applications)
    rm $out/share/applications
    mkdir -p $out/share/applications
    substitute $item/$pname.desktop $out/share/applications/$pname.desktop \
      --replace-fail "Icon=phpstorm" "Icon=$pname" \
      --replace-fail "Name=PhpStorm" "Name=PhpStorm Light"
  '';

  passthru =
    old.passthru
    // {
      buildNumber = "262.9024";
    };

  meta =
    old.meta
    // {
      description = "Trimmed-down, experimental build of PhpStorm";
      longDescription = "Experimental PhpStorm build with faster startup, lower memory usage and fewer bundled features.";
      homepage = "https://phpstorm.dev/light-mode";
      mainProgram = "phpstorm-light";
      platforms = ["x86_64-linux"];
      maintainers = [];
    };
})
