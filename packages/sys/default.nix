{ writeShellScriptBin, ... }:
writeShellScriptBin "sys" ''

  TOTAL_CORES=''${TOTAL_CORES:-10}
  MAX_JOBS=''${MAX_JOBS:-4}
  NIX_BUILD_CORES=$(( TOTAL_CORES / MAX_JOBS ))

  cmd_rebuild() {
      echo "🔨 Building system configuration with $REBUILD_COMMAND (total: $TOTAL_CORES cores, $MAX_JOBS jobs, $NIX_BUILD_CORES cores/job)"
      NIX_BUILD_CORES=$NIX_BUILD_CORES $REBUILD_COMMAND switch --flake .# --max-jobs $MAX_JOBS
  }

  cmd_test() {
      echo "🏗️ Building ephemeral system configuration with $REBUILD_COMMAND (total: $TOTAL_CORES cores, $MAX_JOBS jobs, $NIX_BUILD_CORES cores/job)"
      NIX_BUILD_CORES=$NIX_BUILD_CORES $REBUILD_COMMAND test --no-reexec --flake .# --max-jobs $MAX_JOBS
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
      $PROGRAM rebuild [--cores N]
          Rebuild the system. (You must be in the system flake directory!)
          Must be run as root.
      $PROGRAM test [--cores N]
          Like rebuild but faster and not persistant.
      $PROGRAM update [input]
          Update all inputs or the input specified. (You must be in the system flake directory!)
          Must be run as root.
      $PROGRAM clean
          Garbage collect and optimise the Nix Store.
      $PROGRAM help
          Show this text.

  Options:
      --cores N    Total CPU cores budget (default: 10, env: TOTAL_CORES)
      --jobs N     Max parallel build jobs (default: 4, env: MAX_JOBS)
                   cores/job = total / jobs
  _EOF
  }


  if [[ "$OSTYPE" == "linux"* ]]; then
    REBUILD_COMMAND=nixos-rebuild
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    REBUILD_COMMAND=darwin-rebuild
  fi

  # Parse --cores/--jobs before subcommand
  for arg in "$@"; do
      case "$arg" in
          --cores) shift; TOTAL_CORES="$1"; shift ;;
          --cores=*) TOTAL_CORES="''${arg#*=}"; shift ;;
          --jobs) shift; MAX_JOBS="$1"; shift ;;
          --jobs=*) MAX_JOBS="''${arg#*=}"; shift ;;
      esac
  done
  NIX_BUILD_CORES=$(( TOTAL_CORES / MAX_JOBS ))

  PROGRAM=sys
  COMMAND="$1"
  case "$1" in
      rebuild|r) shift;       cmd_rebuild ;;
      test|t) shift;          cmd_test ;;
      update|u) shift;        cmd_update ;;
      clean|c) shift;         cmd_clean ;;
      help|--help) shift;     cmd_usage "$@" ;;
      *)              echo "Unknown command: $@" ;;
  esac
  exit 0
''
