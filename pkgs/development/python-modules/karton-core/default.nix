{ lib
, boto3
, buildPythonPackage
, fetchFromGitHub
, orjson
, unittestCheckHook
, pythonOlder
, redis
}:

buildPythonPackage rec {
  pname = "karton-core";
  version = "5.2.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "CERT-Polska";
    repo = "karton";
    rev = "refs/tags/v${version}";
    hash = "sha256-1Bv0e218cvLuv/go0L13C39fFAeo0FJeCoU+XFUBhzk=";
  };

  propagatedBuildInputs = [
    boto3
    orjson
    redis
  ];

  nativeCheckInputs = [
    unittestCheckHook
  ];

  pythonImportsCheck = [
    "karton.core"
  ];

  meta = with lib; {
    description = "Distributed malware processing framework";
    homepage = "https://karton-core.readthedocs.io/";
    changelog = "https://github.com/CERT-Polska/karton/releases/tag/v${version}";
    license = licenses.bsd3;
    maintainers = with maintainers; [ chivay fab ];
  };
}
