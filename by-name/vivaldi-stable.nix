{
  callPackage,
  fetchurl,
  # forwarded so `vivaldi.override` keeps working through callPackage
  proprietaryCodecs ? false,
  enableWidevine ? false,
}: let
  version = "8.1.4087.75";
in
  (callPackage ../builders/vivaldi.nix {
    channel = "stable";
    inherit proprietaryCodecs enableWidevine;
  })
  .overrideAttrs (_: {
    inherit version;

    src = fetchurl {
      url = "https://downloads.vivaldi.com/stable/vivaldi-stable_${version}-1_amd64.deb";
      hash = "sha256-nLfNB2SB3Z7PQ0gRXbegQ0JD6RHie2EVdQkuNLLUiZw=";
    };
  })
