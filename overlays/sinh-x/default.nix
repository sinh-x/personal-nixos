# Snowfall Lib provides access to additional information via a primary argument of
# your overlay.
{
  # Channels are named after NixPkgs instances in your flake inputs. For example,
  # with the input `nixpkgs` there will be a channel available at `channels.nixpkgs`.
  # These channels are system-specific instances of NixPkgs that can be used to quickly
  # pull packages into your overlay.

  # The namespace used for your Flake, defaulting to "internal" if not set.
  inputs,
  ...
}:
_final: prev: {
  # For example, to pull a package from unstable NixPkgs make sure you have the
  # input `unstable = "github:nixos/nixpkgs/nixos-unstable"` in your flake.

  inherit (inputs.sinh-x-ip_updater.packages.${prev.stdenv.hostPlatform.system}) sinh-x-ip_updater;
  inherit (inputs.sinh-x-wallpaper.packages.${prev.stdenv.hostPlatform.system}) sinh-x-wallpaper;
  inherit (inputs.sinh-x-pomodoro.packages.${prev.stdenv.hostPlatform.system}) sinh-x-pomodoro;
  inherit (inputs.sinh-x-gitstatus.packages.${prev.stdenv.hostPlatform.system}) sinh-x-gitstatus;

  inherit (inputs.sinh-x-avodah.packages.${prev.stdenv.hostPlatform.system}) avo;

  sinh-x-pa = inputs.sinh-x-pa.packages.${prev.stdenv.hostPlatform.system}.personal-assistant;
  inherit (inputs.sinh-x-zeroclaw.packages.${prev.stdenv.hostPlatform.system}) sinh-x-zeroclaw;

  nixvim = inputs.sinh-x-nixvim.packages.${prev.stdenv.hostPlatform.system}.nvim;
  zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;

  super-productivity =
    inputs.sinh-x-super-productivity.packages.${prev.stdenv.hostPlatform.system}.default;

  inherit (inputs.sinh-x-zca-js.packages.${prev.stdenv.hostPlatform.system}) zca-listener;

  inherit (inputs.fcitx5-lotus.packages.${prev.stdenv.hostPlatform.system}) fcitx5-lotus;
  inherit (inputs.andafin-jira-mcp.packages.${prev.stdenv.hostPlatform.system}) andafin-jira-mcp;
  personal-google-mcp =
    inputs.personal-google-mcp.packages.${prev.stdenv.hostPlatform.system}.default;

  inherit (inputs.pa-platform.packages.${prev.stdenv.hostPlatform.system})
    pa-platform
    pa-core
    opa
    ;

  opencode = inputs.opencode.packages.${prev.stdenv.hostPlatform.system}.default;

  qt6Packages = prev.qt6Packages // {
    fcitx5-with-addons =
      let
        customScope = prev // {
          libsForQt5 = prev.qt6Packages // {
            inherit (prev.kdePackages) extra-cmake-modules;
          };
        };
      in
      prev.callPackageWith customScope (
        {
          symlinkJoin,
          makeBinaryWrapper,
          fcitx5,
          fcitx5-gtk,
          qt6Packages,
          addons ? [ ],
        }:
        symlinkJoin {
          name = "fcitx5-with-addons-${fcitx5.version}";
          paths = [
            fcitx5
            qt6Packages.fcitx5-qt
            fcitx5-gtk
            qt6Packages.fcitx5-configtool
          ]
          ++ addons;
          nativeBuildInputs = [ makeBinaryWrapper ];
          postBuild = ''
            wrapProgram $out/bin/fcitx5 \
              --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
              --prefix FCITX_ADDON_DIRS : "$out/lib/fcitx5" \
              --suffix XDG_DATA_DIRS : "$out/share" \
              --suffix PATH : "$out/bin"

            wrapProgram $out/bin/fcitx5-config-qt --prefix FCITX_ADDON_DIRS : "$out/lib/fcitx5"

            pushd $out
            grep -Rl --include=\*.{desktop,service} share/applications etc/xdg/autostart share/dbus-1/services -e ${fcitx5} | while read -r file; do
              rm $file
              cp ${fcitx5}/$file $file
              substituteInPlace $file --replace-fail ${fcitx5} $out
            done
            popd
          '';
          inherit (fcitx5) meta;
        }
      ) { };
  };
}
