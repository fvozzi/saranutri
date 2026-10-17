#!/usr/bin/env bash
set -Eeuo pipefail

readonly gemstone_home="${GEMSTONE:-/usr/lib/x86_64-linux-gnu/gemstone/3.7.6}"
readonly gemstone_global_dir="${GEMSTONE_GLOBAL_DIR:-/opt/gemstone}"
readonly gemstone_user="saranutri"
readonly configuration_root="/etc/saranutri"
readonly credentials_file="$configuration_root/gemstone-credentials"
readonly marker_file="$configuration_root/gemstone-security-configured"
readonly topazini_file="/home/$gemstone_user/.topazini"

if [[ $EUID -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

if [[ -e "$marker_file" ]]; then
  echo "GemStone credentials are already secured."
  exit 0
fi

install -d -o root -g "$gemstone_user" -m 0750 "$configuration_root"
umask 077

if [[ ! -e "$credentials_file" ]]; then
  data_curator_password="$(openssl rand -hex 24)"
  system_user_password="$(openssl rand -hex 24)"
  gc_user_password="$(openssl rand -hex 24)"
  application_password="$(openssl rand -hex 24)"

  {
    printf 'DATA_CURATOR_PASSWORD=%s\n' "$data_curator_password"
    printf 'SYSTEM_USER_PASSWORD=%s\n' "$system_user_password"
    printf 'GC_USER_PASSWORD=%s\n' "$gc_user_password"
    printf 'APPLICATION_USER=%s\n' 'SaraNutri'
    printf 'APPLICATION_PASSWORD=%s\n' "$application_password"
  } >"$credentials_file"
  chown root:root "$credentials_file"
  chmod 0600 "$credentials_file"
fi

# shellcheck disable=SC1090
source "$credentials_file"

topaz_input="$(mktemp)"
topaz_output="$(mktemp)"
trap 'rm -f -- "$topaz_input" "$topaz_output"' EXIT
cat >"$topaz_input" <<TOPAZ
errorCount
iferr 1 stk
iferr 2 abort
iferr 3 logout
iferr 4 exit 1
set user DataCurator pass swordfish gems gs64stone
login
run
| applicationUser |
applicationUser := AllUsers
  addNewUserWithId: '$APPLICATION_USER'
  password: '$APPLICATION_PASSWORD'
  createNewSecurityPolicy: true.
applicationUser
  addPrivilege: #CodeModification;
  addPrivilege: #UserPassword.
(AllUsers userWithId: 'SystemUser') password: '$SYSTEM_USER_PASSWORD'.
(AllUsers userWithId: 'GcUser') password: '$GC_USER_PASSWORD'.
(AllUsers userWithId: 'DataCurator') password: '$DATA_CURATOR_PASSWORD'.
System commitTransaction
%
logout
exit 0
TOPAZ

if ! runuser -u "$gemstone_user" -- \
  env GEMSTONE="$gemstone_home" GEMSTONE_GLOBAL_DIR="$gemstone_global_dir" \
  "$gemstone_home/bin/topaz" -lq <"$topaz_input" >"$topaz_output" 2>&1; then
  install -o root -g root -m 0600 "$topaz_output" \
    "$configuration_root/gemstone-security-error.log"
  echo "GemStone security setup failed; inspect the root-only error log." >&2
  exit 1
fi

cat >"$topazini_file" <<TOPAZINI
set user $APPLICATION_USER pass $APPLICATION_PASSWORD gems gs64stone
TOPAZINI
chown "$gemstone_user:$gemstone_user" "$topazini_file"
chmod 0600 "$topazini_file"

install -o root -g root -m 0644 /dev/null "$marker_file"
echo "GemStone administrative passwords were rotated and the application user was created."
