# SaraNutri

SaraNutri is a nutrition-management system built with GemStone/S 64 Bit for
the domain, persistence, and application services, and Flutter for the client.

## Repository layout

- `backend/gemstone/`: GemStone source and repeatable Topaz load scripts.
- `frontend/`: Flutter application. The Flutter SDK is not installed locally yet.
- `deploy/`: production service, reverse-proxy, and release scripts.
- `docs/`: architecture and development conventions.

## Deployment

The production workflow builds the Flutter web client and deploys the client
and GemStone source to a single DigitalOcean Droplet over SSH. The first push
only runs CI until the GitHub deployment variables are configured. See
[`docs/deployment.md`](docs/deployment.md) for the one-time server and GitHub
setup.

## Source of truth

Git tracks the files under `backend/gemstone/src/`. The GemStone extent and
Jasper's `.gemstone/` class mirror are runtime artifacts and are intentionally
not versioned. A change is complete only after its source is committed to Git
and loaded into the target stone.
