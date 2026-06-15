{ lib, ... }:
_final: prev:
let
  libxml2-2_11 = prev.libxml2.overrideAttrs (_old: rec {
    version = "2.11.7";
    src = prev.fetchurl {
      url = "https://download.gnome.org/sources/libxml2/2.11/libxml2-${version}.tar.xz";
      hash = "sha256-+ydyDiXq9Ff5T9PXGJvPJibG3M9CAVU7yIdNUONWAWI=";
    };
  });
in
{
  viber = prev.viber.overrideAttrs (oldAttrs: {
    installPhase =
      let
        inherit (oldAttrs) installPhase;
      in
      installPhase
      + ''
        # libxshmfence.so.1 — missing from Viber's bundled libs
        ln -s "${lib.getLib prev.libxshmfence}/lib/libxshmfence.so.1" "$out/opt/viber/lib/libxshmfence.so.1"
      ''
      # Replace nixpkgs libxml2 symlink with older 2.11.7 that has the valuePush symbol
      # (libxml2 >= 2.12.0 renamed valuePush -> xmlXPathValuePush, breaking Viber's Qt6)
      + lib.optionalString true ''
        rm -f "$out/opt/viber/lib/libxml2.so.2"
        ln -s "${lib.getLib libxml2-2_11}/lib/libxml2.so.2" "$out/opt/viber/lib/libxml2.so.2"
      '';
  });
}
