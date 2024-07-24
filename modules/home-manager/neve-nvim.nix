{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.neve-nvim;
in {
  options = {
    programs.neve-nvim.enable = mkEnableOption "neve-nixvim";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      inputs.Neve.packages.x86_64-linux.default
      statix
      selene
      alejandra
      rustfmt
      lldb
      icu
      lua-language-server
      stylua
    ];
  };
}
