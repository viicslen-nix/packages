{
  lib,
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonPackage rec {
  pname = "fetch-use";
  version = "0.4.0";
  pyproject = true;

  src = fetchPypi {
    pname = "fetch_use";
    inherit version;
    hash = "sha256-lRGYfUkH7G2sUB4h1mlG0QCY9mtdIbwqukGJzYG6GJo=";
  };

  build-system = [python3Packages.hatchling];

  pythonImportsCheck = ["fetch_use"];

  meta = with lib; {
    description = "Python client for the Browser Use Fetch HTTP service";
    homepage = "https://github.com/browser-use/fetch-use";
    license = licenses.mit;
    maintainers = [];
  };
}
