# SaraNutri

SaraNutri is a nutrition-management system built with GemStone/S 64 Bit for
the domain, persistence, and application services, and Flutter for the client.

## Repository layout

- `backend/gemstone/`: GemStone source and repeatable Topaz load scripts.
- `frontend/`: Flutter application. The Flutter SDK is not installed locally yet.
- `docs/`: architecture and development conventions.

## Source of truth

Git tracks the files under `backend/gemstone/src/`. The GemStone extent and
Jasper's `.gemstone/` class mirror are runtime artifacts and are intentionally
not versioned. A change is complete only after its source is committed to Git
and loaded into the target stone.
