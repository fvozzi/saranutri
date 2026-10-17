#!/usr/bin/env bash
set -Eeuo pipefail

readonly environment_file="${SARANUTRI_ENV_FILE:-/etc/saranutri/environment}"

set -a
# shellcheck disable=SC1090
source "$environment_file"
set +a

export PATH="$GEMSTONE/bin:$PATH"

printf 'HOME=%s\n' "$HOME"
printf 'GEMSTONE=%s\n' "$GEMSTONE"
printf 'GEMSTONE_GLOBAL_DIR=%s\n' "$GEMSTONE_GLOBAL_DIR"
id
ls -ld "$GEMSTONE_GLOBAL_DIR" "$GEMSTONE_GLOBAL_DIR/locks" \
  "$HOME" "$HOME/.topazini"
gslist -clv

topaz -lq <<'TOPAZ'
errorCount
iferr 1 stk
iferr 2 abort
iferr 3 logout
iferr 4 exit 1
login
logout
exit 0
TOPAZ
