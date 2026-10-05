{
  lib,
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonApplication rec {
  pname = "mempalace";
  version = "3.10.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-x28a6ugaaLaVJJ+UDmdx8UeuO+c9mbtDrZNTDeEssfQ=";
  };

  build-system = [python3Packages.hatchling];

  dependencies = with python3Packages; [
    chromadb
    pyyaml
    tomli
  ];

  pythonImportsCheck = ["mempalace"];
  doCheck = false;

  meta = with lib; {
    description = "Local AI memory system for mining and searching project and conversation context";
    homepage = "https://github.com/MemPalace/mempalace";
    changelog = "https://github.com/MemPalace/mempalace/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [];
    mainProgram = "mempalace";
  };
}
