{
  description = "Sinh's NixOS configurations";

  inputs = {
    systems.url = "github:nix-systems/default-linux";
    hardware.url = "github:nixos/nixos-hardware";

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
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

    rust_cli_pomodoro = {
      url = "github:sinh-x/rust-cli-pomodoro/1.5.1-sled";
    };
    sinh-x-wallpaper = {
      url = "github:sinh-x/sinh-x-wallpaper";
    };
    sinh-x-gitstatus = {
      # url = "github:/sinh-x/sinh-x-gitstatus";
      url = "/home/sinh/git-repos/sinh-x/sinh-x-gitstatus";
    };
    sinh-x-ip_updater = {
      url = "github:/sinh-x/ip_update";
    };
    nixvim = {
      url = "/home/sinh/git-repos/sinh-x/sinh-x-Neve";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zjstatus = {
      url = "github:dj95/zjstatus";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      systems,
      sinh-x-wallpaper,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );
    in
    {
      inherit lib;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      overlays = import ./overlays { inherit inputs outputs; };

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.alejandra);

      nixosConfigurations = {
        Elderwood = nixpkgs.lib.nixosSystem {
          modules = [ ./hosts/Elderwood ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
        Drgnfly = nixpkgs.lib.nixosSystem {
          modules = [ ./hosts/Drgnfly ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
        littleBee = nixpkgs.lib.nixosSystem {
          modules = [ ./hosts/littleBee ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      };

      homeConfigurations = {
        # Desktop
        "sinh@Elderwood" = lib.homeManagerConfiguration {
          modules = [
            ./home/sinh/nixpkgs.nix
            ./home/sinh/Elderwood.nix
          ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };

        # Work laptop
        "sinh@Drgnfly" = lib.homeManagerConfiguration {
          modules = [
            ./home/sinh/nixpkgs.nix
            ./home/sinh/Drgnfly.nix
          ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };
      };
    };
}
