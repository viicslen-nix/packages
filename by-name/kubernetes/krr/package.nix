{
  lib,
  # pydantic v1 (required by krr) is unsupported on python 3.14, the new nixpkgs default.
  python312Packages,
  fetchFromGitHub,
  testers,
  krr,
}: let
  pythonPackages = python312Packages.overrideScope (
    self: super: {
      pydantic = self.pydantic_1;
      # yarl only uses pydantic in tests; skip its pydantic tests under v1
      yarl = super.yarl.overridePythonAttrs {
        disabledTestPaths = (super.yarl.disabledTestPaths or []) ++ ["test_pydantic.py"];
      };
      # slack-sdk test deps pull in python packages currently marked broken.
      # krr does not require running slack-sdk tests at build/eval time.
      slack-sdk = super.slack-sdk.overridePythonAttrs (_: {
        doCheck = false;
        nativeCheckInputs = [];
      });
      # django tests are not relevant for krr (transitive dep only)
      django = super.django.overridePythonAttrs (_: {
        doCheck = false;
      });
    }
  );

  # Private to krr: needs a python scope, so it cannot be a top-level by-name package.
  localPrometrix = pythonPackages.callPackage ./prometrix.nix {};
in
  pythonPackages.buildPythonApplication rec {
    pname = "krr";
    version = "1.29.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "robusta-dev";
      repo = "krr";
      tag = "v${version}";
      hash = "sha256-nf5z1dBVcQF/Zv79EnTzQeH6NsB3fhOUqkfgv5U4Ofo=";
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
      python-json-logger
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
