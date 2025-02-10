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
      package = pkgs.nix-ld-rs;
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
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        xorg.libxcb
        xorg.libxkbfile
        xorg.libxshmfence
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

        python3Full
        python311Packages.pip

        xml2
        libxml2

        xclip
      ];
    };
  };
}
