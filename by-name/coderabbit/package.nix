{
  lib,
  stdenv,
  fetchurl,
  unzip,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "coderabbit";
  version = "0.7.6";

  src = fetchurl (
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64
    then {
      url = "https://cli.coderabbit.ai/releases/${finalAttrs.version}/coderabbit-linux-x64.zip";
      hash = "sha256-hToXJ2CasP8fVoY/pt56zz3lk6bcG9f5GjLxHFck/8k=";
    }
    else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64
    then {
      url = "https://cli.coderabbit.ai/releases/${finalAttrs.version}/coderabbit-linux-arm64.zip";
      hash = "sha256-WW+Vf2e3ugeSUSfFJTDikWMRd9jcug86Zt61WppbBuk=";
    }
    else throw "Unsupported platform: ${stdenv.hostPlatform.system}"
  );

  nativeBuildInputs = [unzip];

  sourceRoot = ".";

  # CodeRabbit is a Bun single-file executable with embedded payload offsets.
  # Stripping mutates the ELF and causes it to fall back to generic Bun mode.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    # CodeRabbit bundles a Bun single-file executable; do not patch the ELF.
    install -Dm755 coderabbit $out/bin/coderabbit
    ln -s $out/bin/coderabbit $out/bin/cr

    runHook postInstall
  '';

  meta = {
    description = "CodeRabbit CLI for reviewing local changes and interacting with CodeRabbit AI";
    homepage = "https://coderabbit.ai";
    license = lib.licenses.unfree;
    mainProgram = "coderabbit";
    platforms = ["x86_64-linux" "aarch64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
