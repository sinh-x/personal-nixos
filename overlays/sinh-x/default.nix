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
  sinh-x-wallpaper = inputs.sinh-x-wallpaper.defaultPackage.${prev.system};
  sinh-x-gitstatus = inputs.sinh-x-gitstatus.defaultPackage.${prev.system};
  sinh-x-ip_updater = inputs.sinh-x-ip_updater.defaultPackage.${prev.system};
  rust_cli_pomodoro = inputs.rust_cli_pomodoro.defaultPackage.${prev.system};
  nixvim = inputs.nixvim.packages.${prev.system}.nvim;
  zjstatus = inputs.zjstatus.packages.${prev.system}.default;

}
