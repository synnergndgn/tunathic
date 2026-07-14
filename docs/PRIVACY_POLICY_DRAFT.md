# Tunathic Privacy Policy Draft

**Status:** Product draft for the current Phase 2A prototype. This is not a final store-publishing policy and contains no invented legal contact details.

Tunathic – Guitar Toolkit is published by GUNDEV. The current application is designed to operate offline and keep its practice data on the user's device.

## Current data behavior

- BPM Tap sessions exist only in application memory. Tap timestamps and estimates are not saved as session history or uploaded.
- Theme, language, haptic-feedback, and Metronome preferences are stored locally on the device.
- Microphone permission is requested only after the user explicitly starts the Tuner Audio Prototype.
- Microphone capture runs only while that prototype is active in the foreground and stops on user request, backgrounding, route exit, or capture failure.
- Raw PCM and normalized samples are processed locally, frame by frame, in memory. They are not recorded to a file, retained as history, uploaded, or transmitted.
- Signal statistics are transient scalar values used by the prototype screen. They are not persisted or transmitted.
- Local debug diagnostics may contain requested or reported format, aggregate counters, lifecycle reasons, and technical failures. They never contain raw bytes or sample values.
- No account is required.
- The application contains no advertising or analytics SDK.
- Tunathic has no application backend in this release.
- The application sends no app data to GUNDEV servers.

Android displays system microphone indicators and controls permission according to the operating system. Platform services and the app-distribution provider may process technical information under their own policies; Tunathic does not add remote collection in this prototype.

## Future changes

This draft must be reviewed and updated before production tuner functionality, recording, advertising, analytics, accounts, cloud synchronization, purchases, a Tunathic backend, or any changed audio retention or transfer behavior is released.

## Publication status

This document describes the current implementation but does not claim Play Store readiness. Final publication requires legal review, effective-date and policy-hosting decisions, Android data-safety declarations, and any other store-required disclosures.
