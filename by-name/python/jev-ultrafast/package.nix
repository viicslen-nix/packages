{
  lib,
  callPackage,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication rec {
  pname = "jev-ultrafast";
  version = "0.1.0-unstable-2026-09-18";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "browser-use";
    repo = "jev-ultrafast";
    rev = "1231850a0bf1a0c0341fe408ef1668dbbfdfac46";
    hash = "sha256-8EJhsOjalxX6uUCu+bREqopVUBG8O64SehhQUdNUwVI=";
  };

  build-system = [python3Packages.hatchling];

  pythonRelaxDeps = true;

  dependencies =
    [(callPackage ../browser-harness/package.nix {})]
    ++ python3Packages.httpx.optional-dependencies.http2;

  # browser-harness spawns its daemon as a bare `python -m`, which needs these on PYTHONPATH.
  makeWrapperArgs = [
    "--prefix"
    "PYTHONPATH"
    ":"
    (python3Packages.makePythonPath dependencies)
  ];

  nativeCheckInputs = [python3Packages.pytestCheckHook];

  # browser-harness creates its state dirs under $HOME on import.
  preInstallCheck = ''export HOME="$(mktemp -d)"'';

  pythonImportsCheck = ["jev_ultrafast"];

  meta = with lib; {
    description = "Browser agent with a dynamic, indexed action space driven by TypeSafe's Jev";
    homepage = "https://github.com/browser-use/jev-ultrafast";
    license = licenses.mit;
    maintainers = [];
    mainProgram = "jev";
  };
}
