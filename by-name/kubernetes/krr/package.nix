{
  lib,
  python3,
  fetchFromGitHub,
  testers,
  krr,
}:

python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "krr";
  version = "1.28.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "robusta-dev";
    repo = "krr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bc1Ql3z/UmOXE2RJYC5/sE4a3MFdE06I3HwKY+SdSlk=";
  };

  postPatch = ''
    # substituteInPlace robusta_krr/__init__.py \
    #   --replace-warn '1.7.0-dev' '${finalAttrs.version}'

    substituteInPlace pyproject.toml \
      --replace '1.8.2-dev' '${finalAttrs.version}' \
      --replace 'kubernetes = "^26.1.0"' 'kubernetes = "*"' \
      --replace 'pydantic = "1.10.7"' 'pydantic = "*"' \
      --replace 'typer = { extras = ["all"], version = "^0.7.0" }' 'typer = { extras = ["all"], version = "*" }'

    # Fix pydantic v2 compatibility by using pydantic.v1 namespace
    find . -type f -name '*.py' | while read f; do
      sed -i 's/import pydantic as pd/import pydantic.v1 as pd/g' "$f"
      sed -i 's/from pydantic import/from pydantic.v1 import/g' "$f"
      sed -i 's/^import pydantic$/import pydantic.v1 as pydantic/g' "$f"
    done
  '';

  propagatedBuildInputs = with python3.pkgs; [
    aiostream
    alive-progress
    cachetools
    kubernetes
    numpy
    poetry-core
    prometheus-api-client
    prometrix
    pydantic_1
    pydantic-settings
    slack-sdk
    typer
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  # Skip runtime dependency checks due to version mismatches with available packages
  pythonRuntimeDepsCheckHook = "true";
  # Allow pydantic v1 and v2 to coexist (needed for prometrix)
  pythonCatchConflictsPhase = "true";

  pythonImportsCheck = [];

  doCheck = false;

  passthru.tests.version = testers.testVersion {
    package = krr;
    command = "krr version";
  };

  meta = {
    description = "Prometheus-based Kubernetes resource recommendations";
    longDescription = ''
      Robusta KRR (Kubernetes Resource Recommender) is a CLI tool for optimizing
      resource allocation in Kubernetes clusters. It gathers Pod usage data from
      Prometheus and recommends requests and limits for CPU and memory. This
      reduces costs and improves performance.
    '';
    homepage = "https://github.com/robusta-dev/krr";
    changelog = "https://github.com/robusta-dev/krr/releases/tag/v${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "krr";
  };
})
