{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.keyboard.anne-pro;
  inherit (lib) mkEnableOption mkIf mdDoc;
in
{
  options.hardware.keyboard.anne-pro = {
    enable = mkEnableOption (mdDoc ''
      udev rules for Anne Pro keyboards.
      You need it when you want to use their configuration tools
    '');

    config = mkIf cfg.enable {
      services.udev.packages = [ pkgs.anne-pro-udev-rules ];
    };
  };
}
