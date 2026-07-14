# Current Milestone: Phase 1A — BPM Tap

Phase 1A delivers the first functional practice tool: an offline, accessible BPM Tap experience built on the approved Foundation shell. Every other unfinished tool remains clearly labeled “Coming Soon”.

## In scope

- A dashboard route to the functional BPM Tap tool
- Monotonic tap timing with pure Dart calculation logic
- A rolling window of the latest eight valid intervals
- Median-centered outlier resistance
- A valid tempo range of 30–300 BPM
- Automatic session reset after three seconds of inactivity
- Riverpod-owned session state and reset behavior
- English and Turkish interface strings
- Accessible, one-handed interaction and responsive text layout
- Unit, controller, and widget interaction tests
- Algorithm and architecture documentation

## Out of scope

- Microphone permissions
- Recording
- Pitch detection
- DSP
- Functional tuner
- Functional metronome engine
- Chord or scale databases
- Ear training
- Interval training
- Advertisements
- Analytics
- Consent SDKs
- In-app purchases
- Accounts
- Backend
- Cloud synchronization

## Completion criteria

- Stable tapping at common tempos produces an accurate estimate.
- Invalid intervals and isolated timing spikes do not destabilize the result.
- The dashboard, reset action, inactivity behavior, themes, and both supported languages work on Android without layout overflow.
- Formatting, static analysis, and all tests pass.
