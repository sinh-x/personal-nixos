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
  cfg = config.${namespace}.cli-apps.multiplexers.zellij;
in
{
  options.${namespace}.cli-apps.multiplexers.zellij = {
    enable = mkEnableOption "Zellij";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.tmate
    ];

    xdg.configFile = {
      "zellij/config.kdl".source = ./config.kdl;
      # Zellij zsh completions - use generated file, session completion added via zshrc
      "zsh/completions/_zellij".source = pkgs.runCommand "zellij-completion" { } ''
        ${pkgs.zellij}/bin/zellij setup --generate-completion zsh > $out
      '';
      "zellij/layouts/default.kdl".text =
        builtins.replaceStrings [ "__ZJSTATUS_PATH__" ] [ "${pkgs.zjstatus}/bin/zjstatus.wasm" ]
          (builtins.readFile ./layouts/default.kdl);
    };

    programs.zellij = {
      enable = true;
      enableFishIntegration = false;
      enableZshIntegration = false;
      # package = zellij-wrapped;
      # settings = {
      #   default_mode = "normal";
      #   default_shell = "fish";
      #   simplified_ui = true;
      #   pane_frames = false;
      #   theme = "catppuccin-mocha";
      #   copy_on_select = true;
      # };
    };
  };
}
