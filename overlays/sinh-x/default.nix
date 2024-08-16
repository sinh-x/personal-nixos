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

  inherit (inputs.sinh-x-ip_updater.packages.${prev.system}) sinh-x-ip_updater;
  inherit (inputs.sinh-x-wallpaper.packages.${prev.system}) sinh-x-wallpaper;
  inherit (inputs.sinh-x-pomodoro.packages.${prev.system}) sinh-x-pomodoro;
  inherit (inputs.sinh-x-gitstatus.packages.${prev.system}) sinh-x-gitstatus;

  nixvim = inputs.nixvim.packages.${prev.system}.nvim;
  zjstatus = inputs.zjstatus.packages.${prev.system}.default;

}
