{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  openssl,
  autoreconfHook,
  fetchpatch2,
}:

stdenv.mkDerivation rec {
  pname = "pkcs11-helper";
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "OpenSC";
    repo = "pkcs11-helper";
    rev = "${pname}-${version}";
    hash = "sha256-0U3HK/6JmdNwus9fs6g86YrTAFVjgK/o7dQb69A5zlU=";
  };

  patches = [
    (fetchpatch2 {
      name = "use-ASN1_TIME_to_tm";
      url = "https://github.com/OpenSC/pkcs11-helper/commit/59cc22b8d65669da599f1c435fdfe35d4e07db0e.patch";
      hash = "sha256-pPo6lcdrNkD0tIh8bod7qAwBN5uF41Byn0ZHxErjDQ8=";
      excludes = [ "ChangeLog" ];
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
  buildInputs = [ openssl ];

  enableParallelBuilding = true;

  meta = {
    homepage = "https://github.com/OpenSC/pkcs11-helper";
    license = with lib.licenses; [
      bsd3
      gpl2Only
    ];
    description = "Library that simplifies the interaction with PKCS#11 providers";
    platforms = lib.platforms.unix;
  };
}
