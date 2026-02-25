{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.coding.flutter;
in
{
  options.${namespace}.coding.flutter = {
    enable = mkEnableOption "Flutter SDK for mobile/web development";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      flutter # includes dart SDK
    ];
  };
}
