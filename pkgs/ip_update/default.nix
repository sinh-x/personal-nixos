{pkgs ? import <nixpkgs> {}}: let
  src = pkgs.fetchFromGitHub {
    owner = "sinh-x";
    repo = "ip_update";
    rev = "3e0191d757420b9a179327f8e9b4c0c8f558b223";
    sha256 = "sha256-CBHsn4M6o78x9hcc203HcNlFkplcCTjXVqK4b3k4ZEY=";
  };
in
  pkgs.rustPlatform.buildRustPackage {
    pname = "ip_update";
    version = "0.1.0";

    inherit src;

    cargoSha256 = "sha256-QD3LgDxnAXR4VUnXwchW80vffeAp1JylGq5bKdCcdgE=";
    buildInputs = [pkgs.openssl];
    nativeBuildInputs = [pkgs.cargo pkgs.rustc pkgs.pkg-config pkgs.openssl];
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.openssl
    ];

    meta = with pkgs.lib; {
      description = "My ip update tool";
      license = licenses.mit;
    };
  }
