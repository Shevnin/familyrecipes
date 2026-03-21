# Design System Strategy: The Nostalgic Cafe

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Nostalgic Cafe."** 

This is not a generic utility app; it is a digital heirloom. We are capturing the soul of a 90s bistro—the warmth of a ceramic mug, the bold clarity of a printed chalkboard menu, and the tactile comfort of high-quality paper. 

To move beyond "template" UI, we use **Poster-Like Energy**. This means we embrace intentional asymmetry, dramatic typography scales, and a "physical" layout logic. Instead of standard grids, we treat the screen as a canvas where elements are layered, not just placed. We achieve a premium feel by balancing "loud" brand colors with "quiet" negative space and sophisticated tonal transitions.

---

## 2. Colors & Surface Logic
The palette is rooted in high-contrast primaries supported by a sophisticated range of neutrals that mimic organic materials.

### The Palette (Token References)
- **Primary (Mug Orange):** `primary (#8a5100)` / `primary_container (#ff9900)`
- **Secondary (Cherry Red):** `secondary (#ba0a06)` / `secondary_container (#df2d1f)`
- **Tertiary (Emerald Green):** `tertiary (#006e0c)`
- **Background (Warm Paper):** `background (#fcf9f4)`
- **Text (Charcoal):** `on_surface (#1c1c19)`

### The "No-Line" Rule
To maintain a high-end editorial aesthetic, **1px solid borders are strictly prohibited for sectioning.** 
Structural boundaries must be defined through background color shifts. For example, a recipe category section should use `surface_container_low` to sit naturally against a `background` page, rather than being separated by a line.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use the `surface_container` tiers to create depth:
1.  **Level 0 (Base):** `background` (#fcf9f4) — The "Warm Paper" foundation.
2.  **Level 1 (Sectioning):** `surface_container_low` — For large grouping areas.
3.  **Level 2 (Cards/Content):** `surface_container_lowest` (#ffffff) — Provides a crisp, clean lift for readability.

### Glass & Gradient Signature
For floating elements (like a "Back to Top" button or a sticky "Add to Grocery List" bar), use **Glassmorphism**. Apply `surface_variant` at 70% opacity with a `20px` backdrop blur. This mimics the frosted glass of a bistro door, allowing the warm background colors to bleed through softly. 

*Director's Note: For main CTAs, use a subtle linear gradient from `primary` to `primary_container` (15° angle) to give the button a "enameled" look rather than a flat digital fill.*

---

## 3. Typography: Neo-Grotesk Precision
We use **Public Sans** for its clean, authoritative, yet friendly demeanor. By omitting serifs entirely, we ensure the app feels modern and high-performance, even while channeling nostalgic themes.

- **Display (Poster Energy):** Use `display-lg` (3.5rem) for hero recipe titles. It should feel massive and confident.
- **Headlines:** Use `headline-md` (1.75rem) for section headers. Ensure a tight line-height (1.1) to maintain that "printed menu" density.
- **Body:** Use `body-lg` (1rem) for instructions. We prioritize the "Warm Paper" feel by using `on_surface` (Charcoal) at 90% opacity to reduce eye strain.
- **Rhythm:** Maintain a strict vertical rhythm. All headers must have a `margin-bottom` of at least `spacing-4` (1.4rem) to let the typography breathe.

---

## 4. Elevation & Depth
In this design system, depth is achieved through **Tonal Layering**, not structural shadows.

### The Layering Principle
Avoid the "floating box" look. Place a `surface_container_highest` element inside a `surface_container_low` parent to create a recessed or "pressed" look. This feels more like a physical scrapbook than a mobile app.

### Ambient Shadows
If a floating effect is required (e.g., a Modal), use an **Ambient Shadow**:
- **Color:** `on_surface` at 6% opacity.
- **Blur:** `32px` to `48px`.
- **Y-Offset:** `8px`.
This mimics soft, overhead cafe lighting rather than a harsh digital drop shadow.

### The "Ghost Border" Fallback
If contrast is insufficient for accessibility, use a **Ghost Border**: `outline_variant` at 15% opacity. It should be barely perceptible, serving only to define an edge in high-glare environments.

---

## 5. Components

### Buttons & Chips (The "Round-Full" Rule)
All interactive elements (Buttons, Chips, Input Fields) must use `rounded-full` (9999px). This creates a friendly, tactile "pebble" shape that offsets the bold, aggressive typography.
- **Primary Button:** `primary_container` fill with `on_primary_container` text.
- **Secondary Button:** `surface_container_high` fill. No border.

### Cards & Lists
**Forbid the use of divider lines.** 
Separate list items using `spacing-3` (1rem) of vertical white space. For recipe cards, use a `surface_container_lowest` fill with a `rounded-xl` (3rem) corner radius. The high rounding is a signature element—embrace it.

### Specialized Component: The "Diner Tag"
For recipe tags (e.g., "Quick," "Vegan"), use Selection Chips with `secondary_container` (Cherry Red) but with a `0.5` horizontal scale animation on press to mimic a physical sticker being touched.

### Input Fields
Inputs should not be boxes. Use a `surface_container_low` rounded pill with `title-md` typography. The label should float above the field in `label-md` using `tertiary` (Emerald Green) to act as a clear signpost.

---

## 6. Do's and Don'ts

### Do:
- **Use generous whitespace:** If you think there is enough space, add `spacing-2` more.
- **Embrace "Mug Orange":** Use it for primary actions to draw the eye instantly.
- **Layer surfaces:** Use the `surface-container` tiers to organize content hierarchy.
- **Keep it Neo-Grotesk:** Ensure even Russian translations stay in Public Sans/Inter.

### Don't:
- **Don't use 1px dividers:** Use color shifts or space instead.
- **Don't use Serifs:** It breaks the "Modern Bistro" tension we are building.
- **Don't use harsh shadows:** Avoid any shadow with more than 10% opacity.
- **Don't cram content:** If a screen feels busy, move elements to a horizontal scroll (Carousel) or a nested "surface."

---
*End of Document. Maintain the rhythm, respect the paper, and keep the energy bold.*