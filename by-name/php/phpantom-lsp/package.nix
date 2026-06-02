{pkgs}:
pkgs.stdenv.mkDerivation rec {
  pname = "phpantom-lsp";
  version = "0.8.0";

  src = pkgs.fetchurl {
    url = "https://github.com/AJenbo/phpantom_lsp/releases/download/${version}/phpantom_lsp-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-OWFbSV5iS7r+h4fDvmGsq8Ej7FrCPpsw4Aq3Zg9Q4CA=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    glibc
    gcc-unwrapped.lib
  ];

  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp phpantom_lsp $out/bin/
    chmod +x $out/bin/phpantom_lsp
  '';

  meta = with pkgs.lib; {
    description = "PHPantom Language Server Protocol implementation";
    homepage = "https://github.com/AJenbo/phpantom_lsp";
    license = licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "phpantom_lsp";
  };
}
