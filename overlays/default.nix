{ outputs, inputs }:
let
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
    });
in
{
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs (
      _: flake:
      let
        legacyPackages = (flake.legacyPackages or { }).${final.system} or { };
        packages = (flake.packages or { }).${final.system} or { };
      in
      if legacyPackages != { } then legacyPackages else packages
    ) inputs;
  };

  unstable = final: _: {
    unstable = import inputs.nixpkgs {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # Adds my custom packages
  additions = final: prev: import ../pkgs { pkgs = final; };

  # Modifies existing packages
  modifications = final: prev: {
    zjstatus = inputs.zjstatus.packages.${prev.system}.default;

    sinh-x-wallpaper = inputs.sinh-x-wallpaper.defaultPackage.${prev.system};
    sinh-x-gitstatus = inputs.sinh-x-gitstatus.defaultPackage.${prev.system};
    sinh-x-ip_updater = inputs.sinh-x-ip_updater.defaultPackage.${prev.system};
    rust_cli_pomodoro = inputs.rust_cli_pomodoro.defaultPackage.${prev.system};
    # nvim-kickstart = inputs.nvim-kickstart.packages.${prev.system}.default;
    nixvim = inputs.nixvim.packages.${prev.system}.nvim;

    viber = prev.viber.overrideAttrs (oldAttrs: {
      src = prev.fetchurl {
        url = "https://web.archive.org/web/20240801032209/https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb";
        sha256 = "sha256-9WHiI2WlsgEhCPkrQoAunmF6lSb2n5RgQJ2+sdnSShM=";
      };
    });
  };
}
