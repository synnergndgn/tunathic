# Tunathic Design Direction

Tunathic should feel like a premium analog music tool: precise, musician-focused, readable, and tactile without becoming ornamental.

The current palette combines warm ivory and cream enamel surfaces, orange actions, muted copper trim, and warm charcoal text. Recessed readouts, short bevel gradients, restrained shadows, and compact radii create physical depth without glass effects or excessive decoration. Color, type, spacing, radius, elevation, and motion values belong in centralized tokens so screens remain consistent.

## Phase 1C token audit

- `AppColors` owns brand and surface colors; feature screens consume `ColorScheme` rather than repeating color literals.
- `AppSpacing` owns the spacing scale, touch-target minimum, and shared responsive content widths.
- `AppRadii` keeps corners restrained at 6 and 10 logical pixels.
- `AppTypography` supplies the Material 3 hierarchy and musician-focused display emphasis.
- `AppElevation` limits surfaces to flat and subtly raised levels. Only available dashboard tools receive the raised treatment.
- `AppMotion` centralizes short theme and interface durations plus the standard easing curve. Phase 1C adds no decorative animation.

The dashboard uses vertical, localized Practice, Theory and Reference, and Training sections. This keeps every tool discoverable without making horizontal gestures essential. Available practice tools receive stronger hierarchy through spacing, surface color, and elevation while retaining text labels, semantics, and non-color availability status.

Settings and informational screens use readable single-column cards with shared maximum widths. Layouts remain scrollable rather than compressing controls when text scaling increases. Touch interactions retain at least the Material 48 logical-pixel target.

Files in `references/` are inspiration only. They may inform broad visual qualities, but their composition, artwork, branding, and interface details must not be copied.

- `references/` stores approved visual inspiration.
- `wireframes/` stores product-owned layout explorations.
- `brand/` stores product-owned identity assets and guidance.
- `store/` stores the Google Play asset masters and the scripts that render
  them. `store/out/` is generated: change the SVG or the script, never the PNG.
  The direction, concepts, copy and capture plan live in
  `docs/store_assets/`.

Note that `AppRadii` no longer keeps corners at 6 and 10 logical pixels: the
scale is now 2/3/4 with 6 for a device edge, and nothing in the system is
pill-shaped. Store assets follow the tighter scale.
