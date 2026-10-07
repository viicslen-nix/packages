{pkgs}:
pkgs.stdenv.mkDerivation rec {
  pname = "phpantom-lsp";
  version = "0.11.1";

  src = pkgs.fetchurl {
    url = "https://github.com/AJenbo/phpantom_lsp/releases/download/${version}/phpantom_lsp-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-kG3YEE1L+CqhxCJfuil6kP8c/wVS32Ne6Fj8Jy9EX8Y=";
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
