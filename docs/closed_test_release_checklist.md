# Closed Test Release Checklist

## Source

- [ ] Branch is `release/closed-test`.
- [ ] Intended commit is recorded; worktree is clean except documented local
      files such as `.claude/settings.local.json`.
- [ ] No secrets, keystores, `key.properties`, tokens, or machine paths are
      tracked.
- [ ] Package ID `dev.gundev.tunathic` is explicitly approved before the first
      Play app/artifact is created.
- [ ] Debug tuner diagnostics remain guarded by `kDebugMode`.
- [ ] Coming Soon tools are visible, localized, and non-interactive.

## Quality

- [ ] `dart format .`
- [ ] `dart format --output=none --set-exit-if-changed .`
- [ ] `flutter gen-l10n`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build apk --debug`
- [ ] `flutter build apk --profile`
- [ ] Signed `flutter build apk --release` after upload credentials exist
- [ ] Signed `flutter build appbundle --release` after upload credentials exist
- [ ] Merged release manifest and AAB permissions inspected
- [ ] Native ABI/library contents and Oboe license inspected
- [ ] `git diff --check`

## Functional / physical

- [ ] Physical Android profile/release cold launch and navigation smoke
- [ ] Theme, EN/TR language, text scaling, and settings persistence
- [ ] Tuner auto-start/stable note/route/background cleanup
- [ ] Tuner stays visually still during silence; no “No signal detected” text
- [ ] Tuner reacts promptly when sound begins and settles without repeated UI
      updates when sound ends
- [ ] Tuner settings route changes Chromatic/preset and A4 (430–450 Hz), and
      the main screen reflects the result after Back
- [ ] Automatic/Manual state and manual target selection remain correct
- [ ] Microphone-denied state remains visible and retryable
- [ ] Android microphone indicator disappears after cleanup
- [ ] Metronome start/stop/BPM/signature/accent and smoke-session continuity
- [ ] Chords: open, barre, extended, alternatives, search
- [ ] Scales: root/type/enharmonics
- [ ] Fretboard: chord/scale modes and horizontal scroll
- [ ] Circle: key/mode and library handoffs
- [ ] Process kill/relaunch; no live tuner/metronome restoration
- [ ] Wi-Fi and mobile data disabled; every Ready feature works
- [ ] Narrow phone, large text, TalkBack/semantics, contrast, and touch targets
- [ ] No raw exception, stack trace, debug ID, or noisy/sensitive release log

## Policy and store

- [ ] Privacy effective date and public contact supplied; policy legally
      reviewed and hosted over public HTTPS
- [ ] In-app and hosted privacy text match final behavior
- [ ] Data Safety reverified against exact final AAB/current form
- [ ] App Content answers reverified in current Play Console
- [ ] IARC content questionnaire completed without inventing a rating
- [ ] Target audience and any Families implications approved
- [ ] EN/TR listing copy pasted and re-counted
- [ ] Final 512×512 listing icon, 1,024×500 feature graphic, and screenshots
- [ ] Support/contact details supplied

## Signing and distribution

- [ ] Version code is greater than every previous Play upload
- [ ] Developer-controlled upload key created and backed up
- [ ] Play App Signing key strategy explicitly approved
- [ ] AAB signer/certificate verified
- [ ] AAB SHA-256 and size recorded
- [ ] Internal Testing smoke completed
- [ ] Closed Testing tester list, feedback channel, and owner ready
- [ ] Account-specific 12-testers/14-days requirement checked
- [ ] No artifact is uploaded until every applicable blocker is closed
