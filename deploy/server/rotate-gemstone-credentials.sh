#!/usr/bin/env bash
set -Eeuo pipefail

readonly gemstone_home="${GEMSTONE:-/usr/lib/x86_64-linux-gnu/gemstone/3.7.6}"
readonly gemstone_global_dir="${GEMSTONE_GLOBAL_DIR:-/opt/gemstone}"
readonly gemstone_user="saranutri"
readonly credentials_file="/etc/saranutri/gemstone-credentials"
readonly topazini_file="/home/$gemstone_user/.topazini"

if [[ $EUID -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

if [[ ! -r "$credentials_file" ]]; then
  echo "GemStone credentials have not been initialized." >&2
  exit 2
fi

umask 077
# shellcheck disable=SC1090
source "$credentials_file"

new_data_curator_password="$(openssl rand -hex 24)"
new_system_user_password="$(openssl rand -hex 24)"
new_gc_user_password="$(openssl rand -hex 24)"
new_application_password="$(openssl rand -hex 24)"
topaz_input="$(mktemp)"
topaz_output="$(mktemp)"
credentials_staging="$(mktemp)"
trap 'rm -f -- "$topaz_input" "$topaz_output" "$credentials_staging"' EXIT

cat >"$topaz_input" <<TOPAZ
errorCount
iferr 1 stk
iferr 2 abort
iferr 3 logout
iferr 4 exit 1
set user DataCurator pass $DATA_CURATOR_PASSWORD gems gs64stone
login
run
(AllUsers userWithId: '$APPLICATION_USER') password: '$new_application_password'.
(AllUsers userWithId: 'SystemUser') password: '$new_system_user_password'.
(AllUsers userWithId: 'GcUser') password: '$new_gc_user_password'.
(AllUsers userWithId: 'DataCurator') password: '$new_data_curator_password'.
System commitTransaction
%
logout
exit 0
TOPAZ

if ! runuser -u "$gemstone_user" -- \
  env GEMSTONE="$gemstone_home" GEMSTONE_GLOBAL_DIR="$gemstone_global_dir" \
  "$gemstone_home/bin/topaz" -lq <"$topaz_input" >"$topaz_output" 2>&1; then
  install -o root -g root -m 0600 "$topaz_output" \
    /etc/saranutri/gemstone-credential-rotation-error.log
  echo "GemStone credential rotation failed; inspect the root-only error log." >&2
  exit 1
fi

{
  printf 'DATA_CURATOR_PASSWORD=%s\n' "$new_data_curator_password"
  printf 'SYSTEM_USER_PASSWORD=%s\n' "$new_system_user_password"
  printf 'GC_USER_PASSWORD=%s\n' "$new_gc_user_password"
  printf 'APPLICATION_USER=%s\n' "$APPLICATION_USER"
  printf 'APPLICATION_PASSWORD=%s\n' "$new_application_password"
} >"$credentials_staging"
install -o root -g root -m 0600 "$credentials_staging" "$credentials_file"

printf 'set user %s pass %s gems gs64stone\n' \
  "$APPLICATION_USER" "$new_application_password" >"$topazini_file"
chown "$gemstone_user:$gemstone_user" "$topazini_file"
chmod 0600 "$topazini_file"

echo "GemStone credentials were rotated without writing secrets to command output."
