{
  lib,
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonApplication rec {
  pname = "mempalace";
  version = "3.3.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ttMVcabQIb7kKOQBmO61xXQohfsXLSSDvbtjoaFFhIc=";
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
