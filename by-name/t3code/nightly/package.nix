{
  lib,
  makeDesktopItem,
  llm-agents,
  # Named after llm-agents' wrapper argument: the t3code home-manager module `.override`s it.
  t3code-unwrapped ? null,
}: let
  version = "0.0.46-nightly.20261009.2873";

  stable = llm-agents.t3code.unwrapped;

  replaceOrThrow = what: from: to: s: let
    out = lib.replaceStrings [from] [to] s;
  in
    if out == s
    then throw "t3code.nightly: anchor for ${what} not found in llm-agents' t3code; the override needs updating"
    else out;

  src = stable.src.override {
    owner = "pingdotgg";
    repo = "t3code";
    tag = "v${version}";
    hash = "sha256-PhMilpaL64mqxkXKChg05+SbXvvD+x/h3CzNmPLsdAU=";
  };

  # A changed Cargo.lock surfaces as a cargo-vendor hash mismatch; set `cargoHash` here then.
  resourceMonitor = stable.passthru.resourceMonitor.overrideAttrs {
    inherit version src;
  };

  cli = "t3-nightly";
  app = "t3code-desktop-nightly";
  icon = "t3code-nightly";

  desktopItem = makeDesktopItem {
    name = "t3code-nightly";
    desktopName = "T3 Code (Nightly)";
    comment = "Control surface for coding agents";
    exec = "${app} %U";
    inherit icon;
    categories = ["Development"];
    startupWMClass = "t3code";
  };

  nightly = stable.overrideAttrs (old: {
    inherit version src;

    pnpmDeps = old.pnpmDeps.override {
      inherit version src;
      hash = "sha256-G3EHVkAEJrl2eOd6dvLjUfwmAurHvq2FZyYM92SFFmE=";
    };

    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace apps/desktop/src/app/DesktopUserData.ts \
          --replace-fail 'current: "t3code-v2"' 'current: "t3code-nightly"'
      '';

    preBuild =
      replaceOrThrow "the release version" "update-release-package-versions.ts ${old.version}"
      "update-release-package-versions.ts ${version}"
      old.preBuild;

    installPhase =
      replaceOrThrow "the resource monitor" "${old.passthru.resourceMonitor}" "${resourceMonitor}"
      old.installPhase;

    postInstall =
      (old.postInstall or "")
      + ''
        chmod u+w "$desktop/share/applications"
        rm "$desktop/share/applications/t3code.desktop"
        install -Dm444 ${desktopItem}/share/applications/t3code-nightly.desktop -t "$desktop/share/applications"

        mv "$desktop/share/icons/t3code.png" "$desktop/share/icons/${icon}.png"
        mv "$desktop/share/icons/hicolor/scalable/apps/t3code.svg" "$desktop/share/icons/hicolor/scalable/apps/${icon}.svg"

        (
          cd "$out/share"
          sed -e 's/\b_t3/_t3_nightly/g' -e 's/^complete -F _t3_nightly t3$/complete -F _t3_nightly ${cli}/' \
            bash-completion/completions/t3.bash > bash-completion/completions/${cli}.bash
          sed -e 's/\b_t3/_t3_nightly/g' -e 's/^#compdef t3$/#compdef ${cli}/' -e 's/compdef _t3_nightly t3$/compdef _t3_nightly ${cli}/' \
            zsh/site-functions/_t3 > zsh/site-functions/_${cli}
          sed -e 's/^complete -c t3 /complete -c ${cli} /' \
            fish/vendor_completions.d/t3.fish > fish/vendor_completions.d/${cli}.fish
          rm bash-completion/completions/t3.bash zsh/site-functions/_t3 fish/vendor_completions.d/t3.fish
          grep -q '^complete -F _t3_nightly ${cli}$' bash-completion/completions/${cli}.bash
          grep -q '^#compdef ${cli}$' zsh/site-functions/_${cli}
          grep -q '^complete -c ${cli} ' fish/vendor_completions.d/${cli}.fish
        )
      '';

    passthru = old.passthru // {inherit resourceMonitor;};

    meta = old.meta // {changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";};
  });

  wrapped = llm-agents.t3code.override {
    t3code-unwrapped =
      if t3code-unwrapped == null
      then nightly
      else t3code-unwrapped;
  };
in
  # Renamed so it installs beside a stable t3code; the module reads these names back.
  wrapped.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        mv "$out/bin/t3" "$out/bin/${cli}"
        mv "$desktop/bin/t3code-desktop" "$desktop/bin/${app}"
      '';

    passthru =
      old.passthru
      // {
        cliProgram = cli;
        desktopProgram = app;
        iconName = icon;
      };

    meta = old.meta // {mainProgram = cli;};
  })
