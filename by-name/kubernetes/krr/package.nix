{
  lib,
  python3Packages,
  fetchFromGitHub,
  testers,
  krr,
}: let
  pythonPackages = python3Packages.overrideScope (
    self: super: {
      pydantic = self.pydantic_1;
      # yarl only uses pydantic in tests; skip its pydantic tests under v1
      yarl = super.yarl.overridePythonAttrs {
        disabledTestPaths = (super.yarl.disabledTestPaths or []) ++ ["test_pydantic.py"];
      };
      # django tests are not relevant for krr (transitive dep only)
      django = super.django.overridePythonAttrs (_: {
        doCheck = false;
      });
    }
  );

  # Use the local package definition from this flake for compatibility with krr.
  localPrometrix = pythonPackages.callPackage ../../python/prometrix/package.nix {};
in
  pythonPackages.buildPythonApplication rec {
    pname = "krr";
    version = "1.28.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "robusta-dev";
      repo = "krr";
      tag = "v${version}";
      hash = "sha256-1wCvoqlFBgC7SSPdq13q4CjR/rJnhv5g/xrty9YUQtg=";
    };

    postPatch = ''
      substituteInPlace robusta_krr/__init__.py \
        --replace-fail 'dev' '${version}'

      substituteInPlace pyproject.toml \
        --replace-fail '1.8.2-dev' '${version}'

      # Fix TypeError: argument of type 'NoneType' is not iterable when
      # --namespace / --resource / --prometheus-other-headers / --named-sinks are not provided
      # (typer returns None for List[str] defaults under pydantic v1).
      substituteInPlace robusta_krr/main.py \
        --replace-fail \
          'namespaces="*" if "*" in namespaces else namespaces,' \
          'namespaces="*" if namespaces and "*" in namespaces else (namespaces or []),' \
        --replace-fail \
          'resources="*" if "*" in resources else resources,' \
          'resources="*" if resources and "*" in resources else (resources or []),' \
        --replace-fail \
          'prometheus_other_headers=prometheus_other_headers,' \
          'prometheus_other_headers=prometheus_other_headers or [],' \
        --replace-fail \
          'named_sinks=named_sinks,' \
          'named_sinks=named_sinks or [],'
    '';

    pythonRelaxDeps = true;

    pythonRemoveDeps = [
      # Transitive dependency version pins, not direct imports
      "idna"
      "setuptools"
      "urllib3"
      "zipp"
    ];

    build-system = with pythonPackages; [
      poetry-core
    ];

    dependencies = with pythonPackages; [
      alive-progress
      cachetools
      kubernetes
      numpy
      pandas
      prometheus-api-client
      localPrometrix
      pydantic
      pyyaml
      requests
      slack-sdk
      tenacity
      typer
    ];

    nativeCheckInputs = with pythonPackages; [
      pytest-asyncio
      pytestCheckHook
    ];

    # Tests require a Kubernetes cluster and use deprecated click API (mix_stderr)
    doCheck = false;

    pythonImportsCheck = [
      "robusta_krr"
    ];

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
      changelog = "https://github.com/robusta-dev/krr/releases/tag/${src.tag}";
      license = lib.licenses.mit;
      maintainers = [];
      mainProgram = "krr";
    };
  }
