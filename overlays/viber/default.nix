{ lib, ... }:
_final: prev: {
  viber = prev.viber.overrideAttrs (oldAttrs: {
    installPhase = oldAttrs.installPhase + ''
      ln -s "${lib.getLib prev.libxshmfence}/lib/libxshmfence.so.1" "$out/opt/viber/lib/libxshmfence.so.1"
    '';
  });
}
