{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pun";
  version = "0.4.4";

  src = fetchurl {
    url = "https://github.com/shipfastlabs/pun/releases/download/v${finalAttrs.version}/punphp-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-LT1BuH4hzyC5gwmF1x0BkNWBqOygzODdjBj+yR43zaM=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 pun $out/bin/pun
    ln -s pun $out/bin/punx
    runHook postInstall
  '';

  meta = {
    description = "The ultrafast unified PHP toolchain";
    homepage = "https://punphp.com";
    license = lib.licenses.mit;
    mainProgram = "pun";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
