{
  lib,
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonPackage rec {
  pname = "cdp-use";
  version = "1.4.5";
  pyproject = true;

  src = fetchPypi {
    pname = "cdp_use";
    inherit version;
    hash = "sha256-DaOjLfRjNqA/9aIrxrxELNfS8tUKEY/UhW8p039tJqA=";
  };

  build-system = [python3Packages.hatchling];

  dependencies = with python3Packages; [
    httpx
    typing-extensions
    websockets
  ];

  pythonImportsCheck = ["cdp_use"];

  meta = with lib; {
    description = "Type-safe generator and client library for the Chrome DevTools Protocol";
    homepage = "https://github.com/browser-use/cdp-use";
    license = licenses.mit;
    maintainers = [];
  };
}
