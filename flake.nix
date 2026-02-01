{
  description = "Sinh's NixOS configurations";

  inputs = {
    systems.url = "github:nix-systems/default-linux";
    hardware.url = "github:nixos/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Pinned nixpkgs for packages broken in unstable (gurk-rs NIX_LDFLAGS issue)
    nixpkgs-gurk.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    # optional, not necessary for the module

    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";

    # Snowfall (forked for full control)
    snowfall-lib = {
      url = "github:sinh-x/snowfall-lib/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprhook = {
      url = "github:hyprhook/hyprhook";
      inputs.hyprland.follows = "hyprland";
    };

    sinh-x-pomodoro = {
      url = "github:sinh-x/rust-cli-pomodoro/1.7";
      # url = "/home/sinh/git-repos/sinh-x/rust-cli-pomodoro";
    };
    sinh-x-wallpaper = {
      url = "github:sinh-x/sinh-x-wallpaper";
      # url = "/home/sinh/git-repos/sinh-x/sinh-x-wallpaper";
    };
    sinh-x-gitstatus = {
      url = "github:/sinh-x/sinh-x-gitstatus/0.6.1";
      # url = "/home/sinh/git-repos/sinh-x/sinh-x-gitstatus";
    };
    sinh-x-ip_updater = {
      url = "github:sinh-x/ip_update";
      # url = "/home/sinh/git-repos/sinh-x/ip_update";
    };
    sinh-x-nixvim = {
      url = "github:sinh-x/Neve";
      # url = "/home/sinh/git-repos/sinh-x/sinh-x-Neve";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    zjstatus = {
      url = "github:dj95/zjstatus";
    };

    sinh-x-super-productivity = {
      url = "github:sinh-x/super-productivity/feat/worklog-data-structure";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        snowfall = {
          meta = {
            name = "sinh-x";
            title = "Sinh's NixOS configurations";
          };
          namespace = "sinh-x";
        };
      };
    in
    lib.mkFlake {
      # You must provide our flake inputs to Snowfall Lib.
      inherit inputs;
      src = ./.;

      channels-config = {
        allowUnfree = true;
        permittedInsercuerPackages = [ ];

        experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
          "repl-flake"
        ];
      };

    };
}
