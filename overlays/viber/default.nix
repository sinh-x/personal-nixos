_: _final: prev: {
  # For example, to pull a package from unstable NixPkgs make sure you have the
  # input `unstable = "github:nixos/nixpkgs/nixos-unstable"` in your flake.
  viber = prev.viber.overrideAttrs (_oldAttrs: {
    src = prev.fetchurl {
      url = "https://web.archive.org/web/20240801032209/https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb";
      sha256 = "sha256-9WHiI2WlsgEhCPkrQoAunmF6lSb2n5RgQJ2+sdnSShM=";
    };
  });

}
