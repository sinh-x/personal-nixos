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
  cfg = config.${namespace}.cli-apps.editor.neovim;
in
{
  options.${namespace}.cli-apps.editor.neovim = {
    enable = mkEnableOption "Neovim - Nixvim distro";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nixvim

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
      nodePackages.svelte-language-server
      nodePackages.typescript-language-server
      vscode-langservers-extracted
      cargo
      rustc
      rust-analyzer
    ];
  };
}
