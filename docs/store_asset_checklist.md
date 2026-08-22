# Store Asset Readiness Checklist

Dimensions below were verified against current official Google Play preview
asset guidance on 2026-07-26. Recheck before upload.

## Repository audit

| Asset | Current state | Release action |
| --- | --- | --- |
| Launcher icon | Present at 48, 72, 96, 144, and 192 px densities | Visually inspect on representative launchers. |
| Adaptive icon | Present with foreground vector, background color/vector, and round icon XML | Check safe zone and monochrome/themed-icon behavior if targeted. |
| Brand source | Tuning-fork mark, wordmark, light/dark icons, and Android layer SVGs exist under `design/brand/` | Preserve source; export marketing assets from these files. |
| Splash | Uses existing Android launch background/style | Capture cold launch; confirm no old Flutter branding or stretched mark. |
| Play listing icon | **Missing** as a dedicated 512×512 deliverable | Export 32-bit PNG with alpha, max 1,024 KB; it is separate from launcher resources. |
| Feature graphic | **Missing** | Produce 1,024×500 JPEG or 24-bit PNG without alpha. |
| Phone screenshots | **Missing** | Produce the planned clean release screenshots. |
| Tablet screenshots | **Missing** | Recommended because the app has responsive tablet layouts; produce at least four if using the tablet slot. |

## Current Google Play requirements

- Listing icon: 512×512, 32-bit PNG with alpha, maximum 1,024 KB.
- Feature graphic: 1,024×500, JPEG or 24-bit PNG without alpha.
- Store listing: at least two screenshots overall, JPEG or 24-bit PNG without
  alpha, each dimension 320–3,840 px, and the long side no more than twice the
  short side.
- Large-screen recommendation: at least four tablet/Chromebook screenshots,
  1,080–7,680 px, 16:9 landscape or 9:16 portrait.
- Add meaningful alt text in Play Console where offered.

Official source:
https://support.google.com/googleplay/android-developer/answer/9866151

## Production checklist

- [ ] Export listing icon from the approved tuning-fork mark; do not upscale a
      192 px launcher PNG.
- [ ] Verify icon contrast on light/dark store surfaces and Android icon masks.
- [ ] Produce feature graphic using warm ivory, orange, and muted copper
      without unverified marketing claims.
- [ ] Capture release/profile UI only; exclude status-bar notifications,
      personal data, debug overlays, and diagnostics.
- [ ] Prepare English and Turkish localized asset sets where text appears.
- [ ] Do not make Coming Soon tools a primary screenshot or graphic claim.
- [ ] Confirm all files meet current Play Console format, size, and dimension
      validation immediately before upload.
