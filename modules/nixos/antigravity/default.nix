{
  inputs,
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
      inputs.antigravity-nix.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}
