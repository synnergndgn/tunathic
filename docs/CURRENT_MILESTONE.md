# Current Milestone: Phase 5B – Repertoire and Internal Test Release

Tunathic adds the Repertoire: user-authored song sheets with chords, semitone
transposition, and hands-free auto-scroll. The milestone keeps every existing
tool intact, keeps the application offline, and prepares a Google Play Internal
Testing upload. It does not create signing keys, make Play Console decisions,
upload artifacts, or start any other planned tool.

## Release scope

Ready:

- Guitar Tuner
- native low-latency Metronome
- BPM Tap
- Repertoire (offline song sheets with transposition and auto-scroll)
- Chord Library
- Scale Library
- Interactive Fretboard
- Circle of Fifths
- Interval Trainer (offline visual theory practice)
- Settings, About, Privacy, and open-source licenses

Coming Soon and non-interactive:

- Ear Training
- Chord Finder
- Capo Calculator

Debug-only:

- `/debug/tuner-diagnostics`, registered only when `kDebugMode` is true
- local developer logs and diagnostic tools under `tool/`

No internal/development-only surface is intentionally exposed in release UI.

## Repertoire scope

- Songs are written or pasted in the app. There is no file import, no sharing,
  no bundled song content, and no network fetch.
- ChordPro bracket text is the stored format. A pasted chart with chords above
  the lyrics is converted once, on save, so a chord stays attached to its
  syllable and printed chord width can never break alignment.
- Chords can be placed by tapping a word instead of typing brackets. The editor
  therefore asks for lyrics alone, and saving a new song opens chord placement
  directly, which is the order performers actually work in. A chord chosen while the chart is transposed is converted
  back to the written key before it is stored.
- Transposition covers -11…+11 semitones. Automatic spelling follows the
  transposed reference key, with explicit sharp and flat overrides.
- Auto-scroll runs at ten steady speed levels, stops at the end of the sheet,
  and yields to a manual drag.
- Song text, transposition, and scroll speed persist locally per song.
- The display is kept awake while a sheet is open and released on leaving it.
  This uses the standard Android keep-screen-on window flag through
  `wakelock_plus`, adds no manifest permission, and applies only in the
  foreground, so the single-runtime-permission baseline below is unchanged.

The song list, lyrics, and chords are user-supplied content. Tunathic ships no
song catalog and provides no way to obtain one.

## Locked baseline

- Android application ID and namespace: `dev.gundev.tunathic`
- app display name: `Tunathic`
- Flutter package: `tunathic`
- version: `0.3.0+4`
- minimum SDK: API 24
- target SDK: API 36
- compile SDK: API 36
- supported release ABIs: Android arm32, arm64, and x86_64 as emitted by Flutter
- only release runtime permission: `android.permission.RECORD_AUDIO`

The application ID is brand-consistent and suitable for long-term use. It must
be treated as permanent once the app is created in Play Console. Version code 1
was reserved for the first closed test; every later Play upload must use a
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
- Repertoire content stays on the device, is never uploaded or shared, and is
  disclosed in the privacy screen.
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
