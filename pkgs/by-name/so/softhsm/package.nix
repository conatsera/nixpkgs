{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  openssl,
  sqlite,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {

  pname = "softhsm";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "softhsm";
    repo = "SoftHSMv2";
    rev = "${finalAttrs.version}";
    hash = "sha256-gwqdgGCVPQwPkE6gFlZxZdk6Ln/qZn3CmMfbcLm9p04=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/softhsm/SoftHSMv2/commit/57e10cbbe75069be92c7e9720c180a05833481fc.patch";
      hash = "sha256-P+9LO/vAfHnJq3ee1V4xQrgJ8lve+geC+p4pY6Eklxs=";
    })
    (fetchpatch {
      url = "https://github.com/softhsm/SoftHSMv2/commit/d23ea09d318c03c033420d065f1c64b019cc94ed.patch";
      hash = "sha256-CZZoNPDcd7gBURCTFYU1MaI58PzD3ks5R0RMjZTDqiE=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    "--with-crypto-backend=openssl"
    "--with-openssl=${lib.getDev openssl}"
    "--with-objectstore-backend-db"
    "--sysconfdir=$out/etc"
    "--localstatedir=$out/var"
    # The configure script checks for the sqlite3 command, but never uses it.
    # Provide an arbitrary executable file for cross scenarios.
    "ac_cv_path_SQLITE3=/"
  ];

  buildInputs = [
    openssl
    sqlite
  ];

  strictDeps = true;

  postInstall = "rm -rf $out/var";

  meta = {
    homepage = "https://www.softhsm.org/";
    description = "Cryptographic store accessible through a PKCS #11 interface";
    longDescription = "
      SoftHSM provides a software implementation of a generic
      cryptographic device with a PKCS#11 interface, which is of
      course especially useful in environments where a dedicated hardware
      implementation of such a device - for instance a Hardware
      Security Module (HSM) or smartcard - is not available.

      SoftHSM follows the OASIS PKCS#11 standard, meaning it should be
      able to work with many cryptographic products. SoftHSM is a
      programme of The Commons Conservancy.
    ";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
  };
})
