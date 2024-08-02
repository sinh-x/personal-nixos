{
  outputs,
  inputs,
}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs (
        _: flake: let
          legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
          packages = (flake.packages or {}).${final.system} or {};
        in
          if legacyPackages != {}
          then legacyPackages
          else packages
      )
      inputs;
  };
  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  # unstable = final: _: {
  #   unstable = import inputs.nixpkgs-unstable (inherit final) system);
  # };
  unstable = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # Adds my custom packages
  additions = final: prev:
    import ../pkgs {pkgs = final;};

  # Modifies existing packages
  modifications = final: prev: {
    zjstatus = inputs.zjstatus.packages.${prev.system}.default;

    viber = final.pkgs.unstable.viber.overrideAttrs (oldAttrs: {
      src = final.fetchurl {
        url = "https://web.archive.org/web/20240115205140/https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb";
        sha256 = "sha256-9WHiI2WlsgEhCPkrQoAunmF6lSb2n5RgQJ2+sdnSShM=";
      };
    });
  };
}
