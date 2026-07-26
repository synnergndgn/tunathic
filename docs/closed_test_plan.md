# Internal and Closed Test Plan

## Phase 1: Internal Testing

1. Lock package ID, version code, Play App Signing choice, and upload-key backup.
2. Build, sign, verify, and hash one release AAB.
3. Complete Play policy declarations and listing with the exact AAB in scope.
4. Distribute to a small trusted device matrix through Internal Testing.
5. Run the full physical/offline checklist and fix only release blockers.
6. Record build `0.2.0+1`, commit, AAB SHA-256, devices, Android/API versions,
   dates, and results.

Promote the same verified artifact to Closed Testing when practical; if rebuilt
or versioned, repeat signer/hash/manifest/smoke checks.

## Phase 2: Closed Testing

- Recruit testers across recent and older supported Android versions, different
  manufacturers, phone sizes, microphone hardware, and wired/Bluetooth audio
  routes where available.
- Give testers a concise scope: Tuner, Metronome, BPM Tap, Chords, Scales,
  Fretboard, Circle, offline behavior, EN/TR, and layout.
- Tell testers Coming Soon items are intentionally unavailable.
- Use one publisher-controlled feedback channel with no request for unnecessary
  personal data.
- Triage by severity: release blocker, functional regression, device-specific,
  accessibility/localization, usability, or future enhancement.
- Associate every report with app build, Android version, and device model.
- Use a deliberate update cadence. Every uploaded fix gets a greater version
  code, release notes, artifact hash, and focused regression pass.
- Do not reset a required continuous opt-in window casually; check Play Console
  status before changing tracks or tester configuration.

## Account-specific production-access requirement

Google currently states that **personal developer accounts created after
13 November 2023** must run a closed test with at least **12 testers opted in
continuously for the last 14 days** before applying for production access.
Internal testing is optional and has no such entry requirement. This does not
apply automatically to every account.

Official source:
https://support.google.com/googleplay/android-developer/answer/14151465

`VERIFY IN CURRENT PLAY CONSOLE`: confirm the developer account type, creation
date, dashboard requirement, tester count, continuous opt-in state, and
production-access application wording.

## Tester communication

Provide:

- app name and exact version/build;
- opt-in and install links;
- known scope and Coming Soon exclusions;
- microphone permission reason and local-only processing statement;
- test window and update expectations;
- feedback template and channel; and
- safety note not to share recordings, credentials, or personal information.

## Exit criteria

- No open release blocker or data/privacy mismatch.
- Tuner and Metronome lifecycle cleanup passes on physical release builds.
- Ready features pass offline on the target device matrix.
- Policy/store declarations match the final AAB.
- Required tester period and production-access criteria, if applicable, are
  evidenced in Play Console.
