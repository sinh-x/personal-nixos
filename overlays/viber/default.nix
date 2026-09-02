{ lib, ... }:
_final: prev: {
  viber = prev.viber.overrideAttrs (oldAttrs: {
    installPhase =
      let
        inherit (oldAttrs) installPhase;
      in
      installPhase
      + ''
        # libxshmfence.so.1 — missing from Viber's bundled libs
        ln -s "${lib.getLib prev.libxshmfence}/lib/libxshmfence.so.1" "$out/opt/viber/lib/libxshmfence.so.1"
      '';
  });
}
