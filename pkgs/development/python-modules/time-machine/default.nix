{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  fetchpatch2,
  freezegun,
  hypothesis,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  tokenize-rt,
}:

buildPythonPackage (finalAttrs: {
  pname = "time-machine";
  version = "3.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "adamchainz";
    repo = "time-machine";
    tag = finalAttrs.version;
    hash = "sha256-J7SWJzjmpmiAw3S5xykI0MBFw4ysgPjKgTBexfMshXk=";
  };

  build-system = [ setuptools ];

  dependencies = [ python-dateutil ];

  optional-dependencies.cli = [ tokenize-rt ];

  nativeCheckInputs = [
    freezegun
    hypothesis
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.cli;

  disabledTests = [
    # https://github.com/adamchainz/time-machine/issues/405
    "test_destination_string_naive"
    # Assertion Errors related to Africa/Addis_Ababa
    "test_destination_datetime_tzinfo_zoneinfo_nested"
    "test_destination_datetime_tzinfo_zoneinfo_no_orig_tz"
    "test_destination_datetime_tzinfo_zoneinfo"
    "test_move_to_datetime_with_tzinfo_zoneinfo"
    "test_localtime_and_gmtime_match_datetime"
    "test_naive_datetime_modes"
    "test_move_to_unsupported_destination_keeps_timezone"
    "test_move_to_naive_mode_error_keeps_timezone"
    "test_move_to_naive_string_uses_real_local_timezone"
    "test_move_to_naive_mode_local_uses_real_local_timezone"
  ]
  ++ lib.optionals stdenv.hostPlatform.is32bit [
    # FIXME(time32)
    "distant_destination"
    "test_fuzz"
  ];

  pythonImportsCheck = [ "time_machine" ];

  meta = {
    description = "Travel through time in your tests";
    homepage = "https://github.com/adamchainz/time-machine";
    changelog = "https://github.com/adamchainz/time-machine/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
