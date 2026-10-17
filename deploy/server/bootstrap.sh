#!/usr/bin/env bash
set -Eeuo pipefail

readonly deploy_user="saranutri"
readonly deploy_group="saranutri"
readonly deploy_root="/opt/saranutri"
readonly configuration_root="/etc/saranutri"
readonly service_name="saranutri-api.service"
readonly stone_service_name="saranutri-stone.service"
readonly netldi_service_name="saranutri-netldi.service"
readonly public_key_path="${1:-}"
readonly script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

if [[ -z "$public_key_path" || ! -r "$public_key_path" ]]; then
  echo "Usage: bootstrap.sh PUBLIC_KEY_PATH" >&2
  exit 2
fi

for required_file in \
  "$script_directory/$service_name" \
  "$script_directory/$stone_service_name" \
  "$script_directory/$netldi_service_name" \
  "$script_directory/environment.example" \
  "$script_directory/sshd-saranutri.conf"; do
  if [[ ! -r "$required_file" ]]; then
    echo "Required bootstrap file is missing: $required_file" >&2
    exit 2
  fi
done

if ! id -u "$deploy_user" >/dev/null 2>&1; then
  adduser --disabled-password --gecos '' "$deploy_user"
fi

install -d -o root -g "$deploy_group" -m 0775 "$deploy_root"
install -d -o "$deploy_user" -g "$deploy_group" -m 0755 \
  "$deploy_root/releases"
install -d -o root -g "$deploy_group" -m 0750 \
  "$configuration_root"
install -d -o "$deploy_user" -g "$deploy_group" -m 0700 \
  "/home/$deploy_user/.ssh"
install -o "$deploy_user" -g "$deploy_group" -m 0600 \
  "$public_key_path" "/home/$deploy_user/.ssh/authorized_keys"

install -o root -g root -m 0644 \
  "$script_directory/$service_name" "/etc/systemd/system/$service_name"
install -o root -g root -m 0644 \
  "$script_directory/$stone_service_name" "/etc/systemd/system/$stone_service_name"
install -o root -g root -m 0644 \
  "$script_directory/$netldi_service_name" "/etc/systemd/system/$netldi_service_name"
install -o root -g root -m 0644 \
  "$script_directory/sshd-saranutri.conf" \
  "/etc/ssh/sshd_config.d/00-saranutri.conf"

if [[ ! -e "$configuration_root/environment" ]]; then
  install -o root -g "$deploy_group" -m 0640 \
    "$script_directory/environment.example" "$configuration_root/environment"
fi

printf '%s\n' \
  "$deploy_user ALL=(root) NOPASSWD: /usr/bin/systemctl restart $service_name, /usr/bin/systemctl stop $service_name" \
  > "/etc/sudoers.d/$deploy_user-deploy"
chmod 0440 "/etc/sudoers.d/$deploy_user-deploy"
visudo --check --file="/etc/sudoers.d/$deploy_user-deploy"

systemctl daemon-reload
systemctl enable "$stone_service_name" "$netldi_service_name" "$service_name"
sshd -t
systemctl reload ssh

echo "SaraNutri server bootstrap completed."
