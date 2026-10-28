{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  poetry-core,

  # dependencies
  markdown-it-py,
  pygments,

  # optional-dependencies
  ipywidgets,

  # tests
  attrs,
  pytestCheckHook,
  which,
  pythonAtLeast,

  # for passthru.tests
  enrich,
  httpie,
  rich-rst,
  textual,
}:

buildPythonPackage (finalAttrs: {
  pname = "rich";
  version = "15.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Textualize";
    repo = "rich";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uk3r6aYhrjYJ8GrMKfdlv3/muK/uUynd4pd1yWCwSOM=";
  };

  # https://github.com/Textualize/rich/issues/4209
  patches = [ ./Update-to-pygments-2.21.0.patch ];

  build-system = [ poetry-core ];

  dependencies = [
    markdown-it-py
    pygments
  ];

  optional-dependencies = {
    jupyter = [ ipywidgets ];
  };

  nativeCheckInputs = [
    attrs
    pytestCheckHook
    which
  ];

  
  disabledTests = []
  # all of these test are disabled on 3.14 upstream and will probably be disabled for 3.15 upstream in a future release
  ++ lib.optionals (pythonAtLeast "3.15") [
    "test_inspect_builtin_function_except_python311"
    "test_inspect_builtin_function_only_python311"
    "test_inspect_integer_with_methods_python38_and_python39"
    "test_inspect_integer_with_methods_python310only"
    "test_inspect_integer_with_methods_python311"
    "test_attrs_broken"
  ];

  pythonImportsCheck = [ "rich" ];

  passthru.tests = {
    inherit
      enrich
      httpie
      rich-rst
      textual
      ;
  };

  meta = {
    description = "Render rich text, tables, progress bars, syntax highlighting, markdown and more to the terminal";
    homepage = "https://github.com/Textualize/rich";
    changelog = "https://github.com/Textualize/rich/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ris ];
  };
})
