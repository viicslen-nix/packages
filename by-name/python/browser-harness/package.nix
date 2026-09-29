{
  lib,
  callPackage,
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonPackage rec {
  pname = "browser-harness";
  version = "0.1.13";
  pyproject = true;

  src = fetchPypi {
    pname = "browser_harness";
    inherit version;
    hash = "sha256-KE3FR6BCwwn+r9mp9KdLKoZRt5Y+o6xssvLWSIn2qPM=";
  };

  # Upstream's `mcp==2.1.1` needs httpx2/mcp-types, which nixpkgs lacks; the
  # server only uses the 1.x FastMCP surface under its 2.x name.
  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail '"setuptools==84.0.0"' '"setuptools"'
    substituteInPlace src/mcp_server.py \
      --replace-fail 'from mcp.server import MCPServer' 'from mcp.server.fastmcp import FastMCP as MCPServer'
  '';

  build-system = [python3Packages.setuptools];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    (callPackage ../cdp-use/package.nix {})
    (callPackage ../fetch-use/package.nix {})
    pillow
    websockets
    mcp
  ];

  makeWrapperArgs = [
    # Nix owns the version; the self-updater would `pip install -U` over it.
    "--set-default"
    "BH_UPDATE_CHECK"
    "0"
    # The daemon is spawned as `sys.executable -m browser_harness.daemon`, a bare
    # interpreter that never sees the site dirs the entry-point script adds.
    "--prefix"
    "PYTHONPATH"
    ":"
    "${placeholder "out"}/${python3Packages.python.sitePackages}:${python3Packages.makePythonPath dependencies}"
  ];

  # Importing it creates its state dirs under $HOME.
  preInstallCheck = ''export HOME="$(mktemp -d)"'';

  pythonImportsCheck = [
    "browser_harness"
    "mcp_server"
  ];

  meta = with lib; {
    description = "Thin harness that lets an agent drive your real browser over CDP";
    homepage = "https://github.com/browser-use/browser-harness";
    license = licenses.mit;
    maintainers = [];
    mainProgram = "browser-harness";
  };
}
