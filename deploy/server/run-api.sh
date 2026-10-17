#!/usr/bin/env bash
set -Eeuo pipefail

readonly environment_file="${SARANUTRI_ENV_FILE:-/etc/saranutri/environment}"

if [[ -r "$environment_file" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$environment_file"
  set +a
fi

if [[ -n "${GEMSTONE:-}" ]]; then
  export PATH="$GEMSTONE/bin:$PATH"
fi

if ! command -v topaz >/dev/null 2>&1; then
  echo "topaz is not available; configure GEMSTONE in $environment_file" >&2
  exit 1
fi

readonly cache_name="${GEMSTONE_CACHE_NAME:-WebGS_Server}"

if [[ ! "$cache_name" =~ ^[A-Za-z0-9_.-]+$ ]]; then
  echo "GEMSTONE_CACHE_NAME contains unsupported characters." >&2
  exit 1
fi

exec topaz -lq <<TOPAZ
errorCount
iferr 1 stk
iferr 2 abort
iferr 3 logout
iferr 4 exit 1
set cachename $cache_name
login
run
Log instance logTypes: #(#'startup' #'warning' #'error').
SNApi runHttpOnPort: 8888
%
TOPAZ
