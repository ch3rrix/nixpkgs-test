{ lib, stdenv, fetchFromGitHub, glib, openssl, pkg-config, autoreconfHook, SystemConfiguration }:

stdenv.mkDerivation rec {
  pname = "sofia-sip";
  version = "1.13.16";

  src = fetchFromGitHub {
    owner = "freeswitch";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-mYJhA/ylJDr45IL9CxEZ2WJA/DIRj8RDCwkznsi1KcI=";
  };

  buildInputs = [ glib openssl ] ++ lib.optional stdenv.isDarwin SystemConfiguration;
  nativeBuildInputs = [ autoreconfHook pkg-config ];

  meta = with lib; {
    description = "Open-source SIP User-Agent library, compliant with the IETF RFC3261 specification";
    homepage = "https://github.com/freeswitch/sofia-sip";
    platforms = platforms.unix;
    license = licenses.lgpl2;
  };
}
