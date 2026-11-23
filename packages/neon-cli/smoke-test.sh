#!/usr/bin/env bash
# Usage: bash packages/neon-cli/smoke-test.sh /nix/store/...-neon-VERSION VERSION
set -euo pipefail

package=$(realpath "${1:?Pass the built neon-cli package output}")
test -x "$package/bin/neon"
expected_version=${2:?Pass the expected upstream version}
shell=$(readlink -f "$(command -v bash)")
coreutils_bin=$(dirname "$(readlink -f "$(command -v mkdir)")")

# Only the immutable store is shared. No host home, environment or network.
# Empty /etc, /run and /var are required by the nested FHS wrapper.
bwrap --unshare-net --ro-bind /nix/store /nix/store \
  --dev /dev --proc /proc --tmpfs /tmp \
  --dir /home --dir /etc --dir /run --dir /var --dir /work \
  --clearenv --setenv HOME /home \
  --setenv XDG_CONFIG_HOME /home/config --setenv XDG_CACHE_HOME /home/cache \
  --setenv PATH "$package/bin:$coreutils_bin" \
  "$shell" --noprofile --norc -euo pipefail -s -- "$expected_version" <<'EOF'
    while read -r interface rest; do
      case "$interface" in Iface|lo) ;; *) exit 1 ;; esac
    done < /proc/net/route
    mkdir -p /work/project-a /work/project-b
    printf "preserve\n" > /home/operator-sentinel
    expected=$(command -v neon)
    for project in /work/project-a /work/project-b; do
      cd "$project"
      test "$(command -v neon)" = "$expected"
      version=$(timeout 30 neon --version)
      test "$version" = "$1"
      help=$(timeout 30 neon --help)
      [[ "$help" == *projects* && "$help" == *branches* ]]
      printf "%s: %s (%s), version/help passed\n" "$project" "$expected" "$version"
    done
    test "$(cat /home/operator-sentinel)" = preserve
    printf "Network-isolated fixture checks passed; installed-profile UAT not run.\n"
EOF
