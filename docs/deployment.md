# DigitalOcean deployment

This deployment is intended for the current private, single-user MVP. Caddy
terminates HTTPS, requires one Basic Auth account for the entire site, serves
the Flutter web build, and proxies `/api/*` to WebGS. WebGS remains on port
8888 and must not be allowed through the public firewall.

The workflow tests and builds Flutter on GitHub, sends an immutable release to
the Droplet over SSH, loads the tracked GemStone source, switches the active
release symlink, restarts WebGS, and checks `/health`. It retains the five most
recent releases. A failed health check restores the previous release files,
although a GemStone code/data migration is not automatically reversible.

## 1. Prepare DNS and the Droplet

Create an Ubuntu Droplet with SSH-key authentication and backups enabled. Point
the production domain's `A`/`AAAA` records at the Droplet. Allow inbound TCP
ports 22, 80, and 443 in the DigitalOcean Cloud Firewall and/or UFW. Do not
allow port 8888.

Install and configure these server dependencies:

- GemStone/S 64 Bit and the production stone.
- Caddy 2.8 or later. The checked-in configuration uses `basic_auth`, which
  replaced the older `basicauth` directive in Caddy 2.8. Use Caddy's official
  stable Debian/Ubuntu repository rather than Ubuntu 24.04's older package.
- `curl`, `flock`, `sudo`, and `tar` (normally present on Ubuntu).

GemStone is licensed software and remains a server prerequisite; the workflow
does not download or install it. SaraNutri currently targets GemStone/S 64 Bit
3.7.6 Community Edition on Ubuntu x86_64.

## 2. Create the deployment account

Use one unprivileged Linux account for SSH deployments and the API service.
The repeatable bootstrap installs the deployment public key, creates the
required directories, installs the systemd unit, and grants only the service
restart permissions required by the release script. It also disables SSH
password authentication and restricts root login to public-key authentication:

```bash
sudo deploy/server/bootstrap.sh /path/to/saranutri-actions.pub
```

Use a dedicated GitHub Actions key for this command and keep the personal
administrative key separate. The bootstrap does not start the API because the
first release and GemStone configuration must exist first.

## 3. Configure GemStone for the service account

After installing the official `gemstone-server-3.7.6` package, run the
repository configuration script as root:

```sh
sudo deploy/server/configure-gemstone.sh
```

It creates the production data directory and the `gs64stone` repository,
applies conservative settings for the 1 GB Droplet, and installs and starts
the Stone and NetLDI systemd units. Both GemStone listeners are restricted to
loopback; NetLDI uses `127.0.0.1:50377`. The script also enables systemd linger
for the service account so logging out of SSH cannot remove GemStone's IPC
semaphores.

Rotate the built-in administrative passwords and create the least-privileged
application/deployment user once:

```sh
sudo deploy/server/secure-gemstone.sh
```

The generated secrets are stored only in
`/etc/saranutri/gemstone-credentials` with mode `0600`. The application login
is written to `/home/saranutri/.topazini`; neither file belongs in GitHub.
Run `rotate-gemstone-credentials.sh` as root whenever these credentials need
to be replaced; it updates GemStone and both protected files together.

Copy `deploy/server/environment.example` to
`/etc/saranutri/environment`, set the real GemStone paths, and keep the file
root-owned and group-readable:

```sh
sudo install -o root -g saranutri -m 0640 \
  deploy/server/environment.example /etc/saranutri/environment
```

The security script creates `/home/saranutri/.topazini` with mode `0600`. It
supplies the dedicated GemStone username, generated password, and stone name
to Topaz. Do not store those credentials in GitHub or this repository.

Before enabling automated deployment, sign in as `saranutri`, source the
environment file, and verify that `topaz -lq` can log in to the intended stone.
The generated `SaraNutri` GemStone user receives `CodeModification` for source
deployment and `UserPassword`; the API and deploy process do not run as
`DataCurator`.

Install the pinned WebGS dependency once in a new production Stone:

```sh
cd backend/gemstone/vendor/WebGS/src
topaz -lq < ../../../scripts/install-webgs-production.topaz
```

## 4. Verify the systemd service

The bootstrap installs and enables `saranutri-api.service`. It is started by
the first successful deployment, after the `current` release symlink exists.
Verify the installed unit before enabling deployment:

```sh
systemctl is-enabled saranutri-api.service
systemctl cat saranutri-api.service
```

## 5. Configure Caddy and the single private account

Generate a password hash interactively so the plaintext password is not placed
in shell history:

```sh
caddy hash-password
```

Copy `deploy/server/Caddyfile.example` to `/etc/caddy/Caddyfile`. Replace the
example domain, username, and password-hash placeholder. Then validate and
reload it:

```sh
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

Caddy obtains and renews the TLS certificate after DNS points to the Droplet
and ports 80/443 are reachable. The Basic Auth account is a temporary
deployment boundary, not an application user system. Keep the whole site
private until backend-owned authentication and authorization are implemented.

## 6. Configure the GitHub production environment

In the GitHub repository, create an Actions environment named `production`.
Optionally require manual approval. Add these repository variables:

| Variable | Example |
| --- | --- |
| `DEPLOY_HOST` | `203.0.113.10` or `saranutri.example.com` |
| `DEPLOY_PORT` | `22` |
| `DEPLOY_USER` | `saranutri` |
| `PRODUCTION_DOMAIN` | `saranutri.ar` |

Add these environment secrets:

| Secret | Value |
| --- | --- |
| `DEPLOY_SSH_PRIVATE_KEY` | Dedicated unencrypted Ed25519 private key |
| `DEPLOY_KNOWN_HOSTS` | Verified OpenSSH host-key line for the Droplet |

Obtain the host-key line with `ssh-keyscan`, but compare its fingerprint with
the key shown through the DigitalOcean console before saving it. This prevents
the workflow from blindly trusting a network-provided host key.

The workflow deliberately skips the deploy job while `DEPLOY_HOST` is absent,
so the initial push can run CI before the server is ready. After the variables
and secrets exist, every successful push to `main` deploys automatically. The
workflow can also be run manually from the Actions tab.

## 7. Verify and operate

After the first deployment:

```sh
systemctl status saranutri-api.service
journalctl -u saranutri-api.service -n 100 --no-pager
curl -u 'saranutri:YOUR_PASSWORD' https://saranutri.ar/api/health
```

Configure tested GemStone backups before storing real patient information.
Droplet backups help with disaster recovery, but they are not a substitute for
application-consistent GemStone backup and restore procedures.
