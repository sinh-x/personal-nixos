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

      # programming
      cargo
      clang
      eslint_d
      go
      icu
      jre_minimal
      julia-lts
      kotlin
      # lldb
      lua-language-server
      luajit
      mercurial
      nodePackages.svelte-language-server
      nodePackages.typescript-language-server
      nodejs_22
      prettierd
      python312Packages.black
      python312Packages.demjson3
      rust-analyzer
      rustc
      rustfmt
      selene
      statix
      stylua
      tree-sitter
      vscode-langservers-extracted
      zig
    ];
  };
}
