# Flutter client

This directory contains two Flutter web surfaces:

- `/` is the public SV Nutrition site.
- `/app` is the SaraNutri patient application backed by the GemStone HTTP API.

The frontend intentionally has no GemStone credentials and never connects to
the database directly. The API owns patient validation and commits new patients
to `SNApplication current`.

The UI supports English, Spanish, and Portuguese. Flutter selects the system
locale by default, and the language menu in the app bar allows users to switch
languages while the app is running. Translations live in `lib/l10n` as ARB
files; update all three locale files together when adding UI copy.

Run the client with:

```sh
cd frontend
flutter pub get
flutter test
flutter run -d chrome
```

The web host must rewrite direct requests such as `/app` to `index.html` so
Flutter can restore that route.

The default API URL is `http://gemstone.mshome.net:8888`. Override it without
changing source code when needed:

```sh
flutter run -d chrome \
  --dart-define=SARANUTRI_API_URL=http://your-gemstone-host:8888
```

The production build uses the same-origin `/api` path. Caddy strips that prefix
and forwards requests to WebGS, so the browser never connects to port 8888
directly.

Flutter generates the localization classes during builds. You can also run
`flutter gen-l10n` explicitly after changing the ARB files.
