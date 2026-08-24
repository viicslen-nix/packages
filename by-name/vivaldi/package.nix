{
  lib,
  vivaldi,
  fetchurl,
  # forwarded so `vivaldi.override` keeps working through callPackage
  proprietaryCodecs ? false,
  enableWidevine ? false,
}: let
  version = "8.2.4133.24";
  versionShort = lib.versions.majorMinor version;
  channel = "snapshot";
  isSnapshot = channel != "stable";
  basePath =
    if isSnapshot
    then "opt/vivaldi-snapshot"
    else "opt/vivaldi";
in
  (vivaldi.override {inherit proprietaryCodecs enableWidevine;}).overrideAttrs (oldAttrs: {
    inherit version;

    src = fetchurl {
      url = "https://downloads.vivaldi.com/${channel}/vivaldi-${channel}_${version}-1_amd64.deb";
      hash = "sha256-M7YOD+QZB7J3XWR3PmQ8UsKnQA2dzqzuzwPNVNT4aWY=";
    };

    passthru =
      (oldAttrs.passthru or {})
      // {
        inherit isSnapshot;
        desktopFileName =
          if isSnapshot
          then "vivaldi-snapshot"
          else "vivaldi-stable";
      };

    buildPhase =
      if isSnapshot
      then
        builtins.replaceStrings
        ["opt/vivaldi/"]
        ["opt/vivaldi-snapshot/"]
        oldAttrs.buildPhase
      else oldAttrs.buildPhase;

    installPhase =
      if isSnapshot
      then
        builtins.replaceStrings
        ["opt/vivaldi/vivaldi" "vivaldi-stable" "opt/vivaldi/"]
        ["opt/vivaldi-snapshot/vivaldi-snapshot" "vivaldi-snapshot" "opt/vivaldi-snapshot/"]
        oldAttrs.installPhase
      else oldAttrs.installPhase;

    # nixpkgs replaces Vivaldi's bundled ffmpeg by symlinking libffmpeg.so.<ver>
    # to chromium-codecs-ffmpeg-extra, but that package is pinned to an older
    # Chromium and lacks symbols this Vivaldi build needs (e.g.
    # av_dynamic_hdr_smpte2094_app5_to_t35). The launcher LD_PRELOADs that
    # symlink, so point it back at Vivaldi's own version-matched libffmpeg.so.
    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        ln -sf libffmpeg.so "$out/${basePath}/libffmpeg.so.${versionShort}"
      '';
  })
