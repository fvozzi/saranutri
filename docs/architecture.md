# Architecture

## Runtime boundaries

| Component | Responsibility |
| --- | --- |
| GemStone/S 64 Bit | Domain model, persistence, transactions, application services |
| WebGS HTTP API | JSON, routing, and OpenAPI contract between GemStone services and mobile clients |
| Flutter | Mobile and web user interface |

The Flutter client does not connect directly to GemStone. It will use an
authenticated HTTP API implemented with WebGS. WebGS is pinned as a Git
submodule under `backend/gemstone/vendor/WebGS`.

WebGS is started on a private network port during development. Production
traffic must pass through a reverse proxy that terminates TLS and applies
authentication, request limits, and audit logging. Do not expose a WebGS port
directly to the Internet.

## GemStone source layout

- `SaraNutri-Core`: application-wide concepts and configuration.
- `SaraNutri-Domain`: business entities and rules.
- `SaraNutri-API`: API adapters, introduced when the API contract exists.

The source files use Topaz/Jasper `.gs` syntax. They can be loaded in order
with `backend/gemstone/scripts/load.topaz` from a checkout available on the
GemStone VM.

`SNApi` is the first WebGS adapter. It owns HTTP routing and serialization;
domain classes do not know about requests, responses, JSON, or Flutter.

## Git workflow

1. Create or change a class in the tracked source tree.
2. Load it into a development stone and run focused checks.
3. Commit the source and load script change together.
4. Promote the same commit to other stones; do not copy extents between
   environments as a deployment mechanism.

Jasper's `.gemstone/` directory is useful for browsing and editing live
classes, but it is not a repository. Before committing a live edit, export or
copy it into `backend/gemstone/src/`.
