# Google Play Data Safety Draft

> Re-verify this declaration against the exact final AAB and current Google
> Play Data Safety form before submission.

This is a repository draft, not a submitted declaration. It describes
Tunathic `0.2.0+1` after source, dependency, manifest, and behavior inspection.
Current Play Console wording may differ; answer the form as it exists at the
time of submission.

## High-level draft

- Does the app collect or share any required user data types with the
  developer or third parties? **No, based on the current release behavior.**
- Is all user data encrypted in transit? **Not applicable to Tunathic app
  data because the release sends no app data over a network.**
- Can users request data deletion? **No developer-held user data or account
  exists.** Users can clear local preferences through Android app storage or
  uninstall the app.
- Does the app provide accounts? **No.**

Local access or ephemeral processing is documented below even where it is not
developer "collection" under the current form.

| Data / capability | App behavior | Collected by developer | Shared | Retention |
| --- | --- | --- | --- | --- |
| Microphone audio / voice or sound | Accessed only after Tuner Start; processed ephemerally on-device for pitch | No | No | Raw PCM is not stored; discarded during/at end of session |
| Pitch estimates and signal statistics | Derived locally and held in bounded runtime state | No | No | Cleared when session ends |
| Theme and language | Stored only in local app preferences | No | No | Until changed, app data is cleared, or app is uninstalled |
| Haptic preference | Stored only locally | No | No | Same as above |
| Metronome BPM, signature, accent, volume | Stored only locally | No | No | Same as above |
| Tuner preset, mode, manual string | Stored only locally | No | No | Same as above |
| BPM Tap timestamps and estimate | In-memory session state | No | No | Cleared with session/process |
| Chord, scale, fretboard, and circle selections | Runtime UI state; content is bundled | No | No | Not persisted as history |
| Location | Not accessed | No | No | Not applicable |
| Contacts | Not accessed | No | No | Not applicable |
| Photos, videos, files, storage, media | Not accessed | No | No | Not applicable |
| Device or other identifiers | Not accessed by app code for developer use | No | No | Not applicable |
| Account, name, email, user ID | No accounts or profile input | No | No | Not applicable |
| App interactions / diagnostics | No analytics or crash-reporting service | No | No | Local debug output only; not transmitted |
| Purchases / financial information | No purchase flow | No | No | Not applicable |

## Verification notes

- The release manifest contains `RECORD_AUDIO`, an app-specific AndroidX
  signature permission used to protect dynamic receivers, and no `INTERNET`
  permission. The signature permission does not expose user data.
- Debug and profile manifests add `INTERNET` for Flutter development tooling;
  they are not the Play release manifest.
- `record` supplies foreground PCM streaming. The app requests a byte stream,
  not file recording.
- `shared_preferences` stores the local scalar settings listed above.
- There is no analytics, ads, crash reporting, account, backend, HTTP client,
  or cloud dependency.
- Google Play and Android platform processing is outside the app's own data
  collection and must be considered under the current form's instructions.

## Submission owner checks

- `VERIFY IN CURRENT PLAY CONSOLE`: confirm whether ephemeral on-device
  microphone processing is represented only through the app's permission and
  privacy disclosures or requires a form-specific answer.
- Confirm the exact uploaded AAB has the permission and SDK inventory recorded
  in `docs/RELEASE_HARDENING_AUDIT.md`.
- Confirm no SDK, permission, network behavior, or feature changed after this
  draft.
