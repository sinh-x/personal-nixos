{ pkgs ? import <nixpkgs> {} }:

let
  src = pkgs.fetchFromGitHub {
    owner = "sinh-x";
    repo = "ip_update";
    rev = "fc7350ad71975e304bc3d6d40c45ab83df243f99";
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
