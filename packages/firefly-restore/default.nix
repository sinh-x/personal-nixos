{ writeShellScriptBin, ... }:
writeShellScriptBin "firefly-restore" ''
  set -euo pipefail

  PROGRAM="firefly-restore"
  PROFILE="sinh-personal_file"
  DEFAULT_TARGET="/persist/home/sinh"

  RESTORE_DIRS=(
    .ssh
    .gnupg
    .config/gh
    .config/git
    .config/sops/age
    .config/rclone
    .config/rustic
    .config/sinh-x-scripts
    git-repos/sinh-x/personal-nixos
  )

  check_prerequisites() {
    local errors=0
    if [[ ! -f "$HOME/.config/rclone/rclone.conf" ]] && [[ ! -f "/persist/home/sinh/.config/rclone/rclone.conf" ]]; then
      echo "ERROR: rclone.conf not found"
      echo "  Copy it manually first: ~/.config/rclone/rclone.conf"
      errors=1
    fi
    if ! rustic -P "$PROFILE" cat config &>/dev/null; then
      echo "ERROR: rustic profile '$PROFILE' not accessible"
      echo "  Copy it manually first: ~/.config/rustic/$PROFILE.toml"
      errors=1
    fi
    if [[ $errors -ne 0 ]]; then
      echo ""
      echo "Bootstrap: manually copy rclone.conf and rustic profile before restoring."
      exit 1
    fi
    echo "Prerequisites OK"
  }

  cmd_check() {
    check_prerequisites
  }

  cmd_list() {
    echo "Directories that 'all' will restore:"
    for d in "''${RESTORE_DIRS[@]}"; do
      echo "  $d"
    done
  }

  cmd_restore_dir() {
    local target="$1"
    local dirname="$2"
    echo "Restoring $dirname -> $target/$dirname"
    rustic -P "$PROFILE" restore "latest:/$dirname" "$target/$dirname"
  }

  cmd_all() {
    local target="''${1:-$DEFAULT_TARGET}"
    check_prerequisites
    echo ""
    echo "Restoring all directories to: $target"
    echo ""
    for d in "''${RESTORE_DIRS[@]}"; do
      cmd_restore_dir "$target" "$d"
      echo ""
    done
    echo "Done. All directories restored to $target"
  }

  cmd_single() {
    local target="$DEFAULT_TARGET"
    local dirname="$1"
    if [[ $# -ge 2 ]]; then
      target="$1"
      dirname="$2"
    fi
    check_prerequisites
    cmd_restore_dir "$target" "$dirname"
  }

  cmd_usage() {
    cat <<-_EOF
  Usage:
      $PROGRAM check
          Verify prerequisites (rclone.conf, rustic profile).
      $PROGRAM list
          List directories that 'all' will restore.
      $PROGRAM all [target]
          Restore all directories to target (default: $DEFAULT_TARGET).
      $PROGRAM <dirname> [target]
          Restore a single directory (e.g., .ssh, Documents).
      $PROGRAM help
          Show this text.

  Examples:
      $PROGRAM all                              # Restore all to /persist/home/sinh
      $PROGRAM all /mnt/persist/home/sinh       # Restore all during install
      $PROGRAM .ssh                             # Restore just .ssh
      $PROGRAM Documents /mnt/persist/home/sinh # Restore Documents to custom target
  _EOF
  }

  COMMAND="''${1:-help}"
  case "$COMMAND" in
    check|c)   cmd_check ;;
    list|ls|l) cmd_list ;;
    all|a)     shift; cmd_all "$@" ;;
    help|--help|-h) cmd_usage ;;
    *)         cmd_single "$@" ;;
  esac
''
