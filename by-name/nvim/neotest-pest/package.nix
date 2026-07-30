{pkgs}:
with pkgs; let
  version = "1.0";
in
  vimUtils.buildVimPlugin {
    pname = "neotest-pest";
    inherit version;

    src = fetchFromGitHub {
      owner = "V13Axel";
      repo = "neotest-pest";
      tag = "v${version}";
      sha256 = "sha256-8iCGpbrDnqJLTiB9oe5RvpTAgi9J9D0y7VzSw9qd0oQ=";
    };

    buildInputs = with vimPlugins; [
      neotest
    ];
  }
