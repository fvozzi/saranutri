#!/usr/bin/env bash
set -Eeuo pipefail

readonly deploy_root="${SARANUTRI_DEPLOY_ROOT:-/opt/saranutri}"
readonly environment_file="${SARANUTRI_ENV_FILE:-/etc/saranutri/environment}"
readonly service_name="saranutri-api.service"

archive_path="${1:-}"
release_id="${2:-}"

if [[ -z "$archive_path" || -z "$release_id" ]]; then
  echo "Usage: deploy-release.sh ARCHIVE_PATH RELEASE_ID" >&2
  exit 2
fi

if [[ ! "$release_id" =~ ^[0-9a-f]{40,64}$ ]]; then
  echo "Release ID must be a full Git commit SHA." >&2
  exit 2
fi

if [[ "$deploy_root" != /* || "$deploy_root" == "/" ]]; then
  echo "SARANUTRI_DEPLOY_ROOT must be a specific absolute path." >&2
  exit 2
fi

if [[ ! -r "$archive_path" ]]; then
  echo "Release archive is not readable: $archive_path" >&2
  exit 2
fi

if [[ -r "$environment_file" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$environment_file"
  set +a
fi

if [[ -n "${GEMSTONE:-}" ]]; then
  export PATH="$GEMSTONE/bin:$PATH"
fi

for command_name in curl flock sudo systemctl tar topaz; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command is unavailable: $command_name" >&2
    exit 1
  fi
done

mkdir -p "$deploy_root/releases"
exec 9>"$deploy_root/releases/.deploy.lock"
if ! flock -n 9; then
  echo "Another SaraNutri deployment is already running." >&2
  exit 1
fi

readonly release_path="$deploy_root/releases/$release_id"
readonly staging_path="$deploy_root/releases/.${release_id}.partial.$$"
readonly temporary_link="$deploy_root/.current-${release_id}.$$"
previous_release=""

cleanup() {
  rm -rf -- "$staging_path"
  rm -f -- "$temporary_link"
  rm -f -- "$archive_path"
}
trap cleanup EXIT

if [[ -d "$release_path" ]]; then
  echo "Reusing previously prepared release $release_id"
else
  mkdir -p "$staging_path"
  tar -xzf "$archive_path" -C "$staging_path"

  for required_path in \
    "$staging_path/backend/gemstone/scripts/deploy.topaz" \
    "$staging_path/deploy/server/run-api.sh" \
    "$staging_path/frontend/build/web/index.html"; do
    if [[ ! -f "$required_path" ]]; then
      echo "Release is missing required file: $required_path" >&2
      exit 1
    fi
  done

  echo "Loading GemStone source for release $release_id"
  (
    cd "$staging_path/backend/gemstone"
    topaz -lq < scripts/deploy.topaz
  )

  mv "$staging_path" "$release_path"
fi

if [[ -L "$deploy_root/current" ]]; then
  previous_release="$(readlink -f "$deploy_root/current")"
fi

ln -s "$release_path" "$temporary_link"
mv -Tf "$temporary_link" "$deploy_root/current"

rollback() {
  echo "The API did not become healthy; restoring the previous release." >&2
  if [[ -n "$previous_release" && -d "$previous_release" ]]; then
    ln -s "$previous_release" "$temporary_link"
    mv -Tf "$temporary_link" "$deploy_root/current"
    sudo -n systemctl restart "$service_name" || true
  else
    rm -f -- "$deploy_root/current"
    sudo -n systemctl stop "$service_name" || true
  fi
}

if ! sudo -n systemctl restart "$service_name"; then
  rollback
  exit 1
fi

healthy=false
for _ in {1..15}; do
  if systemctl is-active --quiet "$service_name" \
    && curl --fail --silent --show-error \
    --max-time 2 http://127.0.0.1:8888/health >/dev/null; then
    healthy=true
    break
  fi
  sleep 2
done

if [[ "$healthy" != true ]]; then
  rollback
  exit 1
fi

find "$deploy_root/releases" \
  -mindepth 1 -maxdepth 1 -type d -not -name '.*' -printf '%T@ %p\n' \
  | sort -nr \
  | tail -n +6 \
  | cut -d' ' -f2- \
  | while IFS= read -r old_release; do
      if [[ -n "$old_release" && "$old_release" == "$deploy_root/releases/"* ]]; then
        rm -rf -- "$old_release"
      fi
    done

echo "SaraNutri release $release_id is healthy and active."
