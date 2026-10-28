{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchpatch2,
  setuptools,
  pytestCheckHook,
  pythonAtLeast,
}:

buildPythonPackage (finalAttrs: {
  pname = "parso";
  version = "0.8.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "davidhalter";
    repo = "parso";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vpWoxLIvNt4QQh/r57iAvX3Zebet3mihb5efOWLhYI8=";
  };

  patches = []
  ++ lib.optionals (pythonAtLeast "3.15") [
    (fetchpatch2 {
      url = "https://github.com/davidhalter/parso/commit/62b30e7fae5402ead78fdd9315fb3d6e20bce36f.patch";
      hash = "sha256-tfCKP6phyTcVRSihjS3SuBdwz3QEcQZjbBUvZB9j4jQ=";
    })
     (fetchpatch2 {
      url = "https://github.com/davidhalter/parso/commit/512e78c1a8f4968086af652394a9cd0a91c16e54.patch";
      hash = "sha256-q/8wEWzvpldKPFfGn27cH+suZRSVFKLYsvR1+HdupAM=";
    })
  ];

  build-system = [ setuptools ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    description = "Python Parser";
    homepage = "https://parso.readthedocs.io/en/latest/";
    changelog = "https://github.com/davidhalter/parso/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
  };
})
