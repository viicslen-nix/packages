{
  lib,
  pkgs,
  fetchFromGitHub,
}:
# MCPHub CLI tool (npm package)
# Note: mcphub-nvim plugin comes from the flake input, not built here
pkgs.buildNpmPackage rec {
  pname = "mcp-hub";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "ravitemer";
    repo = "mcp-hub";
    rev = "v${version}";
    sha256 = "sha256-KakvXZf0vjdqzyT+LsAKHEr4GLICGXPmxl1hZ3tI7Yg=";
  };

  npmDepsHash = "sha256-nyenuxsKRAL0PU/UPSJsz8ftHIF+LBTGdygTqxti38g=";

  meta = with lib; {
    description = "MCP Hub CLI tool";
    homepage = "https://github.com/ravitemer/mcp-hub";
    license = licenses.mit;
    maintainers = [];
  };
}
