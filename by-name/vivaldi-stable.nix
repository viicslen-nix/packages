{
  callPackage,
  fetchurl,
  # forwarded so `vivaldi.override` keeps working through callPackage
  proprietaryCodecs ? false,
  enableWidevine ? false,
}: let
  version = "8.1.4087.70";
in
  (callPackage ../builders/vivaldi.nix {
    channel = "stable";
    inherit proprietaryCodecs enableWidevine;
  })
  .overrideAttrs (_: {
    inherit version;

    src = fetchurl {
      url = "https://downloads.vivaldi.com/stable/vivaldi-stable_${version}-1_amd64.deb";
      hash = "sha256-8abo9bxEphuM+AK+vFSBLyFCLi26U6D6YlyL9yFnRlk=";
    };
  })
