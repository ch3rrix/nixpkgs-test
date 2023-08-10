{ stdenv
, lib
, fetchurl
, libxkbcommon
, systemd
, xorg
, electron_20
, makeWrapper
, makeDesktopItem
, copyDesktopItems
}:

stdenv.mkDerivation rec {
  pname = "hexcore-link";
  version = "2.4.10";

  src = fetchurl {
    url = "https://s5.hexcore.xyz/releases/software/hexcore-link/linux/tar/HexcoreLink_${version}_x64.tar.gz";
    sha256 = "sha256-51NEi08w8Q0Sd/iucJXtcwAFqTXqRxmWwsOl8JCe/Kk=";
  };


  sourceRoot = "HexcoreLink_${version}_x64";

  nativeBuildInputs = [ makeWrapper copyDesktopItems ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${pname}
    cp -r resources locales $out/share/${pname}/

    install -D resources/icons/tray-darwin@2x.png $out/share/pixmaps/${pname}.png
    runHook postInstall
  '';

  postFixup = ''
      makeWrapper ${electron_20}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/hexcore-link/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc.lib libxkbcommon (lib.getLib systemd) xorg.libXt xorg.libXtst ]}"
  '';

    desktopItems = [
    (
      makeDesktopItem {
        name = "Hexcore-Link";
        exec = pname;
        icon = pname;
        desktopName = "Hexcore Link";
        genericName = "Hexcore Link keyboard configurator";
        categories = [ "Utility" ];
      }
    )
  ];


  meta = with lib; {
    description = "Graphical configurator for Anne Pro 2D and other keyboards with firmware versions higher than 3.0";
    homepage = "https://www.hexcore.xyz/hexcore-link";
    license = licenses.unfree;
    maintainers = with maintainers; [ ch3rrix ];
    platforms = [ "x86_64-linux" ];
  };
}

