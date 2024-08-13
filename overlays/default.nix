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

  # Adds my custom packages
  additions = final: prev:
    import ../pkgs {pkgs = final;};

  # Modifies existing packages
  modifications = final: prev: {
    zjstatus = inputs.zjstatus.packages.${prev.system}.default;

    sinh-x-wallpaper = inputs.sinh-x-wallpaper.defaultPackage.${prev.system};
    sinh-x-gitstatus = inputs.sinh-x-gitstatus.defaultPackage.${prev.system};
    sinh-x-ip_updater = inputs.sinh-x-ip_updater.defaultPackage.${prev.system};
    rust_cli_pomodoro = inputs.rust_cli_pomodoro.defaultPackage.${prev.system};
    # nvim-kickstart = inputs.nvim-kickstart.packages.${prev.system}.default;
    nixvim = inputs.nixvim.packages.${prev.system}.default;

    # viber = final.pkgs.viber.overrideAttrs (oldAttrs: {
    #   src = final.fetchurl {
    #     url = "https://web.archive.org/web/20240114085219/https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb";
    #     sha256 = "sha256-RrObmN21QOm5nk0R2avgCH0ulrfiUIo2PnyYWvQaGVw";
    #   };
    # });
  };
}
