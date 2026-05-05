{ lib, ... }:
{
  inherit (lib) overrideDerivation;

  override = lib.overrideDerivation;

  override-meta =
    meta: package:
    package.overrideAttrs (_: {
      inherit meta;
    });
}
