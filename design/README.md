# Tunathic Design Direction

Tunathic should feel premium, precise, modern, minimal, musician-focused, readable, and dark-mode friendly.

The initial palette combines deep charcoal surfaces, electric blue actions, soft cyan accents, and off-white text. Color, type, spacing, and radius values belong in centralized tokens so screens remain consistent. Interfaces should favor clarity over decoration: restrained radii, limited motion, and no unnecessary gradients or glass effects.

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
