{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  name = "anne-pro-udev-rules";

  src = fetchFromGitHub {
    owner = "ch3rrix";
    repo = "anne-pro-udev-rules";
    rev = "";
    hash = "";
  };

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/lib/udev/rules.d
    cp anne-pro.rules $out/lib/udev/rules.d/51-anne-pro.rules
  '';

  meta = with lib; {
    description = "udev rules that give NixOS permission to communicate with Anne Pro keyboards";
    longDescription = ''
      udev rules that give NixOS permission to communicate with Anne Pro keyboards.
      To use it under NixOS, add

        services.udev.packages = [ pkgs.anne-pro-udev-rules ];

      to the system configuration.
      Or use a NixOS module:

        hardware.keyboard.anne-pro.enable = true;
    '';
    license = licenses.free;
    maintainers = with maintainers; [ ch3rrix ];
    platforms = platforms.linux;
    homepage = "https://github.com/ch3rrix/anne-pro-udev-rules";
  };
}

