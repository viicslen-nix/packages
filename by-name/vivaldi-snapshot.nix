{
  callPackage,
  fetchurl,
  # forwarded so `vivaldi.override` keeps working through callPackage
  proprietaryCodecs ? false,
  enableWidevine ? false,
}: let
  version = "8.2.4133.29";
in
  (callPackage ../builders/vivaldi.nix {
    channel = "snapshot";
    inherit proprietaryCodecs enableWidevine;
  })
  .overrideAttrs (_: {
    inherit version;

    src = fetchurl {
      url = "https://downloads.vivaldi.com/snapshot/vivaldi-snapshot_${version}-1_amd64.deb";
      hash = "sha256-5dXroub+CvXzZ7y2uf+LG9olmOvQHNC4CHmS/YdDfy4=";
    };
  })
