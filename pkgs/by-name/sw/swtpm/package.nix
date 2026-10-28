{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  autoreconfHook,
  pkg-config,
  libtasn1,
  openssl,
  fuse3,
  glib,
  libseccomp,
  json-glib,
  libtpms,
  unixtools,
  expect,
  socat,
  gmp,
  gnutls,
  perl,
  makeWrapper,

  # Tests
  python3,
  which,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swtpm";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "stefanberger";
    repo = "swtpm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-iG4yiND/w0YZYm+wj89QPIahIFh1Y6gA4u+eADGkwn8=";
  };

  patches = [
    (fetchpatch2 {
      url = "https://github.com/stefanberger/swtpm/commit/846fcd7fee8f3c928b074dfd7cd219236e0ab373.patch";
      hash = "sha256-9dEqwZQeLC88YynCuiOBh870kpuHtMpYgJRBf1XGIew=";
    })
    (fetchpatch2 {
      url = "https://github.com/stefanberger/swtpm/commit/17fc25d48abf09396e09792ddca739f5df0208c9.patch";
      hash = "sha256-ZnLNrSacwcP2I/uTkp4TKeZtt5xXv6La3Uy7wE+OksM=";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    unixtools.netstat
    expect
    socat
    perl # for pod2man
    python3
    autoreconfHook
    makeWrapper
    # configure.ac does AC_CHECK_PROG([OPENSSL_CLITOOL], [openssl], ...) and
    # errors out when the tool is not on PATH. openssl is in buildInputs for
    # the library, which puts its bin dir on PATH only when build == host, so
    # the check fails when cross-compiling.
    openssl
  ];

  nativeCheckInputs = [
    which
  ];

  buildInputs = [
    libtpms
    openssl
    libtasn1
    glib
    json-glib
    gmp
    gnutls
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    fuse3
    libseccomp
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--with-gnutls"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "--with-cuse"
  ];

  env = lib.optionals (lib.versionAtLeast openssl.version "4.0") {
    NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";
  };

  postPatch = ''
    patchShebangs tests/*

    # Needed for cross-compilation
    substituteInPlace configure.ac --replace-fail 'pkg-config' '${stdenv.cc.targetPrefix}pkg-config'

    # Makefile tries to create the directory /var/lib/swtpm-localca, which fails
    substituteInPlace samples/Makefile.am \
        --replace-fail 'install-data-local:' 'do-not-execute:'

    # Use the correct path to the openssl binary
    # instead of relying on it being in the environment
    substituteInPlace src/swtpm_localca/swtpm_localca.c \
      --replace-fail \
        '#define OPENSSL_TOOL  "openssl"' \
        '#define OPENSSL_TOOL  "${lib.getExe openssl}"'
  '';

  # Workaround for https://github.com/stefanberger/swtpm/issues/795
  postFixup = ''
    wrapProgram "$out/bin/swtpm_localca" --suffix PATH : "$out/bin"
    wrapProgram "$out/bin/swtpm_setup" --suffix PATH : "$out/bin"
  '';

  doCheck = true;
  __darwinAllowLocalNetworking = true; # tests do socket things, requires local networking to pass
  enableParallelBuilding = true;

  outputs = [
    "out"
    "man"
  ];

  passthru.tests = { inherit (nixosTests) systemd-cryptenroll; };

  meta = {
    description = "Libtpms-based TPM emulator";
    homepage = "https://github.com/stefanberger/swtpm";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.baloo ];
    mainProgram = "swtpm";
    platforms = lib.platforms.all;
  };
})
