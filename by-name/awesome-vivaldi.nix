{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "awesome-vivaldi";
  # rev-pinned: upstream tags rarely, so `just bump awesome-vivaldi --version <x>`
  version = "0-unstable-2026-08-11";

  # the repo is ~750M of docs, themes and reverse-engineering dumps; take the modpack only
  src = fetchFromGitHub {
    owner = "PaRr0tBoY";
    repo = "Awesome-Vivaldi";
    rev = "c9d49e2e5a7976d99524775250de62440956f698";
    hash = "sha256-GjfkT4Y824XqS++ncVemogrsSOsFpUv3a+XdwklTazo=";
    sparseCheckout = [
      "Vivaldi8.0Stable/CSS"
      "Vivaldi8.0Stable/Javascripts"
      "Vivaldi8.0Stable/Import.css"
      "injectMods.js"
    ];
  };

  dontBuild = true;

  # Mirrors what install.sh deploys into <vivaldi>/resources/vivaldi: the loader
  # at the root, mods under user_mods/, and Import.css flattened (upstream writes
  # its @import paths relative to the repo, not to the deployed css directory).
  installPhase = ''
    runHook preInstall

    mkdir -p $out/user_mods/css $out/user_mods/js
    cp injectMods.js $out/injectMods.js
    cp Vivaldi8.0Stable/CSS/*.css $out/user_mods/css/
    cp Vivaldi8.0Stable/Javascripts/*.js $out/user_mods/js/
    sed 's|@import "CSS/|@import "|g' Vivaldi8.0Stable/Import.css >$out/user_mods/css/Import.css

    runHook postInstall
  '';

  meta = {
    description = "Vivaldi modpack: CSS/JS mods plus the loader that window.html pulls in";
    homepage = "https://github.com/PaRr0tBoY/Awesome-Vivaldi";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
