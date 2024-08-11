{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [
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

    cargo
    rustc
    rust-analyzer
  ];
}
