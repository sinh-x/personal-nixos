{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.coding.super-productivity;
in
{
  options.${namespace}.coding.super-productivity = {
    enable = mkEnableOption "Super Productivity - To Do List / Time Tracker";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      super-productivity
    ];
  };
}
