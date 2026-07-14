# Tunathic Repository Rules

Tunathic – Guitar Toolkit is a commercial Flutter music toolkit published by GUNDEV. Its tagline is “Tune. Train. Create.”

## Engineering

- Use Flutter stable, Dart stable, and Material 3.
- Use a pragmatic feature-first architecture. Preferred high-level source folders are `app`, `core`, `features`, and `shared`.
- Do not create abstractions that have no current purpose.
- User interface code must not access local storage directly.
- User interface code must not contain audio DSP logic.
- Isolate platform-specific code.
- Avoid global mutable state, oversized files, circular dependencies, and duplicated design constants.
- Do not add speculative packages for future features. Explain why a dependency is needed before adding it.
- Run formatting, analysis, and tests after meaningful changes.
- Do not implement functionality outside `docs/CURRENT_MILESTONE.md`.

## Product and interface

- All user-visible strings must be localizable.
- English is the source language; Turkish must be supported.
- Support text scaling, semantic labels, and sufficiently large touch targets.
- Use deep charcoal, electric blue, and soft cyan as the initial brand direction.
- Avoid excessive gradients, glassmorphism, animation, and rounded corners.
- Do not use emoji as production interface icons.

## Security and Git

- Never commit secrets, signing files, API keys, or machine-specific configuration.
- Do not commit or push unless explicitly requested in a future task.
