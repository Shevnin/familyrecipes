# FamilyRecipes DESIGN.md

Updated: 2026-03-21

## Product
FamilyRecipes is a mobile-first product for preserving and repeating family recipes.
It is not a recipe marketplace, a social feed, or an inspiration catalog.
It is a calm tool for passing dishes between generations with enough clarity that another person can cook them reliably.

## Primary users
- Master: a family member who collects recipes, requests them, cooks from them, and adds personal notes.
- Donor: a relative or friend who shares a recipe through a zero-install mobile web flow using two text fields: the main recipe text and a personal donor comment.

## Core product promise
- Preserve the voice of the original person.
- Make the recipe repeatable, not just sentimental.
- Reduce friction for older or low-tech family members.
- Make family knowledge feel valuable, warm, and easy to pass on.

## Experience principles
1. Warm, not cute.
2. Editorial, not corporate.
3. Calm and trustworthy, not noisy.
4. One primary action per screen.
5. Always show the next step after success.
6. Family context matters as much as instructions.
7. Reading comfort beats dense productivity UI.
8. Content first, chrome second.
9. A phone screen is a notebook page, not a poster.

## Current visual system
Accepted style baseline: 2026-03-21 Stitch exports.

Reference artifacts:
- `docs/stitch_exports/2026-03-21/list/screen.png`
- `docs/stitch_exports/2026-03-21/recipe_detail/screen.png`
- `docs/stitch_exports/2026-03-21/list/code.html`
- `docs/stitch_exports/2026-03-21/recipe_detail/code.html`

Style name:
- Warm Paper Notebook

The accepted mood is:
- warm paper
- compact native list density
- Public Sans typography
- orange as primary accent
- green as a secondary functional accent
- quiet surfaces with occasional tactile panels
- practical recipe reading over decorative storytelling

## Visual direction
Theme: Warm Paper Notebook.

The product should feel like a contemporary family notebook:
- warm paper-like backgrounds
- compact neo-grotesk text hierarchy
- low-chrome surfaces, subtle separators, restrained chips
- small graphic accents in navigation and metadata
- more notebook than gallery

The core app should be text-first:
- no decorative photography in main task flows
- no oversized hero cards
- no bento grids
- no floating dashboard blocks competing with the content
- maximize useful reading and writing space on the phone screen

Avoid:
- generic meal-planning UI
- marketplace or delivery-app aesthetics
- neon gradients, glossy fintech cards, heavy gamification
- cluttered dashboards
- oversized cards with excessive padding
- decorative image-led layouts
- large pill buttons and bloated rounded containers

## Color system
Use the accepted warm paper palette from the approved Stitch screens.

Suggested base tokens:
- Background: `#FCF9F4`
- Surface: `#FFFFFF`
- Surface Soft: `#F6F3EE`
- Surface Muted: `#EBE8E3`
- Text Primary: `#1C1C19`
- Text Secondary: `#666666`
- Border / Divider: `#E5E1D8`
- Outline Variant: `#DBC2AD`
- Accent Primary: `#FF9900`
- Accent Primary Dark: `#8A5100`
- Accent Red: `#DF2D1F`
- Accent Green: `#228B22`
- Accent Green Dark: `#006E0C`

Use accent colors intentionally:
- orange for primary actions and active navigation
- green for note / clarification / status accents
- red only for sparing emphasis, warnings, or donor-tag moments
- stable contact colors for chips and avatars
- keep most of the screen on warm paper neutrals

## Typography
- Use sans-serif typography for both Latin and Cyrillic.
- Do not use serif fonts in the app UI.
- Preferred family: `Public Sans`.
- Fallbacks: `Inter`, `Manrope`, or a similarly readable sans-serif with reliable Cyrillic support.
- Body: `Public Sans` for UI and recipe text.
- Labels: `Public Sans` or a compact sans-serif for metadata and small uppercase labels.

Typography rules:
- hierarchy should come from size, weight, rhythm, and spacing, not decorative type
- supporting copy should stay simple and practical
- labels should help scanning without creating noise
- recipe text should remain highly legible at large accessibility sizes
- avoid condensed, thin, or stylized fonts
- use bold weights with restraint; most density should come from alignment and spacing
- compact uppercase labels are allowed in small doses

