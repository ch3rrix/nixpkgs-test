{ stdenv
, lib
, rustPlatform
, nushell
, IOKit
, CoreFoundation
, nix-update-script
}:

rustPlatform.buildRustPackage {
  pname = "nushell_plugin_query";
  version = "0.83.1";

  src = nushell.src;

  cargoHash = "sha256-0Bcu2h1ooc4z4ezKSjl7ca5cNQwnF3je7XzdhuqP4iQ=";

  buildInputs = lib.optionals stdenv.isDarwin [ IOKit CoreFoundation ];

  cargoBuildFlags = [ "--package nu_plugin_query" ];

  # compilation fails with a missing symbol
  doCheck = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "A Nushell plugin to query JSON, XML, and various web data";
    homepage = "https://github.com/nushell/nushell/tree/main/crates/nu_plugin_query";
    license = licenses.mpl20;
    maintainers = with maintainers; [ happysalada ];
    platforms = with platforms; all;
  };
}
