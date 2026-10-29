{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  parso,

  # tests
  attrs,
  pytestCheckHook,
  pythonAtLeast,
}:

buildPythonPackage (finalAttrs: {
  pname = "jedi";
  version = "0.20.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "davidhalter";
    repo = "jedi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s8ITHaV3cSpo0oMW7RmZ3PejmMoERC7RbNPcbIfWqA0=";
    fetchSubmodules = true;
  };

  build-system = [ setuptools ];

  dependencies = [ parso ];

  nativeCheckInputs = [
    attrs
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  disabledTests =
    lib.optionals stdenv.hostPlatform.isDarwin [
      # sensitive to platform, causes false negatives on darwin
      "test_import"
    ]
    ++ lib.optionals stdenv.targetPlatform.useLLVM [
      # InvalidPythonEnvironment: The python binary is potentially unsafe.
      "test_create_environment_executable"
      # AssertionError: assert ['', '.1000000000000001'] == ['', '.1']
      "test_dict_keys_completions"
      # AssertionError: assert ['', '.1000000000000001'] == ['', '.1']
      "test_dict_completion"
    ]
    ++ lib.optionals (pythonAtLeast "3.15") [
      # needs further investigation, but I assume assumptions about the environment that don't hold on nixos are made
      "test_find_system_environments"
      "test_scanning_venvs"
      "test_create_environment_venv_path"
      "test_create_environment_executable"
      "test_venv_and_pths"
    ];

  meta = {
    changelog = "https://github.com/davidhalter/jedi/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    description = "Autocompletion tool for Python that can be used for text editors";
    homepage = "https://github.com/davidhalter/jedi";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
