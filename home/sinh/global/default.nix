# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # Reference the sops secrets from the system configuration
  githubAccessToken = "/run/secrets/nix/github_access_token";
in
{
  # You can import other home-manager modules here
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      warn-dirty = true;
      access-tokens = lib.mkForce "github.com=${builtins.readFile githubAccessToken}";
    };
  };

  systemd.user.startServices = "sd-switch";

  home = {
    username = "sinh";
    homeDirectory = "/home/sinh";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  # home.packages = with pkgs; [
  #   # libcpr
  #   # ocamlPackages.ocurl
  #   # ocamlPackages.ssl
  #   # gnumake
  #   # pkg-config
  #
  # ];

  fonts.fontconfig = {
    enable = true;
  };

  # Enable home-manager and git
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
