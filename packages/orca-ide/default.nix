{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nodejs_24,
  electron_43,
  python3,
  node-gyp,
  pkg-config,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  gsettings-desktop-schemas,
  glib,
  gtk3,
  gtk4,
  copyDesktopItems,
  makeDesktopItem,
}:
let
  pname = "orca-ide";
  version = "1.4.200";
  rev = "f352b6b08d9028ba8b577d6ac8a8247c2a6c9c92";

  # Orca's packageManager field requires pnpm 12.0.0 exactly. Until nixpkgs
  # exposes pnpm 12, provision the official, hash-pinned standalone tool.
  pnpm_12 = stdenv.mkDerivation {
    pname = "pnpm";
    version = "12.0.0";
    src = fetchurl {
      url = "https://registry.npmjs.org/@pnpm/exe.linux-x64/-/exe.linux-x64-12.0.0.tgz";
      hash = "sha256-0MZO+rOdVg7zrk3Ivl3QiVHlQJ7S1Ty2uDF7dxPCYzM=";
    };
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib ];
    dontBuild = true;
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 pnpm "$out/bin/pnpm"
      ln -s pnpm "$out/bin/pnpx"
      runHook postInstall
    '';
    passthru.nodejs-slim = nodejs_24;
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "stablyai";
    repo = "orca";
    inherit rev;
    hash = "sha256-LS9VEj4uUFs6F9NTnq2y8AMEXbuVLp9dpIExSTegt+4=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version;
    inherit (finalAttrs) src;
    # The nixpkgs fetcher does not yet understand pnpm 12's native downloader.
    # pnpm 11 reads the same v9 lockfile/store format; the sandboxed install and
    # all compilation below still run with Orca's required pnpm 12.0.0.
    pnpm = pnpm_11;
    fetcherVersion = 4;
    # Dependency ages are an online policy check. The lockfile and output hash
    # remain the build authorities, so disable that check in the fetcher.
    postPatch = ''
      substituteInPlace pnpm-workspace.yaml \
        --replace-fail "minimumReleaseAge: 4320" "minimumReleaseAge: 0"
    '';
    hash = "sha256-XN3grjFeGbiN0rKM29GArtkpHkB1XuXdl32V2UqaT/E=";
  };

  postPatch = ''
    substituteInPlace pnpm-workspace.yaml \
      --replace-fail "minimumReleaseAge: 4320" "minimumReleaseAge: 0"

    # The Nix closure supplies its own glibc. Upstream's Ubuntu 20.04 floor is
    # valid for portable release artifacts, but not for a NixOS-only package.
    substituteInPlace config/electron-builder.config.cjs \
      --replace-fail \
        '      verifyLinuxGlibcFloor(context.appOutDir, {' \
        "      if (process.env.ORCA_NIX_BUILD !== '1') verifyLinuxGlibcFloor(context.appOutDir, {"
  '';

  nativeBuildInputs = [
    nodejs_24
    pnpm_12
    pnpmConfigHook
    python3
    node-gyp
    pkg-config
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    gsettings-desktop-schemas
    glib
    gtk3
    gtk4
  ];

  dontWrapGApps = true;
  dontStrip = true;

  buildPhase = ''
    runHook preBuild

    # pnpm 12 runs approved dependency scripts before the first command. Prepare
    # the pinned Electron runtime first so upstream's native rebuild is offline.
    electron_package="$(realpath node_modules/electron)"
    chmod -R u+w "$electron_package"
    substituteInPlace "$electron_package/package.json" \
      --replace-fail '"version": "43.6.0"' '"version": "${electron_43.version}"'
    rm -rf "$electron_package/dist"
    ln -s ${electron_43.dist} "$electron_package/dist"
    printf '%s' electron > "$electron_package/path.txt"

    export ELECTRON_OVERRIDE_DIST_PATH=${electron_43.dist}
    export npm_config_nodedir=${electron_43.headers}
    export npm_config_node_gyp=${node-gyp}/lib/node_modules/node-gyp/bin/node-gyp.js
    export ORCA_REUSE_PREPARED_NATIVE_RUNTIME=1
    export ORCA_NIX_BUILD=1
    export CXXFLAGS="''${CXXFLAGS-} -std=gnu++2a"

    test "$(pnpm --version)" = "12.0.0"
    pnpm run build:desktop

    pnpm exec electron-builder \
      --config config/electron-builder.config.cjs \
      --dir --x64 \
      -c.electronDist=${electron_43.dist} \
      -c.electronVersion=${electron_43.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    app_dir="$out/share/orca-ide"
    mkdir -p "$app_dir" "$out/bin" "$out/share/icons/hicolor/512x512/apps"
    cp -r dist/linux-unpacked/. "$app_dir/"
    install -Dm444 resources/build/icon.png \
      "$out/share/icons/hicolor/512x512/apps/orca-ide.png"

    # Mark repackaged Linux installs as externally managed so Orca does not
    # attempt to replace its immutable Nix-store installation.
    printf 'deb\n' > "$app_dir/resources/package-type"

    gappsWrapperArgsHook
    wrapProgram "$app_dir/orca-ide" \
      "''${gappsWrapperArgs[@]}" \
      --set CHROME_DEVEL_SANDBOX ${electron_43}/libexec/electron/chrome-sandbox

    cat > "$out/bin/orca-ide" <<EOF
    #!/bin/sh
    if [ "\$#" -eq 1 ] && [ "\$1" = --version ]; then
      echo "orca-ide ${version}"
      exit 0
    fi
    exec "$app_dir/orca-ide" "\$@"
    EOF
    chmod 755 "$out/bin/orca-ide"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "orca-ide";
      exec = "orca-ide %U";
      icon = "orca-ide";
      desktopName = "Orca";
      comment = "IDE for parallel agentic development";
      categories = [
        "Development"
        "IDE"
      ];
      startupWMClass = "orca";
      terminal = false;
    })
  ];

  meta = {
    description = "IDE for parallel agentic development";
    homepage = "https://github.com/stablyai/orca";
    license = lib.licenses.asl20;
    mainProgram = "orca-ide";
    platforms = [ "x86_64-linux" ];
  };
})
