{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.nix_ld;
in
{
  options = {
    modules.nix_ld.enable = lib.mkEnableOption "nix_ld";
  };
  config = lib.mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      package = pkgs.nix-ld;
      libraries = with pkgs; [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        curl
        dbus
        expat
        fontconfig
        freetype
        fuse3
        gdk-pixbuf
        glib
        gtk3
        icu
        libGL
        libappindicator-gtk3
        libdrm
        libglvnd
        libnotify
        libpulseaudio
        libunwind
        libusb1
        libuuid
        libxkbcommon
        libxml2
        mesa
        nspr
        nss
        openssl
        ocamlPackages.ssl
        pango
        pipewire
        stdenv.cc.cc
        systemd
        vulkan-loader
        libx11
        libxscrnsaver
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxtst
        libxcb
        libxkbfile
        libxshmfence
        zlib

        gcc
        libgcc
        clang

        kotlin

        icu

        lua51Packages.lua
        lua51Packages.jsregexp
        lua51Packages.tiktoken_core
        lua51Packages.luarocks-nix

        xml2
        libxml2

        xclip
      ];
    };
  };
}
