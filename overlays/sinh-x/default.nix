# Snowfall Lib provides access to additional information via a primary argument of
# your overlay.
{
  # Channels are named after NixPkgs instances in your flake inputs. For example,
  # with the input `nixpkgs` there will be a channel available at `channels.nixpkgs`.
  # These channels are system-specific instances of NixPkgs that can be used to quickly
  # pull packages into your overlay.

  # The namespace used for your Flake, defaulting to "internal" if not set.
  inputs,
  ...
}:
let
  # AnyIO 4.14.2 has an invalid TLS fixture and a racy global thread-count test.
  # Correct the tests without adding skips or changing runtime behavior.
  pythonAnyioFix = _final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (_pythonFinal: pythonPrev: {
        anyio = pythonPrev.anyio.overridePythonAttrs (
          old:
          prev.lib.optionalAttrs (old.version == "4.14.2") {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace tests/streams/test_tls.py \
                --replace-fail $'server_side=True,\n            hostname="localhost",' 'server_side=True,'
              substituteInPlace tests/test_to_thread.py \
                --replace-fail 'active_threads_before = threading.active_count()' \
                  'threads_before = set(threading.enumerate())' \
                --replace-fail 'assert threading.active_count() == active_threads_before' \
                  $'assert not any(thread.is_alive() for thread in threads)\n        assert set(threading.enumerate()) <= threads_before'
            '';
          }
        );
      })
    ];
  };
in
_final: prev:
(pythonAnyioFix _final prev)
// {
  # Model tests auto-detect CPU threads independently of Nix's build-core hint.
  # Avoid nested test parallelism without skipping checks or changing runtime code.
  llama-cpp = prev.llama-cpp.overrideAttrs (
    old:
    prev.lib.optionalAttrs (old.version == "0.6.0") {
      enableParallelChecking = false;
      preCheck = (old.preCheck or "") + ''
        export LLAMA_ARG_THREADS=2
      '';
    }
  );

  # For example, to pull a package from unstable NixPkgs make sure you have the
  # input `unstable = "github:nixos/nixpkgs/nixos-unstable"` in your flake.

  inherit (inputs.sinh-x-ip_updater.packages.${prev.stdenv.hostPlatform.system}) sinh-x-ip_updater;
  inherit (inputs.sinh-x-wallpaper.packages.${prev.stdenv.hostPlatform.system}) sinh-x-wallpaper;
  inherit (inputs.sinh-x-pomodoro.packages.${prev.stdenv.hostPlatform.system}) sinh-x-pomodoro;
  inherit (inputs.sinh-x-gitstatus.packages.${prev.stdenv.hostPlatform.system}) sinh-x-gitstatus;

  inherit (inputs.sinh-x-avodah.packages.${prev.stdenv.hostPlatform.system}) avo;

  inherit (inputs.sinh-x-zeroclaw.packages.${prev.stdenv.hostPlatform.system}) sinh-x-zeroclaw;

  # Neovim uses its own package set, so apply the same fixture fix there.
  nixvim = inputs.sinh-x-nixvim.packages.${prev.stdenv.hostPlatform.system}.nvim.override (args: {
    pkgs = args.pkgs.extend pythonAnyioFix;
  });
  zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;

  inherit (inputs.sinh-x-zca-js.packages.${prev.stdenv.hostPlatform.system}) zca-listener;

  fcitx5-lotus =
    inputs.fcitx5-lotus.packages.${prev.stdenv.hostPlatform.system}.fcitx5-lotus.override
      {
        inherit (prev.kdePackages) extra-cmake-modules;
      };
  inherit (inputs.andafin-jira-mcp.packages.${prev.stdenv.hostPlatform.system}) andafin-jira-mcp;
  personal-google-mcp =
    inputs.personal-google-mcp.packages.${prev.stdenv.hostPlatform.system}.default;

  pa-platform = inputs.pa-platform.lib.mkPaPlatform prev.stdenv.hostPlatform.system {
    enablePiVimMode = true;
    enableProperBase = false;
  };
  inherit (inputs.pa-platform.packages.${prev.stdenv.hostPlatform.system})
    pa-core
    opa
    ;

  opencode = inputs.opencode.packages.${prev.stdenv.hostPlatform.system}.default;

  inherit (inputs.herdr.packages.${prev.stdenv.hostPlatform.system}) herdr;

  inherit (prev.kdePackages) extra-cmake-modules;

  libsForQt5 = prev.qt6Packages // {
    inherit (prev.kdePackages) extra-cmake-modules;
  };

  qt6Packages = prev.qt6Packages // {
    fcitx5-with-addons = prev.lib.makeOverridable (
      {
        addons ? [ ],
      }:
      prev.symlinkJoin {
        name = "fcitx5-with-addons-${prev.fcitx5.version}";
        paths = [
          prev.fcitx5
          prev.qt6Packages.fcitx5-qt
          prev.fcitx5-gtk
          prev.qt6Packages.fcitx5-configtool
        ]
        ++ addons;
        nativeBuildInputs = [ prev.makeBinaryWrapper ];
        postBuild = ''
          wrapProgram $out/bin/fcitx5 \
            --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
            --prefix FCITX_ADDON_DIRS : "$out/lib/fcitx5" \
            --suffix XDG_DATA_DIRS : "$out/share" \
            --suffix PATH : "$out/bin"

          wrapProgram $out/bin/fcitx5-config-qt --prefix FCITX_ADDON_DIRS : "$out/lib/fcitx5"

          pushd $out
          grep -Rl --include=\*.{desktop,service} share/applications etc/xdg/autostart share/dbus-1/services -e ${prev.fcitx5} | while read -r file; do
            rm $file
            cp ${prev.fcitx5}/$file $file
            substituteInPlace $file --replace-fail ${prev.fcitx5} $out
          done
          popd
        '';
        inherit (prev.fcitx5) meta;
      }
    ) { };
  };
}
