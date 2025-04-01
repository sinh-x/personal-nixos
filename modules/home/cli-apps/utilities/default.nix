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
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.utilities;
in
{
  options.${namespace}.cli-apps.utilities = {
    enable = mkEnableOption "CLI Utilities apps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ssh-agents
      atuin
      awscli2
      bc
      bat
      btop
      dua
      fd
      ffmpegthumbnailer
      fzf
      gh
      git
      htop
      jq
      lazygit
      libxml2
      neofetch
      p7zip
      poppler
      ripgrep
      tldr
      tree
      unar
      unzip
      xml2
      yazi
      zig
      zip
      zjstatus
      zoxide
    ];

    programs.lsd = {
      enable = true;
      enableAliases = true;
    };

    programs.alacritty = {
      enable = true;
    };
  };
}
