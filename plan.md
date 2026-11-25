# Dragon Tales Implementation Plan

## Product scope

Dragon Tales is a calm, landscape-oriented 2D Godot game about caring for, breeding, collecting, and battling dragons. The first playable milestone is offline-first with local saves. Accounts, visiting a friend's island, and limited coin gifts are future online features and are intentionally not part of the initial build. Real-time multiplayer, live events, promotions, calendars, popups, and monetization pressure are out of scope for the first version.

## First playable milestone

The first checkpoint will deliver a coherent island management loop:

- Title screen with a direct Start button.
- Landscape island view using the supplied starter-island artwork.
- Ten named base dragons and ten base elements: Blaze/Fire, Tide/Water, Pebble/Earth, Breeze/Air, Spark/Lightning, Fern/Plant, Frost/Ice, Gleam/Light, Rivet/Metal, and Twinkle/Star.
- Ten habitats, three core buildings (hatchery, breeding corral, food farm), and ten base-element eggs from the supplied artwork.
- Dragon sprites using the supplied four-row by six-column sheets: idle, walk, fly, and action.
- Food harvesting, dragon feeding, base-dragon breeding, egg hatching, collection progress, achievements, and a compact battle prototype.
- Local save/load with a versioned save document.
- A restrained management HUD and contextual panels instead of dense event and promotion surfaces.

The first breeding rules are intentionally simple: a base dragon can be selected from the collection, a breeding action records a short egg result, and the base-element result is deterministic enough for early testing. Hybrid combinations will be added later through data files without rewriting the systems.

## Technology and runtime

Use Godot 4.7.2 through the initialized GameDev project and keep the game as an offline/static Web export for the first milestone. Use a 1280x720 logical viewport with canvas-item stretching and a landscape layout. Keep the existing runtime/autoload support needed by the project, but replace the inherited generic maze presentation and gameplay with Dragon Tales owners.

The future account/friend layer should be added as a separate online milestone using the game's server/database capability only when requested. Its first scope should be authentication, owned-island reads, friend-visit read-only views, and bounded coin-gift mutations. The authoritative player identity must come from the authenticated server context; the offline game remains playable without an account until that milestone is explicitly enabled.

## Asset strategy

The uploaded `dragon_game_assets_v2.zip` is the source of truth. Keep the original sheets under `assets/dragon_tales/source/` and derive transparent runtime crops under `assets/dragon_tales/runtime/`. The source sheets contain titles, labels, grid lines, and colored art; crop processing removes presentation-sheet clutter while preserving the original masters. No new generated art is authorized.

Runtime assets are generated from explicit atlas layouts:

- Each dragon: 4 rows x 6 columns, with rows idle, walk, fly, action.
- Starter island: 2 rows x 3 columns; use the six frames as a subtle island animation.
- Habitats: one 2x2 sheet for Lightning/Light/Metal/Star and one 2x3 sheet for Fire/Water/Earth/Air/Plant/Ice.
- Eggs: 2 rows x 5 columns in element order Fire, Water, Earth, Air, Lightning, Plant, Ice, Light, Metal, Star.
- Buildings: three lower-sheet regions in order hatchery, food farm, breeding corral.

## Design direction

### Design movement

Quiet illustrated fantasy-garden management game with a storybook island presentation and a low-noise console-like information hierarchy.

### Core principles

1. The island is the home screen, not a dashboard of offers.
2. Dragon silhouettes and element colors communicate state at a glance.
3. Important actions happen in contextual panels with clear consequences.
4. Motion is used for life and feedback, never for constant interruption.

### Color philosophy

Use the supplied artwork as the emotional center and pair it with deep moss, warm cream, river blue, and muted plum interface tones. Accent colors come from the ten elements. UI surfaces should be dark enough to preserve contrast over the bright island art without turning the game into a neon control panel.

### Layout paradigm

Use a scenic island canvas with three quiet interaction anchors: food farm, breeding corral, and hatchery. Habitats occupy a readable ring around the island. Collection, achievements, and battle are secondary views opened from a compact navigation rail rather than permanently competing with the island.

### Signature elements

- A calm island card with a small animated waterfall frame cycle.
- Element-colored habitat tags and egg silhouettes.
- A single notification/status line for completed actions instead of stacked popups.

### Interaction philosophy

Every action should produce one clear state change: harvest food, feed a dragon, start breeding, hatch an egg, claim an achievement, or resolve a battle. Buttons should explain their outcome and avoid coercive urgency. Completed work remains available until the player chooses to collect it.

### Animation

Use supplied idle animations for visible dragons, short walk/fly loops for ambient movement where appropriate, and one-shot action rows for battle feedback. Keep island motion subtle. Avoid continuous reward flights, screen shake, large particle bursts, or animated counters in the first milestone.

### Typography system

Use the starter's bundled Godot display and body fonts, keeping title text expressive and body text highly readable. Use a clear hierarchy: large title, medium section heading, small uppercase element labels, and compact body copy. Keep all labels live text rather than baked into runtime art.

### Brand essence

Dragon Tales is a calm dragon island for players who want discovery and collection without the noise of a live-service billboard. Personality: gentle, curious, grounded.

### Brand voice

Headlines and buttons should sound warm and direct. Example lines: “Your island is waking up.” and “Choose two dragons to discover what hatches next.”

### Wordmark and logo

Use a live-text Dragon Tales wordmark with a small hand-drawn-style tail flourish or dragon-wing underline when an original mark is later requested. The first milestone uses live title text and supplied art rather than generating a separate logo asset.

### Signature brand color

A deep river-moss teal, approximately `#2D6F67`, used sparingly for active controls and status accents.

## Project structure

```text
assets/dragon_tales/source/     Original uploaded sheets and manifest
assets/dragon_tales/runtime/    Transparent crops used by the game
data/                           Dragon, element, achievement, and battle data
scripts/dragon_tales.gd        Main scene owner and UI flow
scripts/dragon_catalog.gd       Static base-element definitions
scripts/dragon_save.gd          Versioned local save autoload
scenes/main.tscn                Root Control scene
scripts/                         Existing runtime helpers and future systems
tools/process_dragon_assets.py  Deterministic source-sheet cropper
docs/                            Product and future-online notes
plan.md                          This approved implementation plan
TODO.md                          Outcome-based delivery list
```

## Deferred decisions

- Hybrid breeding tables and inherited traits.
- Final timer lengths and whether timers can be accelerated by normal play.
- Battle depth beyond the first short PvE prototype.
- Account provider and online persistence contract.
- Friend-code/search model and gifting limits.
- iOS signing, TestFlight, and store metadata.
