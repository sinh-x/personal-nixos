{ pkgs ? import <nixpkgs> {} }:

let
  src = pkgs.fetchFromGitHub {
    owner = "sinh-x";
    repo = "ip_update";
    rev = "b672d020bc88ac6155aeb88fd1a6dca87a1fb8d7";
    sha256 = "sha256-H76Co7WLjEFmZoMJN/plBrVNrW4AzJsiREYIcRc7pd0=";
  };
in
pkgs.rustPlatform.buildRustPackage rec {
  pname = "ip_update";
  version = "0.1.0";

  inherit src;

  cargoSha256 = "sha256-yICTbIDOyTCy443pBa0yS+W2WOUCbBJijj53JooL9Kw=";
  buildInputs = [ pkgs.openssl ];
  nativeBuildInputs = [ pkgs.cargo pkgs.rustc pkgs.pkg-config pkgs.openssl ];
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.openssl
  ];

  meta = with pkgs.lib; {
    description = "My ip update tool";
    license = licenses.mit;
  };
}
