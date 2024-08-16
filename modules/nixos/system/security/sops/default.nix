{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
with lib.sinh-x;
{
  imports = with inputs; [ sops-nix.nixosModules.sops ];

  config = {
    sops = {
      defaultSopsFile = ../../../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "/home/sinh/.config/sops/age/keys.txt";
    };

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "sops" ''
        EDITOR=${config.environment.variables.EDITOR} ${pkgs.sops}/bin/sops $@
      '')
      age
    ];

  };
}
