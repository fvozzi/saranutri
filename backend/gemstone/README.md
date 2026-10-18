# GemStone backend

The files in `src/` are the versioned GemStone source. They use the same
Topaz syntax Jasper exports for a class. WebGS is a version-pinned Git
submodule in `vendor/WebGS`.

To prepare a development stone, install WebGS once and then load SaraNutri
from a checkout on the VM:

```smalltalk
input scripts/install-webgs.topaz
input scripts/load.topaz
```

For an unattended first-time production setup, run Topaz from
`vendor/WebGS/src` with `../../../scripts/install-webgs-production.topaz` as
its input. WebGS includes source files relative to that directory. The script
logs in using the protected server-side `.topazini`, installs WebGS, commits,
and exits on errors.

To load only the initial application and patient domain classes, without the
WebGS dependency, use:

```smalltalk
input scripts/load-minimal.topaz
```

`SNApi runHttpOnPort: 8888` starts the development API. Verify it locally on
the VM before exposing it through a reverse proxy. Keep that expression
running in a dedicated Topaz or IDE session while the Flutter client is in use.

The API exposes:

- `GET /health`
- `POST /sessions`
- `GET /patients` (professional)
- `POST /patients` (professional)
- `GET /appointments` (professional or the authenticated patient)
- `POST /appointments` (professional)
- `GET /openapi.json`
- `GET /docs`

Except for health and session creation, API routes require an
`Authorization: Bearer <accessToken>` header. Sessions expire after twelve
hours. Passwords are stored as salted, iterated SHA-256 digests; raw passwords
are never persisted.

Accounts are provisioned from a trusted GemStone session rather than through a
public sign-up endpoint. For example, replace the example values while running
the following in an authenticated Topaz or IDE session:

```smalltalk
| application patient |
application := SNApplication current.
application
  addProfessionalNamed: 'Professional name'
  email: 'professional@example.com'
  password: 'replace-with-a-strong-password'.
patient := application patients first.
application
  addPatientUserFor: patient
  email: 'patient@example.com'
  password: 'replace-with-a-strong-password'.
System commitTransaction
```

Patient creation validates and normalizes names in `SNPatient`; appointment
assignment resolves the persisted patient and enforces the professional role
inside `SNApplication`. Every mutation commits before returning HTTP 201.

`SNAppointment` models a scheduled appointment for an `SNPatient`. Its initial
state is `#scheduled`; the domain object validates both the patient and the
scheduled `DateAndTime`. Professionals see all appointments, while patient
accounts only receive appointments associated with their patient profile.

The loaders commit only after every listed source file has been processed and
all loaded SUnit suites pass. Use a dedicated deployment user for
non-development environments and do not place credentials in this repository.

Automated production loads use `scripts/deploy.topaz`. It logs in with the
server account's protected `.topazini`, loads the same source list, and exits
with an error when Topaz reports a failure. The DigitalOcean setup and release
workflow are documented in [`../../docs/deployment.md`](../../docs/deployment.md).

## SUnit tests

Backend tests live under `src/SaraNutri-Tests/` and are loaded by both loader
scripts. Jasper discovers `TestCase` subclasses and their `test*` methods in VS
Code's Testing view. After loading the source, choose **Refresh SUnit Tests**
and run `SNApplicationTest` or one of its individual methods.

`SNApplication current` is the persistent application root. It stores the root
under `#SaraNutriApplication` in `UserGlobals`; changes to its patients become
persistent when the surrounding application/API transaction commits.
