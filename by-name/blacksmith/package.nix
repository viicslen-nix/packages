{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  rsync,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "blacksmith";
  version = "0.5.3";

  src = fetchurl (
    if stdenvNoCC.hostPlatform.isLinux && stdenvNoCC.hostPlatform.isx86_64
    then {
      url = "https://clireleases.blacksmith.sh/cli/v${finalAttrs.version}/linux/amd64/blacksmith";
      hash = "sha256-CJowHqXMk6dWDH8RBpEVR/39RvxcDO9weeKmKiLpcc4=";
    }
    else if stdenvNoCC.hostPlatform.isLinux && stdenvNoCC.hostPlatform.isAarch64
    then {
      url = "https://clireleases.blacksmith.sh/cli/v${finalAttrs.version}/linux/arm64/blacksmith";
      hash = "sha256-SsyhXLEIssz/KV39PkRLgakP1SPVdExl/FKj7LvOfRc=";
    }
    else throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}"
  );

  dontUnpack = true;

  nativeBuildInputs = [makeWrapper];

  # Self-update would try to overwrite the store path; testbox sync shells out to rsync.
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/blacksmith
    wrapProgram $out/bin/blacksmith \
      --set BLACKSMITH_DISABLE_AUTO_UPDATE 1 \
      --suffix PATH : ${lib.makeBinPath [rsync]}
    runHook postInstall
  '';

  meta = {
    description = "Blacksmith CLI: CI logs, job metrics, caches, sticky disks and testboxes";
    homepage = "https://docs.blacksmith.sh/blacksmith-cli/overview";
    license = lib.licenses.unfree;
    mainProgram = "blacksmith";
    platforms = ["x86_64-linux" "aarch64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
