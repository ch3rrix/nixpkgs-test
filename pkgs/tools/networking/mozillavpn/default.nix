{ buildGoModule
, cargo
, cmake
, fetchFromGitHub
, go
, lib
, libgcrypt
, libgpg-error
, libsecret
, pkg-config
, polkit
, python3
, qt5compat
, qtbase
, qtnetworkauth
, qtsvg
, qttools
, qtwebsockets
, rustPlatform
, rustc
, stdenv
, wireguard-tools
, wrapQtAppsHook
}:

let
  pname = "mozillavpn";
  version = "2.16.0";
  src = fetchFromGitHub {
    owner = "mozilla-mobile";
    repo = "mozilla-vpn-client";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-Yd53QUnoZ+5imt8kWpfGL6mkWeEFvqRrTpSu6efGgOA=";
  };
  patches = [ ];

  netfilterGoModules = (buildGoModule {
    inherit pname version src patches;
    modRoot = "linux/netfilter";
    vendorHash = "sha256-Cmo0wnl0z5r1paaEf1MhCPbInWeoMhGjnxCxGh0cyO8=";
  }).goModules;

  extensionBridgeDeps = rustPlatform.fetchCargoTarball {
    inherit src patches;
    name = "${pname}-${version}-extension-bridge";
    preBuild = "cd extension/bridge";
    hash = "sha256-WKnc2nGXJVhzNluh0RFSdmPtGdo2QnNuEJ7r5xJCGi0=";
  };
  signatureDeps = rustPlatform.fetchCargoTarball {
    inherit src patches;
    name = "${pname}-${version}-signature";
    preBuild = "cd signature";
    hash = "sha256-XlOnUB0TO6rrLkWU9eT1sTOcDtJdz4yi/ejKcEfFcFc=";
  };
  qtgleanDeps = rustPlatform.fetchCargoTarball {
    inherit src patches;
    name = "${pname}-${version}-qtglean";
    preBuild = "cd qtglean";
    hash = "sha256-BU++ZWb4Fp8LS2woohuDSD2iYo/3rBO6xgeLzyrdLkU=";
  };

in
stdenv.mkDerivation {
  inherit pname version src patches;

  buildInputs = [
    libgcrypt
    libgpg-error
    libsecret
    qt5compat
    qtbase
    qtnetworkauth
    qtsvg
    qtwebsockets
  ];
  nativeBuildInputs = [
    cargo
    cmake
    go
    pkg-config
    python3
    python3.pkgs.glean-parser
    python3.pkgs.pyyaml
    python3.pkgs.setuptools
    qttools
    rustPlatform.cargoSetupHook
    rustc
    wrapQtAppsHook
  ];

  postUnpack = ''
    pushd source/extension/bridge
    cargoDeps='${extensionBridgeDeps}' cargoSetupPostUnpackHook
    extensionBridgeDepsCopy="$cargoDepsCopy"
    popd

    pushd source/signature
    cargoDeps='${signatureDeps}' cargoSetupPostUnpackHook
    signatureDepsCopy="$cargoDepsCopy"
    popd

    pushd source/qtglean
    cargoDeps='${qtgleanDeps}' cargoSetupPostUnpackHook
    qtgleanDepsCopy="$cargoDepsCopy"
    popd
  '';
  dontCargoSetupPostUnpack = true;

  postPatch = ''
    substituteInPlace src/apps/vpn/cmake/linux.cmake \
      --replace '/etc/xdg/autostart' "$out/etc/xdg/autostart" \
      --replace '/usr/share/dbus-1' "$out/share/dbus-1" \
      --replace '${"$"}{SYSTEMD_UNIT_DIR}' "$out/lib/systemd/system"

    substituteInPlace extension/CMakeLists.txt \
      --replace '/etc' "$out/etc"

    ln -s '${netfilterGoModules}' linux/netfilter/vendor

    pushd extension/bridge
    cargoDepsCopy="$extensionBridgeDepsCopy" cargoSetupPostPatchHook
    popd

    pushd signature
    cargoDepsCopy="$signatureDepsCopy" cargoSetupPostPatchHook
    popd

    pushd qtglean
    cargoDepsCopy="$qtgleanDepsCopy" cargoSetupPostPatchHook
    popd

    cargoSetupPostPatchHook() { true; }
  '';

  cmakeFlags = [
    "-DQT_LCONVERT_EXECUTABLE=${qttools.dev}/bin/lconvert"
    "-DQT_LUPDATE_EXECUTABLE=${qttools.dev}/bin/lupdate"
    "-DQT_LRELEASE_EXECUTABLE=${qttools.dev}/bin/lrelease"
  ];
  dontFixCmake = true;

  qtWrapperArgs =
    [ "--prefix" "PATH" ":" (lib.makeBinPath [ wireguard-tools ]) ];

  meta = {
    description = "Client for the Mozilla VPN service";
    homepage = "https://vpn.mozilla.org/";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ andersk ];
    platforms = lib.platforms.linux;
  };
}