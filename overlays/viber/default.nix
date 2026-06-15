{ lib, ... }:
_final: prev: {
  viber = prev.viber.overrideAttrs (oldAttrs: {
    # Viber bundles its own libs but misses libxshmfence.so.1 at runtime.
    # Symlink pattern matches the existing libxml2 fix in nixpkgs.
    installPhase = oldAttrs.installPhase + ''
      ln -s "${lib.getLib prev.libxshmfence}/lib/libxshmfence.so.1" "$out/opt/viber/lib/libxshmfence.so.1"
    '';
  });
}
# Template for version pinning: viber = prev.viber.overrideAttrs (oldAttrs: rec { version = "..."; src = ...; });
