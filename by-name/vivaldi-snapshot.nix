{
  callPackage,
  fetchurl,
  # forwarded so `vivaldi.override` keeps working through callPackage
  proprietaryCodecs ? false,
  enableWidevine ? false,
}: let
  version = "8.3.4175.3";
in
  (callPackage ../builders/vivaldi.nix {
    channel = "snapshot";
    inherit proprietaryCodecs enableWidevine;
  })
  .overrideAttrs (_: {
    inherit version;

    src = fetchurl {
      url = "https://downloads.vivaldi.com/snapshot/vivaldi-snapshot_${version}-1_amd64.deb";
      hash = "sha256-lFpUpR4weZG03BypXsleP9PnV0oJRESLXJx3rlZwfe0=";
    };
  })
