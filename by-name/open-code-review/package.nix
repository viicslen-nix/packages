{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}: let
  # Go expression standing in for os.UserHomeDir(): `$var`, else `$HOME/fallback`.
  xdgDir = var: fallback: ''func() (string, error) { if d := os.Getenv("${var}"); d != "" { return d, nil }; h, err := os.UserHomeDir(); return filepath.Join(h, "${fallback}"), err }()'';
  home = ''filepath.Join(home, ".opencodereview"'';
  xdg = ''filepath.Join(home, "opencodereview"'';
in
  buildGoModule (finalAttrs: {
    pname = "open-code-review";
    version = "1.14.3";

    src = fetchFromGitHub {
      owner = "alibaba";
      repo = "open-code-review";
      tag = "v${finalAttrs.version}";
      hash = "sha256-qtnUIiJ3xeCFa+vDClEdNFwAxK9OhGv9PNbOwTVsBUE=";
    };

    vendorHash = "sha256-60Z3sPZEW4ELAS5KjtJZ9QaR5oekmnqe1PSLz7hOwkY=";

    subPackages = ["cmd/opencodereview"];

    # Upstream hardcodes ~/.opencodereview; split it across XDG config/data/state.
    postPatch = ''
      substituteInPlace cmd/opencodereview/config_cmd.go internal/telemetry/config.go internal/config/rules/system_rules.go \
        --replace-fail 'os.UserHomeDir()' 'os.UserConfigDir()' \
        --replace-fail '${home}' '${xdg}'
      substituteInPlace internal/chatgptauth/store.go \
        --replace-fail 'os.UserHomeDir()' '${xdgDir "XDG_DATA_HOME" ".local/share"}' \
        --replace-fail '${home}' '${xdg}'
      substituteInPlace internal/session/{delete,list,persist,resume,raw_writer}.go internal/viewer/store.go \
        --replace-fail 'os.UserHomeDir()' '${xdgDir "XDG_STATE_HOME" ".local/state"}' \
        --replace-fail '${home}' '${xdg}'
    '';

    # the suite pins ~/.opencodereview paths and needs git fixtures
    doCheck = false;

    ldflags = [
      "-s"
      "-w"
      "-X main.Version=v${finalAttrs.version}"
    ];

    postInstall = ''
      ln -s $out/bin/opencodereview $out/bin/ocr
    '';

    passthru.updateScript = nix-update-script {};

    meta = {
      description = "LLM code review CLI with line-level comments and built-in rulesets";
      homepage = "https://open-codereview.ai";
      changelog = "https://github.com/alibaba/open-code-review/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.asl20;
      mainProgram = "ocr";
    };
  })
