# Shared body for both Vivaldi channels — see by-name/vivaldi-{stable,snapshot}.nix.
# Each channel sets its own `version`/`src` there, because nix-update locates the
# file to rewrite from where `src` is defined (`just bump vivaldi-<channel>`).
{
  vivaldi,
  channel,
  proprietaryCodecs ? false,
  enableWidevine ? false,
}: let
  isSnapshot = channel != "stable";
  # a snapshot deb installs itself beside a stable one, under its own names
  basePath =
    if isSnapshot
    then "opt/vivaldi-snapshot"
    else "opt/vivaldi";
  exeName =
    if isSnapshot
    then "vivaldi-snapshot"
    else "vivaldi";
  desktopFileName =
    if isSnapshot
    then "vivaldi-snapshot"
    else "vivaldi-stable";
in
  (vivaldi.override {inherit proprietaryCodecs enableWidevine;}).overrideAttrs (oldAttrs: {
    passthru =
      (oldAttrs.passthru or {})
      // {inherit isSnapshot desktopFileName;};

    # Both phases hardcode the stable layout, so rewrite the paths — the
    # substitutions are no-ops on the stable channel. 8.2 also stopped shipping
    # the bundled ANGLE lib that the shim loop still patchelfs, and patchelf
    # hard-fails on a missing file, so skip what the deb doesn't carry.
    buildPhase =
      builtins.replaceStrings
      ["opt/vivaldi/" "libqt5_shim.so libqt6_shim.so; do"]
      ["${basePath}/" "libqt5_shim.so libqt6_shim.so; do\n  [ -e ${basePath}/$f ] || continue"]
      oldAttrs.buildPhase;

    installPhase =
      builtins.replaceStrings
      ["opt/vivaldi/vivaldi" "vivaldi-stable" "opt/vivaldi/"]
      ["${basePath}/${exeName}" desktopFileName "${basePath}/"]
      oldAttrs.installPhase;
  })
