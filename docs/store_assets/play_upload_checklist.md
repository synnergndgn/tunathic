# Play Console Upload Checklist

Requirements below were current on 2026-07-27 per
`release_assets/google_play/README.md` and are unchanged in the older
`docs/store_asset_checklist.md`. **Play Console's own validator is
authoritative** — re-check immediately before upload.

Official sources:
- <https://support.google.com/googleplay/android-developer/answer/9866151>
- <https://developer.android.com/distribute/google-play/resources/icon-design-specifications>

---

## 1. Format gate

| Asset | Requirement | How to check |
| --- | --- | --- |
| Listing icon | 512×512, 32-bit PNG with alpha, sRGB, ≤ 1,024 KB, **full square**, **no rounded corners, no drop shadow** — Play masks at 30 % radius and adds its own shadow | `python design/store/validate_assets.py` |
| Feature graphic | 1024×500, JPEG or 24-bit PNG, **no alpha** | same |
| Screenshots | JPEG or 24-bit PNG, no alpha; each side 320–3,840 px; long side ≤ 2× short side; ≤ 8 MB; 2–8 per device type | same |
| Phone promo | ≥ 4 shots at ≥ 1,080 px, 16:9 or 9:16 | 1350×2400 ✓ |
| 7" / 10" tablet | ≥ 4 per type, 1,080–7,680 px | 1200×2133, 1600×2844 ✓ |

---

## 2. Content gate

- [ ] Light theme on **every** asset in a set. No dark captures mixed in.
- [ ] No cyan, teal or electric blue anywhere. The old identity is gone.
- [ ] Same device body, same canvas, same caption style across the whole set.
- [ ] Status bar cropped; gesture pill present and identical in every capture.
- [ ] No system permission dialog, no keyboard, no snackbar, no debug overlay,
      no diagnostics route, no emulator chrome.
- [ ] No label broken mid-word or truncated in a shipped shot. Both known cases
      (the dashboard dock, the metronome volume readout) were fixed in
      0.7.4 (14) — re-check after any layout change.
- [ ] Coming-soon tools (Ear Training, Chord Finder, Capo Calculator) are not a
      screenshot subject and are not named in any caption.
- [ ] No ratings, rankings, prices, install counts, "Best", "#1", "New", Play
      branding, or a call to action in any graphic. Play's asset rules forbid
      these.
- [ ] No accuracy, latency or certification claim: no cents figure, no "studio",
      no "zero latency", no "professional grade".
- [ ] Any shape-count claim re-verified on the shipping commit against
      `test/chord_library/guitar_shape_coverage_test.dart`.
- [ ] Musical notation identical between en-US and tr-TR; only interface
      language and caption differ.

---

## 3. Privacy gate

- [ ] Every capture uses synthetic, music-only state.
- [ ] No account, e-mail, username, file path, device identifier, API key,
      notification, or microphone-usage history visible.
- [ ] Nothing from the emulator's own data appears in the exported directory.

---

## 4. Build provenance

- [ ] Captures come from the **exact commit** being submitted.
- [ ] Build type recorded (profile, `flutter build apk --profile`).
- [ ] Version and build number recorded and matching `pubspec.yaml`.
- [ ] `versionCode` bumped for this upload — every release AAB gets uploaded, so
      the previous code is already consumed.

---

## 5. Upload order

1. App icon — the 512 PNG.
2. Feature graphic — the 1024×500 PNG.
3. Phone screenshots, en-US, filename order 01 → 08.
4. 7-inch tablet, en-US.
5. 10-inch tablet, en-US.
6. Add the tr-TR locale, then repeat 3–5 from the Turkish sets.
7. Fill in alt text for each screenshot where Play Console offers the field. The
   headline from `screenshot_plan.md` §3 is a good starting point.
8. Read Play Console's validation messages before publishing. They override this
   file.

---

## 6. After upload

- [ ] View the listing on a phone, in both light and dark system themes. The
      ivory icon and feature graphic sit on a dark Play surface in dark mode —
      confirm they still read.
- [ ] Check the icon at real launcher size, not just in Console.
- [ ] Confirm the store listing text still matches what the screenshots show
      (`docs/store_listing.md` is written against 0.7.1 — refresh the
      "What's New" block for the release you are actually shipping).
