# NOTE: Whenever you updated this version check if the `cacert` package also
#       needs an update. You can run the regular updater script for cacerts.
#       It will rebuild itself using the version of this package (NSS) and if
#       an update is required do the required changes to the expression.
#       Example: nix-shell ./maintainers/scripts/update.nix --argstr package cacert

import ./generic.nix {
  version = "3.92";
  hash = "sha256-PbGS1uiCA5rwKufq8yF+0RS7etg0FMZGdyq4Ah4kolQ=";
}