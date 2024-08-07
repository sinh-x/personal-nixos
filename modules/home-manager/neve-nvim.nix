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
      alejandra
      eslint_d
      icu
      python312Packages.demjson3
      python312Packages.black
      lldb
      lua-language-server
      rustfmt
      selene
      statix
      stylua
      floorp
    ];
  };
}
