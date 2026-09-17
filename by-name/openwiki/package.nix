{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
  python3,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "openwiki";
  version = "0.5.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/openwiki/-/openwiki-${finalAttrs.version}.tgz";
    hash = "sha256-9W2tmstMo+tlsVhrLK7ZdzJPLlSPiuQRdwety9xrC2I=";
  };

  # The registry tarball ships no lockfile, so this one is generated from the
  # published package.json with `npm install --package-lock-only
  # --ignore-scripts` after stripping devDependencies -- regenerate it on every
  # version bump or npmDepsHash will not match.
  postPatch = ''
    ${lib.getExe nodejs} -e '
      const fs = require("fs");
      const pkg = JSON.parse(fs.readFileSync("package.json"));
      delete pkg.devDependencies;
      delete pkg.scripts;
      fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
    '
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-KGtL5r3koAYCaCailYCs4wnAWaJerucBmFdKIvgubho=";

  # `dist/` is prebuilt in the tarball; only better-sqlite3 has to compile, and
  # its bundled prebuild-install would otherwise fetch a binary from the net.
  dontNpmBuild = true;
  npmFlags = ["--omit=dev"];
  env.npm_config_build_from_source = "true";

  nativeBuildInputs = [python3];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "CLI that writes and maintains agent documentation for your codebase";
    homepage = "https://github.com/langchain-ai/openwiki";
    license = lib.licenses.mit;
    mainProgram = "openwiki";
    platforms = lib.platforms.unix;
    sourceProvenance = [lib.sourceTypes.binaryBytecode];
  };
})
