# Current Milestone: Phase 1C — Application Polish

Phase 1C turns the existing Foundation, BPM Tap, and Core Metronome into a coherent, branded, accessible Android application shell. It does not add a new music tool or complete all of Phase 1.

## In scope

- A grouped dashboard with prominent BPM Tap and Metronome entries
- Settings sections for appearance, interaction, and application information
- A persisted, default-on global haptic-feedback preference
- An injectable haptic boundary used only for meaningful direct interactions
- Localized About and Privacy screens
- Flutter’s standard open-source license page
- Runtime package-version display through an injectable package-information boundary
- Centralized color, spacing, radius, typography, elevation, and motion tokens
- Navigation, feedback, accessibility, and responsive-layout refinements
- Minimal GitHub Actions verification for pushes and pull requests to `main`
- Application-shell, haptic, navigation, version, responsive, and regression tests
- Product version `0.2.0+1`, reflecting a pre-1.0 application with two working tools

## Dashboard hierarchy

The dashboard retains every planned tool without an essential carousel. It groups tools into Practice, Theory and Reference, and Training. Metronome and BPM Tap appear first and use stronger visual emphasis; Guitar Tuner and every remaining unfinished tool remain clearly marked Coming Soon.

## Interaction and feedback

Haptic feedback is enabled by default and stored locally with other application preferences. Flutter’s platform haptic API sits behind `HapticFeedbackOutput` and `AppHaptics`, allowing tests to replace hardware behavior. Subtle feedback accompanies direct taps, start/stop, applying BPM Tap, reset, navigation, and important selections. Timers, passive changes, sliders, and individual Metronome beats never trigger haptics.

Inline content communicates ongoing screen state, SnackBars acknowledge brief user-triggered results such as applying a BPM estimate, and full error presentation is reserved for a screen that cannot function. Technical details remain in `AppLogger`.

## Privacy and application information

The in-app Privacy screen and `docs/PRIVACY_POLICY_DRAFT.md` describe the current implementation: BPM Tap sessions remain in memory, preferences stay local, and there is no microphone permission, recording, account, advertising, analytics, Tunathic backend, upload, or GUNDEV data collection. The draft must change before future data-affecting features ship.

`package_info_plus` reads the installed version once during bootstrap. Settings, About, and the standard Flutter license page consume the application-owned `ApplicationInfo` value rather than calling the package from widgets.

## Out of scope

- Guitar Tuner, microphone access, pitch detection, recording, or DSP
- New music tools or additional Metronome capabilities
- Native audio scheduling or background playback
- Advertisements, analytics, accounts, backend, cloud, purchases, or synchronization
- App icon, adaptive icon, splash branding, signing, deployment, or store publishing

## Completion criteria

- Existing BPM Tap and Metronome behavior remains covered and operational.
- Dashboard, Settings, About, Privacy, licenses, and version metadata are localized and navigable with natural Android back behavior.
- Haptics persist, honor the disabled preference, and remain absent from passive/timing-driven behavior.
- Representative narrow, common, large, tablet, and large-text layouts avoid overflow in automated coverage where practical.
- Formatting checks, analysis, all tests, and an Android debug APK build pass.
- CI performs dependency resolution, formatting verification, analysis, and tests without secrets or deployment.

## Known limitations

- The application is not Play Store ready; privacy, store disclosure, signing, brand assets, and release work remain.
- Metronome playback is foreground-only and not sample-accurate. Millisecond-scale scheduler, platform-channel, buffering, or device latency jitter may remain on some Android devices.
- The rare stutter observed on an earlier physical Android test is not declared resolved without repeat device validation.
- Haptic strength and availability depend on Android device hardware and system behavior.
- No physical Android device was connected during the latest automated validation unless separately reported.
