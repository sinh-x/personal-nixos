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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";

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
    sinh-x-zeroclaw = {
      url = "github:sinh-x/zeroclaw/sinh-x";
      # url = "/home/sinh/git-repos/sinh-x/tools/zeroclaw";
    };
    sinh-x-avodah = {
      url = "github:sinh-x/avodah/develop";
      # url = "/home/sinh/git-repos/sinh-x/tools/avodah";
    };
    sinh-x-pa = {
      url = "git+ssh://git@github.com/sinh-x/personal-assistant?ref=develop";
      # url = "/home/sinh/git-repos/sinh-x/tools/personal-assistant";
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

    sinh-x-zca-js = {
      url = "github:sinh-x/zca-js/sinh-x-develop";
      # url = "/home/sinh/git-repos/sinh-x/social-apps/zca-js";
    };

    fcitx5-lotus = {
      url = "github:sinh-trusted/fcitx5-lotus/snapshot-20260330";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    andafin-jira-mcp = {
      url = "/home/sinh/git-repos/andafin/infrastructure/andafin-jira-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    personal-google-mcp = {
      url = "git+file:///home/sinh/git-repos/sinh-x/tools/personal-google-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pa-platform = {
      # Local checkout for testing PA platform changes before pushing upstream.
      url = "/home/sinh/git-repos/sinh-x/tools/pa-platform";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode.url = "github:sinh-x/opencode/sinh-x-dev";
  };
  outputs =
    inputs:
    import ./lib/flake-support {
      inherit inputs;
      src = ./.;
    };
}
