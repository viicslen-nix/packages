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
  version = "0.9.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/openwiki/-/openwiki-${finalAttrs.version}.tgz";
    hash = "sha256-hZHU7NQzENChEDTGJFz0EXO65i5W/HiLlAc3ANcPPTI=";
  };

  # The registry tarball ships no lockfile; `just bump openwiki` regenerates
  # package-lock.json and npmDepsHash from the same stripped package.json.
  postPatch = ''
    ${lib.getExe nodejs} ${./strip-package-json.js}
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-VPHlONGA/a9Zxzs4P2IRAtUZsJc0AFPXiNHEnCQT06k=";

  # `dist/` is prebuilt in the tarball; only better-sqlite3 has to compile, and
  # its bundled prebuild-install would otherwise fetch a binary from the net.
  dontNpmBuild = true;
  # deepagents pins langsmith <0.10 while openwiki itself wants ^0.10.5.
  npmFlags = ["--omit=dev" "--legacy-peer-deps"];
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
