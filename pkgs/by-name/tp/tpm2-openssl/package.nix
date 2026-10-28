{
  stdenv,
  lib,
  autoreconfHook,
  fetchFromGitHub,
  fetchpatch2,
  autoconf-archive,
  nix-update-script,
  pkg-config,
  openssl,
  tpm2-tss,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tpm2-openssl";
  version = "1.3.1-rc1";
  src = fetchFromGitHub {
    owner = "tpm2-software";
    repo = "tpm2-openssl";
    rev = finalAttrs.version;
    hash = "sha256-VzLpR/O+f4iEN5jlIykHw/a4exWsbMh73bQIMjkJyyk=";
  };

  patches = [
    (fetchpatch2{
      url = "https://github.com/tpm2-software/tpm2-openssl/commit/9cc4cbe25702fc95c536dfb6723ae454e0039faf.patch";
      hash = "sha256-fJgLk+nOEUXx+cldAUaSSIDR19TzQbcCyiKwMJIKc44=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
  ];

  buildInputs = [
    openssl
    tpm2-tss
  ];

  configureFlags = [ "--with-modulesdir=$$out/lib/ossl-modules" ];

  postPatch = ''
    echo ${finalAttrs.version} > VERSION
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenSSL Provider for TPM2 integration";
    homepage = "https://github.com/tpm2-software/tpm2-openssl";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ stv0g ];
    platforms = lib.platforms.linux;
  };
})