## Shape and depth
- Dense list rows: `0-6px`
- Section panels / text surfaces: `8-10px`
- Input radius: `6-8px`
- Button radius: `6-10px`
- Chips: soft rounded rectangles or restrained pills
- Shadows: extremely light, often unnecessary
- Borders: warm, subtle, and allowed where density benefits from them
- Thin dividers are allowed in dense list views
- Prefer dividers, alignment, and spacing over large containers
- Avoid floating action buttons unless a flow explicitly requires one

## Motion
- Use gentle spring or ease-out motion
- Short staggered reveals on list/content load
- Meaningful transitions between flow steps
- Avoid playful bounces or excessive micro-animation

## Layout guidance
- Optimize for one-handed mobile use first
- Respect safe areas
- Prefer tight but breathable spacing and clear vertical rhythm
- Make long text comfortable to read
- Use compact metadata rows and clear CTA hierarchy
- Maximize usable text area on small screens
- Avoid stacking multiple decorative containers
- Use lists, sections, and text blocks before using cards
- Design for cooking use: glanceable, scannable, low-friction
- Assume some users will enable larger text to read without glasses
- Prefer edge-to-edge or near-edge-to-edge dense lists
- Top bars and bottom bars should stay compact and native-feeling
- Search and filters should be visually quiet, not hero elements

## Content tone
UI copy should be in Russian.

Tone:
- supportive
- simple
- respectful
- family-oriented
- never technical or bureaucratic

## Must-have screens
### Native app
- Splash / welcome atmosphere screen
- Auth screen
- Recipes empty state
- Recipes list
- Recipe detail
- Personal note state in recipe detail
- Create own recipe
- Request form
- Request success state
- Request history section with status chips and repeat actions
- Settings
- Contacts list
- Create/edit contact

### Donor mobile web
- Request landing with short onboarding context
- Recipe submission form
- Success state
- Not found / expired / already fulfilled states

## Key interaction rules
- The donor flow must feel easier than sending a long WhatsApp message.
- Request success must never be a dead end.
- Asking for clarification should be possible in 1-2 taps from recipe detail.
- Contacts should speed up repeated requests.
- Empty states should explain what to do next.
- Recipe detail should prioritize readable original text and family origin.
- Core app flows should work even with no images at all.
- Important text should wrap instead of shrinking into unreadability.
- Decorative spacing should be sacrificed before text readability is sacrificed.

## Recipe detail requirements
- Show recipe title prominently.
- Show author in a light metadata row.
- Do not prioritize date on the detail screen.
- Present original text in a readable, high-comfort text surface.
- Include a clear secondary CTA to request clarification.
- Include a personal note area that feels private and lightweight.
- Use minimal chrome around the recipe text so the text gets the screen, not the container.
- Treat the donor recipe and the personal note as one continuous working area.
- The donor recipe stays free-form text from one original submission, without auto-splitting into ingredients or steps.
- A subtle paper texture or tonal surface is acceptable on the main reading block if it does not reduce legibility.

## Request flow requirements
- Make recipient and dish the core fields.
- Surface repeat contacts as warm, color-coded chips.
- After success, clearly offer share, copy, and history actions.
- History should feel like living context, not a buried admin log.
- Keep the form compact and text-led.
- Prefer section dividers and list rhythm over big floating cards.
- The request screen can use one or two tactile grouped panels, but should still read as a notebook page rather than a dashboard.

## Donor web requirements
- Reassure the donor that no installation or registration is needed.
- Explain the task in one glance.
- Keep the form simple and forgiving.
- Capture two distinct donor inputs:
  - the main recipe text
  - a separate personal donor comment / context field
- Support both short and more detailed answers in future-ready variants.
- Make success feel warm and complete.

## Accessibility and platform behavior
- Large tap targets
- Strong text contrast
- Clear status color + label pairing
- Support Dynamic Type friendly spacing where possible
- iOS and Android should share the same product language, but native navigation patterns can differ
- Support larger accessibility text sizes without overlapping or clipping key content
- Important recipe text and form labels should remain readable at 200% scale
- Keep interfaces robust when Bold Text and Larger Text are enabled

## Deliverables expected from the design tool
- A mobile design system for this product
- High-fidelity screens for iOS and Android app flows
- Companion donor mobile web screens
- Clickable prototype across the main request -> donor reply -> recipe review loop
- Reusable components for cards, chips, buttons, inputs, and empty states

## Non-goals
- Social feed
- Public discovery marketplace
- Heavy analytics dashboards
- Complex multi-column desktop-first layouts
