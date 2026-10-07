{
  callPackage,
  fetchurl,
  # forwarded so `vivaldi.override` keeps working through callPackage
  proprietaryCodecs ? false,
  enableWidevine ? false,
}: let
  version = "8.2.4133.84";
in
  (callPackage ../builders/vivaldi.nix {
    channel = "stable";
    inherit proprietaryCodecs enableWidevine;
  })
  .overrideAttrs (_: {
    inherit version;

    src = fetchurl {
      url = "https://downloads.vivaldi.com/stable/vivaldi-stable_${version}-1_amd64.deb";
      hash = "sha256-3whviT+Fd2q2jq9tuZHe7eE00oD9stbHST+j/zDIMB4=";
    };
  })
