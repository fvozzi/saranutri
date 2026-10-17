#!/usr/bin/env bash
set -Eeuo pipefail

readonly gemstone_home="${GEMSTONE:-/usr/lib/x86_64-linux-gnu/gemstone/3.7.6}"
readonly gemstone_global_dir="${GEMSTONE_GLOBAL_DIR:-/opt/gemstone}"
readonly gemstone_data="${GEMSTONE_DATA:-/opt/gemstone/data/saranutri}"
readonly gemstone_user="saranutri"
readonly gemstone_group="saranutri"
readonly configuration_root="/etc/saranutri"
readonly script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly marker_file="$configuration_root/gemstone-3.7.6-configured"

if [[ $EUID -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

for required_path in \
  "$gemstone_home/install/doconfiguregs" \
  "$gemstone_home/install/createNewGemStoneRepository" \
  "$gemstone_home/bin/extent0.dbf" \
  "$script_directory/saranutri-stone.service" \
  "$script_directory/saranutri-netldi.service"; do
  if [[ ! -e "$required_path" ]]; then
    echo "Required GemStone path is missing: $required_path" >&2
    exit 2
  fi
done

if ! id -u "$gemstone_user" >/dev/null 2>&1; then
  echo "Linux account $gemstone_user does not exist; run bootstrap.sh first." >&2
  exit 2
fi

install -d -o root -g "$gemstone_group" -m 0750 "$configuration_root"

if [[ ! -e "$marker_file" ]]; then
  answers_file="$(mktemp)"
  trap 'rm -f -- "$answers_file"' EXIT
  cat >"$answers_file" <<ANSWERS
GSUSER="$gemstone_user"
GSGROUP="$gemstone_group"
GSKEY=""
GSLOCKDIR="$gemstone_global_dir"
UPDATE_SERVICES="y"
LDINAME="gs64ldi"
LDIPORT="50377"
OOM_PROTECT="y"
LOGIND_PROTECT="y"
ANSWERS

  GEMSTONE="$gemstone_home" \
    "$gemstone_home/install/doconfiguregs" "$answers_file"
  install -o root -g root -m 0644 /dev/null "$marker_file"
fi

if [[ ! -e "$gemstone_data/extent0.dbf" ]]; then
  install -d -o "$gemstone_user" -g "$gemstone_group" -m 0750 "$gemstone_data"
  runuser -u "$gemstone_user" -- \
    env GEMSTONE="$gemstone_home" GEMSTONE_GLOBAL_DIR="$gemstone_global_dir" \
    "$gemstone_home/install/createNewGemStoneRepository" "$gemstone_data"
fi

readonly executable_config="$gemstone_data/gemstone_data.conf"
if ! grep -q '^# SaraNutri small-droplet overrides$' "$executable_config"; then
  cat >>"$executable_config" <<'CONFIG'

# SaraNutri small-droplet overrides
SHR_PAGE_CACHE_SIZE_KB = 128MB;
GEM_TEMPOBJ_CACHE_SIZE = 32MB;
STN_MAX_SESSIONS = 20;
STN_CACHE_WARMER_ARGS = "";
CONFIG
fi

if ! grep -q '^STN_LISTENING_ADDRESSES = "127.0.0.1";$' "$executable_config"; then
  printf '%s\n' 'STN_LISTENING_ADDRESSES = "127.0.0.1";' >>"$executable_config"
fi

chown -R "$gemstone_user:$gemstone_group" "$gemstone_data"
chmod 0750 "$gemstone_data"
loginctl enable-linger "$gemstone_user"

install -o root -g root -m 0644 \
  "$script_directory/saranutri-stone.service" \
  /etc/systemd/system/saranutri-stone.service
install -o root -g root -m 0644 \
  "$script_directory/saranutri-netldi.service" \
  /etc/systemd/system/saranutri-netldi.service

systemctl daemon-reload
systemctl enable saranutri-stone.service saranutri-netldi.service
systemctl start saranutri-stone.service
systemctl start saranutri-netldi.service

echo "GemStone repository 'gs64stone' is configured and running."
