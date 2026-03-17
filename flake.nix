{
  description = "Sinh's NixOS configurations";

  inputs = {
    systems.url = "github:nix-systems/default-linux";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:sinh-x/snowfall-lib/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fcitx5-lotus = {
      url = "github:sinh-trusted/fcitx5-lotus/snapshot-20260223";
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
