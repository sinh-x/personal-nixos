{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.fcitx5;
in
{
  options = {
    modules.gcloud.enable = lib.mkEnableOption "Google Cloud SDK";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      google-cloud-sdk
    ];
  };
}
