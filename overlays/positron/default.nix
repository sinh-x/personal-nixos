_: _final: prev: {
  # For example, to pull a package from unstable NixPkgs make sure you have the
  # input `unstable = "github:nixos/nixpkgs/nixos-unstable"` in your flake.
  positron-bin = prev.positron-bin.overrideAttrs (_oldAttrs: {
    version = "2025.02.0-171";
    src = prev.fetchurl {
      url = "https://github.com/posit-dev/positron/releases/download/2025.02.0-171/Positron-2025.02.0-171-x64.deb";
      sha256 = "sha256-TjQc/Y4Sa2MlLslbygYVFbIk3raArMvYstSiSEYzfo0=";
    };
  });
}
