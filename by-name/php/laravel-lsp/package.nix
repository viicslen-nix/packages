{pkgs}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "laravel-lsp";
  version = "0.0.31";

  # Statically linked PHP build — no patching or PHP runtime needed.
  src = pkgs.fetchurl {
    url = "https://github.com/laravel/lsp/releases/download/v${finalAttrs.version}/server-v${finalAttrs.version}-x64-linux";
    hash = "sha256-z4Ftro0baMSh9yiORiVzKj+H3w3M31oGfn4xW5ZDyII=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/laravel-lsp
    # The app mkdir's `logs` next to the phar on boot and dies on the read-only
    # store. Pre-create it — the default log channel is stderr, so nothing
    # actually writes there.
    mkdir $out/bin/logs
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "The official Laravel language server";
    homepage = "https://github.com/laravel/lsp";
    license = licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "laravel-lsp";
  };
})
