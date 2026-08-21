{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "iris";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "versenilvis";
    repo = "iris";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+1FZgqViuQYZkhjxvbAg9l8vvazyA5RACyVRL7ubWHQ=";
  };

  # Upstream supports bash, zsh and fish only. The patch adds a nushell
  # adapter (`iris init nu`, `--shell nu`) and fixes core.shell being
  # validated and logged but never actually read by the wrapper.
  # Drop it once versenilvis/iris carries nushell support upstream.
  patches = [./nushell-adapter.patch];

  subPackages = ["cmd/iris"];

  proxyVendor = true;
  vendorHash = "sha256-q1szUQkhdKq2VhMuWYYWTahmDxGeVjvHLmjciZu3cBU=";

  # the suite shells out to bash/zsh/fish and pokes at $HOME
  doCheck = false;

  ldflags = ["-s" "-w"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Context-aware CLI autocomplete overlay that renders inline in any TTY";
    homepage = "https://github.com/versenilvis/iris";
    changelog = "https://github.com/versenilvis/iris/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd0;
    mainProgram = "iris";
    # the nushell hook reaches the IRIS_FD pipe through /proc/self/fd
    platforms = lib.platforms.linux;
  };
})
