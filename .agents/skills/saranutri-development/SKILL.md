---
name: saranutri-development
description: Implement or review SaraNutri GemStone backend, API, and Flutter changes while preserving English source code, English-Spanish-Portuguese UI localization, and backend-owned business rules. Use for development work anywhere in this repository.
---

# SaraNutri Development

Apply these constraints to every SaraNutri implementation and review.

## Language

- Write all backend class names, method selectors, variables, comments, tests,
  and technical messages in English.
- Write all frontend identifiers, comments, tests, and non-user-facing strings
  in English.
- Keep API field names, error codes, and other machine-readable values in
  English. Do not use translated text as an API contract.

## User-facing localization

- Every label, button, heading, message, validation error, empty state,
  accessibility description, and other user-visible string must support
  English, Spanish, and Portuguese.
- In Flutter, use generated localization resources with ARB files such as
  `app_en.arb`, `app_es.arb`, and `app_pt.arb`. Do not hard-code user-visible
  text in widgets, dialogs, snack bars, or presentation controllers.
- Add or update the English, Spanish, and Portuguese entries together. Keep
  placeholders semantically equivalent across locales.
- Tests may select a locale explicitly, but must not make production widgets
  bypass localization.

## Object-oriented design style

- Follow Smalltalk-style object-oriented design in both GemStone Smalltalk and
  Flutter/Dart. Keep classes, methods, functions, and widgets small, focused,
  and named after one clear responsibility.
- Do not repeat code or knowledge. Reuse existing collaborators and extract
  shared behavior behind a meaningful method, object, or widget rather than
  copying an implementation.
- Prefer telling objects what to do over querying their state and deciding for
  them elsewhere. Keep behavior close to the object that owns the knowledge.
- Avoid using `nil` or `null` as a control-flow pattern. Prefer a Null Object,
  an explicit state/result type, or a polymorphic collaborator. Use nullable
  values only when absence is genuinely part of the domain or an external
  boundary, and normalize them as early as practical.
- Prefer polymorphism and double dispatch over `if`, `switch`, runtime type
  checks, or condition chains when behavior varies by object type or state.
  Simple guards and boundary validation remain appropriate when they express
  values rather than competing object behaviors.
- Follow *Smalltalk with Style* in GemStone code. Do not use `isKindOf:` unless
  a runtime class distinction is strictly necessary and no meaningful
  polymorphic protocol expresses the requirement. For textual and collection
  validation, send protocol messages such as `trimWhiteSpace`, `allSatisfy:`,
  and `Character>>isLetter` instead of asking for the receiver's class.
- Apply these design rules to frontend structure without moving business rules
  into Flutter; backend ownership of business behavior remains authoritative.

## Business-rule boundary

- Implement every business rule in GemStone Smalltalk on the backend. This
  includes domain invariants, eligibility, calculations, authorization,
  state transitions, and persistence decisions.
- Keep HTTP/WebGS routes and serializers as adapters. They may parse requests,
  invoke backend application or domain methods, and translate results, but
  must not become an alternate home for domain logic.
- Flutter may render state, collect input, manage navigation and transient UI
  state, format localized values, and perform purely syntactic input checks.
  It must not decide or duplicate business outcomes.
- Treat backend validation as authoritative. Return stable machine-readable
  error codes or structured results and localize their presentation in Flutter.
- The Flutter client must use the HTTP API; it must never connect directly to
  GemStone or contain GemStone credentials.

## Change workflow

1. Put new domain behavior and its focused tests in the GemStone backend.
2. Expose only the required operation or data through the API adapter.
3. Implement the Flutter presentation using localized resources and without
   reproducing the backend rule.
4. Test business outcomes on the backend and presentation, interaction, and
   locale behavior on the frontend.

Keep `backend/gemstone/src/` as the versioned source of truth. When backend
code changes, load and commit the same source in the target development stone;
do not treat Jasper's `.gemstone/` mirror as repository source.
