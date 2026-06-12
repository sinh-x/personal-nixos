{
  inputs,
  src,
}:
let
  inherit (inputs.nixpkgs) lib;

  namespace = "sinh-x";

  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];

  forAllSystems = lib.genAttrs systems;

  discoverDefaultNix =
    root:
    let
      walk =
        dir: prefix:
        lib.flatten (
          lib.mapAttrsToList (
            name: type:
            let
              path = dir + "/${name}";
              rel = if prefix == "" then name else "${prefix}/${name}";
            in
            if type == "directory" then
              (lib.optional (builtins.pathExists (path + "/default.nix")) {
                inherit rel;
                file = path + "/default.nix";
              })
              ++ walk path rel
            else
              [ ]
          ) (builtins.readDir dir)
        );
    in
    builtins.listToAttrs (
      map (entry: {
        name = entry.rel;
        value = entry.file;
      }) (walk root "")
    );

  repoLib =
    (import ../default.nix { inherit lib; })
    // (import ../file/default.nix { lib = flakeLib; })
    // (import ../module/default.nix { lib = flakeLib; })
    // (import ../theme/default.nix { lib = flakeLib; });

  flakeLib = lib.extend (
    _final: _prev: inputs.home-manager.lib // repoLib // { ${namespace} = repoLib; }
  );

  packageFiles = discoverDefaultNix (src + "/packages");
  overlayFiles = discoverDefaultNix (src + "/overlays");
  nixosModuleFiles = discoverDefaultNix (src + "/modules/nixos");
  homeModuleFiles = discoverDefaultNix (src + "/modules/home");
  checkFiles = discoverDefaultNix (src + "/checks");
  shellFiles = discoverDefaultNix (src + "/shells");

  importOverlay =
    file:
    import file {
      inherit inputs namespace;
      lib = flakeLib;
    };

  packageOverlays = lib.mapAttrs' (name: file: {
    name = "package/${name}";
    value =
      final: prev:
      let
        package = final.callPackage file { };
      in
      {
        ${name} = package;
        ${namespace} = (prev.${namespace} or { }) // {
          ${name} = package;
        };
      };
  }) packageFiles;

  namedOverlays = lib.mapAttrs (_name: importOverlay) overlayFiles;

  nonDefaultOverlays = packageOverlays // namedOverlays;

  overlays = nonDefaultOverlays // {
    default =
      final: prev:
      lib.foldl' (attrs: overlay: attrs // overlay final prev) { } (
        builtins.attrValues nonDefaultOverlays
      );
  };

  pkgsFor =
    system:
    import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [ "electron-39.8.10" ];
      };
      overlays = (builtins.attrValues nonDefaultOverlays) ++ [ (_final: _prev: { lib = flakeLib; }) ];
    };

  pkgs = forAllSystems (system: {
    nixpkgs = pkgsFor system;
    nixpkgs-gurk = import inputs.nixpkgs-gurk {
      inherit system;
      config.allowUnfree = true;
    };
  });

  packages = forAllSystems (
    system: lib.mapAttrs (_name: file: (pkgsFor system).callPackage file { }) packageFiles
  );

  nixosModules = lib.mapAttrs (_name: import) nixosModuleFiles;
  homeModules = lib.mapAttrs (_name: import) homeModuleFiles;

  checks = forAllSystems (
    system:
    lib.mapAttrs (
      _name: file:
      import file {
        inherit inputs namespace;
        lib = flakeLib;
        pkgs = pkgsFor system;
      }
    ) checkFiles
  );

  devShells = forAllSystems (
    system:
    lib.mapAttrs (
      _name: file:
      (pkgsFor system).callPackage file {
        inherit inputs namespace system;
        pkgs = pkgsFor system;
      }
    ) shellFiles
  );

  hostFiles = discoverDefaultNix (src + "/systems/x86_64-linux");

  mkNixosConfiguration =
    hostName: file:
    lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs namespace;
        lib = flakeLib;
      };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        {
          networking.hostName = hostName;
          nixpkgs.pkgs = pkgsFor "x86_64-linux";
          _module.args = {
            inherit inputs namespace;
            lib = flakeLib;
          };
          home-manager.sharedModules = builtins.attrValues homeModules;
          home-manager.extraSpecialArgs = {
            inherit inputs namespace;
            lib = flakeLib;
          };
        }
      ]
      ++ builtins.attrValues nixosModules
      ++ [ file ];
    };

  nixosConfigurations = lib.mapAttrs mkNixosConfiguration hostFiles;
in
{
  inherit
    checks
    devShells
    homeModules
    nixosConfigurations
    nixosModules
    overlays
    packages
    pkgs
    ;

  inherit src;

  lib = repoLib;

  darwinModules = { };
  templates = { };
}
