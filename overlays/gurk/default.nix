# Overlay to pin gurk-rs to stable nixpkgs due to NIX_LDFLAGS build error in unstable
{ inputs, ... }:
_final: prev:
let
  pkgs-gurk = import inputs.nixpkgs-gurk {
    inherit (prev.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  inherit (pkgs-gurk) gurk-rs;
}
