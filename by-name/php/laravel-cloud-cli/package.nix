{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  php,
  git,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "laravel-cloud-cli";
  version = "0.7.3";

  src = fetchurl {
    url = "https://github.com/laravel/cloud-cli/releases/download/v${finalAttrs.version}/cloud";
    hash = "sha256-N60sQ5QmJI7DQIca4tt+08DXWIQQgI6rKl7RgIZT98k=";
  };

  dontUnpack = true;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/libexec/cloud.phar
    makeWrapper ${lib.getExe php} $out/bin/cloud \
      --add-flags $out/libexec/cloud.phar \
      --prefix PATH : ${lib.makeBinPath [git]}
    runHook postInstall
  '';

  meta = {
    description = "Deploy and manage Laravel Cloud applications from the command line";
    homepage = "https://github.com/laravel/cloud-cli";
    license = lib.licenses.mit;
    mainProgram = "cloud";
    platforms = lib.platforms.unix;
    sourceProvenance = [lib.sourceTypes.binaryBytecode];
  };
})
