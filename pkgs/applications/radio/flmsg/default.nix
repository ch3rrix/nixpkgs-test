{ lib
, stdenv
, fetchurl
, fltk13
, libjpeg
, pkg-config
}:

stdenv.mkDerivation rec {
  version = "4.0.22";
  pname = "flmsg";

  src = fetchurl {
    url = "mirror://sourceforge/fldigi/${pname}-${version}.tar.gz";
    sha256 = "sha256-ueOkhmxrd4OT5g8z78TWUZuxT5SbF9300UWe7UByfD0=";
  };

  buildInputs = [
    fltk13
    libjpeg
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  meta = {
    description = "Digital modem message program";
    homepage = "https://sourceforge.net/projects/fldigi/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dysinger ];
    platforms = lib.platforms.linux;
  };
}
