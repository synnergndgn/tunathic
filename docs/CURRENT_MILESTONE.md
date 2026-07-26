# Current Milestone: Phase 5A – Closed Test Release Hardening

Tunathic is under feature freeze for its first Google Play Internal and Closed
Testing release. This milestone prepares source, build configuration, policy
drafts, store copy, signing architecture, and reproducible quality gates. It
does not create signing keys, make Play Console decisions, upload artifacts, or
add product features.

## Release scope

Ready:

- Guitar Tuner
- native low-latency Metronome
- BPM Tap
- Chord Library
- Scale Library
- Interactive Fretboard
- Circle of Fifths
- Settings, About, Privacy, and open-source licenses

Coming Soon and non-interactive:

- Interval Trainer
- Ear Training
- Chord Finder
- Capo Calculator

Debug-only:

- `/debug/tuner-diagnostics`, registered only when `kDebugMode` is true
- local developer logs and diagnostic tools under `tool/`

No internal/development-only surface is intentionally exposed in release UI.

## Locked baseline

- Android application ID and namespace: `dev.gundev.tunathic`
- app display name: `Tunathic`
- Flutter package: `tunathic`
- version: `0.2.0+1`
- minimum SDK: API 24
- target SDK: API 36
- compile SDK: API 36
- supported release ABIs: Android arm32, arm64, and x86_64 as emitted by Flutter
- only release runtime permission: `android.permission.RECORD_AUDIO`

The application ID is brand-consistent and suitable for long-term use. It must
be treated as permanent once the app is created in Play Console. Version code 1
is retained for the first closed test; every later Play upload must use a
strictly greater build number.

## Hardening policy

- Release builds must fail unless local upload-key credentials are configured.
- A debug key must never sign an upload artifact.
- Production credentials, keystores, and `key.properties` stay outside Git.
- The release manifest has no Internet permission and the application has no
  analytics, ads, accounts, backend, cloud sync, or tracking.
- Microphone audio remains transient, local, unstored, and unshared.
- Ready tools must work offline; live tuner and metronome state is not
  persisted.
- Physical profile/release validation remains mandatory before upload.

## Required gates

Repository completion requires formatting, localization generation, static
analysis, the full test suite, debug/profile builds, expected release signing
gate checks, merged-manifest inspection, native-library inspection, secret
audit, and `git diff --check`.

Distribution remains blocked until the user supplies the privacy contact and
effective date, authorizes creation of an upload key, makes the Play App
Signing decision, completes physical release-mode and offline smoke tests,
verifies Play Console declarations, and produces final store assets.

See `docs/closed_test_release_checklist.md` for the operational gate and
`docs/RELEASE_HARDENING_AUDIT.md` for the inspected baseline.
