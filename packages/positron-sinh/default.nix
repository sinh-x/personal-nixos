{
  lib,
  _7zz,
  alsa-lib,
  systemd,
  autoPatchelfHook,
  blas,
  dpkg,
  fetchurl,
  gtk3,
  libglvnd,
  libxkbcommon,
  makeShellWrapper,
  mesa,
  musl,
  nss,
  openssl,
  patchelf,
  stdenv,
  xorg,
}:
let
  pname = "positron-sinh";
  version = "2025.02.0-171";
in
stdenv.mkDerivation {
  inherit version pname;

  src = fetchurl {
    url = "https://cdn.posit.co/positron/prereleases/deb/x86_64/Positron-2025.03.0-116-x64.deb";
    hash = "sha256-ay4coAhTUCht77FR26JQ4bAGsZmDbMHejy3BDkrPhSQ=";
  };

  buildInputs =
    [ makeShellWrapper ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
      dpkg
      gtk3
      libglvnd
      libxkbcommon
      mesa
      musl
      nss
      openssl
      stdenv.cc.cc
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libxkbfile
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      blas
      patchelf
    ];

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      _7zz
    ];

  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [
    # Needed to fix the "Zygote could not fork" error.
    (lib.getLib systemd)
  ];

  postUnpack = lib.optionalString stdenv.hostPlatform.isLinux ''dpkg-deb --fsys-tarfile "$src" | tar -x --no-same-owner'';

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        runHook preInstall
        mkdir -p "$out/Applications" "$out/bin"
        cp -r . "$out/Applications/Positron.app"

        # Positron will use the system version of BLAS if we don't provide the nix version.
        wrapProgram "$out/Applications/Positron.app/Contents/Resources/app/bin/code" \
          --prefix DYLD_INSERT_LIBRARIES : "${lib.makeLibraryPath [ blas ]}/libblas.dylib"

        ln -s "$out/Applications/Positron.app/Contents/Resources/app/bin/code" "$out/bin/positron"
        runHook postInstall
      ''
    else
      ''
        runHook preInstall
        mkdir -p "$out/share"
        cp -r usr/share/pixmaps "$out/share/pixmaps"
        cp -r usr/share/positron "$out/share/positron"

        mkdir -p "$out/share/applications"
        install -m 444 -D usr/share/applications/positron.desktop "$out/share/applications/positron.desktop"
        substituteInPlace "$out/share/applications/positron.desktop" \
          --replace-fail \
          "Exec=/usr/share/positron/positron %F" \
          "Exec=$out/share/positron/.positron-wrapped %F" \
          --replace-fail \
          "/usr/share/positron/positron --new-window %F" \
          "$out/share/positron/.positron-wrapped --new-window %F"

        # Fix libGL.so not found errors.
        wrapProgram "$out/share/positron/positron" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}"

        mkdir -p "$out/bin"
        ln -s "$out/share/positron/positron" "$out/bin/positron"
        runHook postInstall
      '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Positron, a next-generation data science IDE";
    homepage = "https://github.com/posit-dev/positron";
    license = licenses.elastic20;
    maintainers = with maintainers; [
      b-rodrigues
      detroyejr
    ];
    mainProgram = "positron";
    platforms = [ "x86_64-linux" ] ++ platforms.darwin;
  };
}
