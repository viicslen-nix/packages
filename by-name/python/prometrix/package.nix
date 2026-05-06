{
  lib,
  boto3,
  botocore,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  prometheus-api-client,
  pydantic,
  pythonAtLeast,
  requests,
  unstableGitUpdater,
}:
buildPythonPackage {
  pname = "prometrix";
  version = "0.2.11-unstable-2026-04-07";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "robusta-dev";
    repo = "prometrix";
    rev = "e1eceacc35e5f10fa4cf8a3bc7e2b52c5cbad9f6";
    hash = "sha256-TSCNBidkIhHtF6LieTACMDSJXROLW2/hd+mtcAzkBwc=";
  };

  pythonRelaxDeps = true;

  pythonRemoveDeps = [
    # Transitive dependency version pins for CVE patches, not direct imports
    "fonttools"
    "idna"
    "pillow"
    "zipp"
  ];

  build-system = [poetry-core];

  dependencies = [
    boto3
    botocore
    prometheus-api-client
    pydantic
    requests
  ];

  # Fixture is missing
  # https://github.com/robusta-dev/prometrix/issues/9
  doCheck = false;

  pythonImportsCheck = ["prometrix"];

  passthru.updateScript = unstableGitUpdater {};

  meta = {
    description = "Unified Prometheus client";
    longDescription = ''
      This Python package provides a unified Prometheus client that can be used
      to connect to and query various types of Prometheus instances.
    '';
    homepage = "https://github.com/robusta-dev/prometrix";
    license = lib.licenses.mit;
    maintainers = [];
  };
}
