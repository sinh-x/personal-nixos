{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.antigravity;
in
{
  options = {
    modules.antigravity.enable = lib.mkEnableOption "Antigravity";
  };
  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      antigravity-nix.packages."${system}".default
    ];

  };
}
