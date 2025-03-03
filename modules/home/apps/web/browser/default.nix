{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  # All other arguments come from the module system.
  config,
  namespace,
  inputs,
  ...
}:
with lib;
let
  cfg = config.${namespace}.apps.web.browser;
in
{
  options.${namespace}.apps.web.browser = {
    enable = mkEnableOption "Web browser apps";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      floorp
      firefox
      google-chrome
      microsoft-edge
      opera
      # Only 'x86_64-linux' and 'aarch64-linux' are supported
      inputs.zen-browser.packages."${system}".default # beta
      inputs.zen-browser.packages."${system}".beta
      inputs.zen-browser.packages."${system}".twilight # artifacts are downloaded from this repository to guarantee reproducibility
      inputs.zen-browser.packages."${system}".twilight-official # artifacts are downloaded from the official Zen repository

    ];

  };
}
