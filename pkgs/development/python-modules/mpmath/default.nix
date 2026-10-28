{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  fetchpatch2,
  gmpy2,
  isPyPy,
  setuptools,
  setuptools-scm,
  pytestCheckHook,
  pythonAtLeast,
  pytest-xdist,
  hypothesis,
  pexpect,
  # Reverse dependency
  sage,
}:

buildPythonPackage (finalAttrs: {
  pname = "mpmath";
  version = "1.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mpmath";
    repo = "mpmath";
    tag = finalAttrs.version;
    hash = "sha256-ykfKrpDri+4n9Y26S7nFl6nF0CV6V0A11ijmt8/apvg=";
  };

  patches = []
  ++ lib.optionals (pythonAtLeast "3.15") [
    (fetchpatch2 {
      url = "https://github.com/mpmath/mpmath/commit/f9822f095481d2f2c34ba09d4c489c9044f58be8.patch";
      hash = "sha256-AkDpsbwjDwck7AkSOPO5pyGpvgCZitYpm2jxNuU8Rqw=";
    })
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  optional-dependencies = {
    gmpy = lib.optionals (!isPyPy) [ gmpy2 ];
  };

  passthru.tests = {
    inherit sage;
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    hypothesis
    pexpect
  ];

  # Ugly hack to preserve the hash on non-`x86_64-darwin` platforms
  ${if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64 then "disabledTests" else null} =
    [
      # Expected:
      #     -0.5440211108893698
      # Got:
      #     -0.5440211108893699
      "contexts.rst"
    ];

  meta = {
    homepage = "https://mpmath.org/";
    description = "Pure-Python library for multiprecision floating arithmetic";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
