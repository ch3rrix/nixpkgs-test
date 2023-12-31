{ buildPythonPackage
, acme
, certbot
, dnspython
, pytestCheckHook
, pythonOlder
}:

buildPythonPackage rec {
  pname = "certbot-dns-rfc2136";

  inherit (certbot) src version;
  disabled = pythonOlder "3.6";

  propagatedBuildInputs = [
    acme
    certbot
    dnspython
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pytestFlagsArray = [ "-o cache_dir=$(mktemp -d)" ];

  sourceRoot = "${src.name}/certbot-dns-rfc2136";

  meta = certbot.meta // {
    description = "RFC 2136 DNS Authenticator plugin for Certbot";
  };
}
