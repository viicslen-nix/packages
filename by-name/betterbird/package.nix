{
  lib,
  fetchurl,
  thunderbird-esr-bin-unwrapped,
  wrapThunderbird,
}: let
  version = "153.3.0esr-bb9";

  unwrapped = thunderbird-esr-bin-unwrapped.overrideAttrs (old: {
    pname = "betterbird-unwrapped";
    inherit version;

    src = fetchurl {
      url = "https://www.betterbird.eu/downloads/LinuxArchive/betterbird-${version}.en-US.linux-x86_64.tar.xz";
      hash = "sha256-EA+55pAULVYeaI05taZqiJvLbbQHGqJd0QFe0OoUj7M=";
    };

    # libName must keep the "thunderbird" prefix: wrapThunderbird keys the mail desktop entry on it
    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib/thunderbird-bin-${version}" "$out/bin"
      cp -r * "$out/lib/thunderbird-bin-${version}"
      ln -s "$out/lib/thunderbird-bin-${version}/betterbird" "$out/bin/"

      gappsWrapperArgs+=(--argv0 "$out/bin/.betterbird-wrapped")

      runHook postInstall
    '';

    passthru =
      old.passthru
      // {
        binaryName = "betterbird";
        applicationName = "Betterbird";
      };

    meta =
      old.meta
      // {
        description = "Fine-tuned Thunderbird with system tray support (binary package)";
        homepage = "https://www.betterbird.eu/";
        changelog = "https://www.betterbird.eu/releasenotes/";
        mainProgram = "betterbird";
        platforms = ["x86_64-linux"];
      };
  });
in
  wrapThunderbird unwrapped {
    pname = "betterbird";
    libName = "thunderbird-bin-${version}";
  }
