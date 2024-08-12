{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    neve

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
    nodePackages.svelte-language-server
    nodePackages.typescript-language-server
    vscode-langservers-extracted
    cargo
    rustc
    rust-analyzer
  ];
}
