{ writeShellScriptBin, ... }:
writeShellScriptBin "sys" ''
  set -euo pipefail

  NIX_BUILD_CORES=''${NIX_BUILD_CORES:-2}
  MAX_JOBS=''${MAX_JOBS:-4}

  cmd_rebuild() {
      echo "🔨 Building system configuration with $REBUILD_COMMAND (cores: $NIX_BUILD_CORES, jobs: $MAX_JOBS)"
      "$REBUILD_COMMAND" switch --flake "$FLAKE_DIR#" --cores "$NIX_BUILD_CORES" --max-jobs "$MAX_JOBS" "''${REBUILD_ARGS[@]}"
  }

  cmd_test() {
      echo "🏗️ Building ephemeral system configuration with $REBUILD_COMMAND (cores: $NIX_BUILD_CORES, jobs: $MAX_JOBS)"
      "$REBUILD_COMMAND" test --no-reexec --flake "$FLAKE_DIR#" --cores "$NIX_BUILD_CORES" --max-jobs "$MAX_JOBS" "''${REBUILD_ARGS[@]}"
  }

  # TODO: Make it update a single input
  cmd_update() {
      echo "🔒Updating flake.lock"
      nix flake update
  }

  cmd_clean() {
      echo "🗑️ Cleaning and optimizing the Nix store."
      nix store optimise --verbose &&
      nix store gc --verbose
  }

  cmd_usage() {
      cat <<-_EOF
  Usage:
      $PROGRAM rebuild [directory] [--cores N] [--jobs N] [nixos-rebuild options]
          Rebuild and switch the system. Must be run as root.
      $PROGRAM test [directory] [--cores N] [--jobs N] [nixos-rebuild options]
          Build and activate temporarily. Must be run as root.
      $PROGRAM update [input]
          Update all inputs or the input specified. (You must be in the system flake directory!)
          Must be run as root.
      $PROGRAM clean
          Garbage collect and optimise the Nix Store.
      $PROGRAM help
          Show this text.

  Options:
      --cores N    Cores per build job (default: 2, env: NIX_BUILD_CORES)
      --jobs N     Max parallel build jobs (default: 4, env: MAX_JOBS)
      --max-jobs N Alias for --jobs (also accepts Nix values such as auto)

  Build limits may appear before or after test/rebuild. Directory defaults to .
  Additional nixos-rebuild options are forwarded unchanged, after these defaults.
  Example: $PROGRAM test . --cores 4 --jobs 6 --option sandbox true
  _EOF
  }


  if [[ "$OSTYPE" == "linux"* ]]; then
    REBUILD_COMMAND=nixos-rebuild
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    REBUILD_COMMAND=darwin-rebuild
  fi

  parse_build_limit() {
      case "$1" in
          --cores|--jobs|--max-jobs)
              if [[ $# -lt 2 || -z "''${2:-}" || "''${2:-}" == --* ]]; then
                  echo "$1 requires a value" >&2
                  exit 2
              fi
              if [[ "$1" == --cores ]]; then
                  NIX_BUILD_CORES="$2"
              else
                  MAX_JOBS="$2"
              fi
              PARSED_COUNT=2
              ;;
          --cores=*) NIX_BUILD_CORES="''${1#*=}"; PARSED_COUNT=1 ;;
          --jobs=*|--max-jobs=*) MAX_JOBS="''${1#*=}"; PARSED_COUNT=1 ;;
          *) return 1 ;;
      esac
      if [[ -z "$NIX_BUILD_CORES" || -z "$MAX_JOBS" ]]; then
          echo "Build limits require non-empty values" >&2
          exit 2
      fi
  }

  PROGRAM=sys
  FLAKE_DIR=.
  REBUILD_ARGS=()
  while [[ $# -gt 0 ]] && parse_build_limit "$@"; do
      shift "$PARSED_COUNT"
  done
  COMMAND="''${1:-help}"
  if [[ $# -gt 0 ]]; then shift; fi

  case "$COMMAND" in
      rebuild|r|test|t)
          if [[ $# -gt 0 && "$1" != -* ]]; then
              FLAKE_DIR="$1"
              shift
          fi
          while [[ $# -gt 0 ]]; do
              if parse_build_limit "$@"; then
                  shift "$PARSED_COUNT"
              else
                  case "$1" in
                      --option)
                          if [[ $# -lt 3 ]]; then
                              echo "--option requires a name and value" >&2
                              exit 2
                          fi
                          REBUILD_ARGS+=("$1" "$2" "$3")
                          shift 3
                          ;;
                      --) shift; REBUILD_ARGS+=("$@"); break ;;
                      *) REBUILD_ARGS+=("$1"); shift ;;
                  esac
              fi
          done
          ;;
  esac

  case "$COMMAND" in
      rebuild|r) cmd_rebuild ;;
      test|t) cmd_test ;;
      update|u) cmd_update ;;
      clean|c) cmd_clean ;;
      help|--help|-h) cmd_usage ;;
      *) echo "Unknown command: $COMMAND" >&2; exit 2 ;;
  esac
''
