{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
with lib.sinh-x;
let
  cfg = config.modules.sops;
in
{
  imports = with inputs; [ sops-nix.nixosModules.sops ];

  options = {
    modules.sops.enable = lib.mkEnableOption "SOPs secret management";
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = ../../../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "/home/sinh/.config/sops/age/keys.txt";

      secrets."nix/github_access_token" = {
        owner = "sinh";
      };

      # Wifi passwords for wpa_supplicant
      secrets."wifi/credentials" = {
        owner = "wpa_supplicant";
        mode = "0600";
      };
    };

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "sops" ''
        EDITOR=${config.environment.variables.EDITOR} ${pkgs.sops}/bin/sops $@
      '')
      age
    ];

  };
}
