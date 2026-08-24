{
  lib,
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonApplication rec {
  pname = "mempalace";
  version = "3.8.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-kzZCXC6Nq9wChhdWXmY8Iq8heb4z75+CJASqeCIe0h4=";
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
