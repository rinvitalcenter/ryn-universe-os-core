# Ryn Apple-Neutral Design System R1

- Status: Canonical visual foundation
- Platform baseline: Flutter Desktop, Windows-first
- Source reference: `DESIGN-apple.md` (analysis source; unchanged)
- Typography baseline: Pretendard
- First reference implementation: People

## 1. Design principles

Ryn Universe OS uses a quiet Apple-neutral interface adapted for a content-dense desktop operating environment. The interface supports the work; it does not become the work.

1. **Content first.** People, records, readings, and journals are visually primary.
2. **Neutral surfaces.** Light and Dark modes use neutral luminance steps rather than module-colored canvases.
3. **One interactive accent.** Blue carries navigation, selection, links, focus, and primary actions.
4. **Minimal chrome.** Use spacing, hairlines, and luminance before adding frames.
5. **Flat interface elevation.** Cards and buttons do not use decorative shadows.
6. **Consistent geometry.** Components use the shared spacing and radius scales.
7. **Functional generosity.** Desktop whitespace improves scanning and reading without reducing operational density.
8. **Accessible state.** Selection and focus must never depend on color alone; combine blue with an indicator, outline, icon, or underline.
9. **No atmospheric decoration.** Gradients and ornamental effects do not stand in for hierarchy.
10. **Local continuity.** Visual migration must not alter persistence, functional semantics, or stored data.

## 2. Light palette

| Semantic role | Token | Value | Use |
|---|---|---:|---|
| App canvas | `appCanvas` | `#F5F5F7` | Window and page background |
| Primary surface | `primarySurface` | `#FFFFFF` | Main content surfaces and inputs |
| Secondary surface | `secondarySurface` | `#FAFAFC` | Navigator and quiet grouped regions |
| Tertiary surface | `tertiarySurface` | `#F0F0F2` | Muted rows and secondary controls |
| Primary text | `primaryText` | `#1D1D1F` | Titles and body copy |
| Secondary text | `secondaryText` | `#515154` | Supporting copy |
| Muted text | `mutedText` | `#7A7A7A` | Metadata and disabled-adjacent copy |
| Hairline | `hairline` | `#E0E0E0` | 1 px separators and container outlines |
| Primary action | `primaryAction` | `#0066CC` | CTA, selected, active navigation, links |
| Focus ring | `focusRing` | `#0071E3` | Keyboard focus outline |
| Selected state | `selectedState` | blue at low alpha | Quiet selected surface behind a blue indicator |

Pure white is a surface, not the universal window canvas. Pearl and tertiary surfaces provide restrained grouping without lavender, gold, or green tint.

## 3. Dark palette

| Semantic role | Token | Value | Use |
|---|---|---:|---|
| App canvas | `appCanvas` | `#000000` | Window and page background |
| Primary surface | `primarySurface` | `#1D1D1F` | Main content surfaces and inputs |
| Secondary surface | `secondarySurface` | `#272729` | Navigator and quiet grouped regions |
| Tertiary surface | `tertiarySurface` | `#2A2A2C` | Muted rows and secondary controls |
| Primary text | `primaryText` | `#FFFFFF` | Titles and body copy |
| Secondary text | `secondaryText` | `#CCCCCC` | Supporting copy |
| Muted text | `mutedText` | `#999999` | Metadata and disabled-adjacent copy |
| Hairline | `hairline` | low-alpha white | Separators and outlines |
| Primary action on dark | `primaryActionOnDark` | `#2997FF` | CTA, selected, links, active navigation |
| Focus ring | `focusRing` | `#2997FF` | Keyboard focus outline |
| Selected state | `selectedState` | bright blue at low alpha | Quiet selected surface behind a blue indicator |

Dark mode uses black and neutral charcoal luminance steps. Deep navy is not the universal canvas.

## 4. Semantic color roles

- **Blue:** interactive, selected, focused, active navigation, and links.
- **Green:** success and small semantic/People identity icons only.
- **Red:** destructive actions and errors only.
- **Amber:** warnings only.
- **Gold:** not a default accent and not a selected state.
- **Purple:** not a default accent and not a module-wide surface.
- Interactive state must not mix blue with gold, green, or purple on one control.
- Module identity must not be expressed through large colored backgrounds.

The Flutter source of truth is `RynSemanticColors`, installed as a `ThemeExtension` and mirrored into `ColorScheme` where Material components require standard roles.

## 5. Typography policy

- Pretendard remains the primary Windows family.
- Existing Segoe UI Variable, Segoe UI, and Malgun Gothic fallbacks remain.
- SF Pro is not bundled, referenced as a runtime dependency, or substituted in this release.
- Existing readable desktop sizes are preserved unless a component-specific accessibility defect requires correction.
- Default body weight is 400; emphasis is 600–700 according to the existing hierarchy.
- Display tracking may be slightly tightened, but not at the cost of Korean legibility.
- Typography changes are not part of module identity.

## 6. Spacing scale

Structural spacing follows a compact 4/8-based desktop rhythm:

| Token | Value | Use |
|---|---:|---|
| `space1` | 4 | Tight icon/text and metadata spacing |
| `space2` | 8 | Inline groups and compact gaps |
| `space3` | 12 | Control groups |
| `space4` | 16 | Standard internal separation |
| `space5` | 20 | Medium component padding |
| `space6` | 24 | Primary panel padding |
| `space7` | 32 | Section separation |
| `space8` | 40 | Large composition separation |
| `space9` | 48 | Major desktop section separation |

Use spacing to establish hierarchy before adding a container.

## 7. Radius scale

| Token | Value | Use |
|---|---:|---|
| `none` | 0 | Full-bleed and edge-aligned regions |
| `xs` | 5 | Rare micro surfaces |
| `sm` | 8 | Compact utility controls |
| `md` | 11 | Inputs and standard controls |
| `lg` | 18 | Primary utility cards and panels |
| `pill` | 999 | Primary CTA, search, and true capsule controls |

Do not invent intermediate radii inside feature widgets. Avoid nesting multiple large rounded panels.

## 8. Elevation policy

- Application UI is flat by default.
- Cards, inputs, buttons, navigation, dialogs, and sheets use no decorative drop shadow.
- Separation comes from canvas/surface luminance, 1 px hairlines, spacing, and fixed-position context.
- Product or editorial imagery may receive a dedicated imagery shadow in a future media specification; that exception does not apply to UI chrome.
- Flutter Material elevation is set to zero for the shared button/card/dialog/sheet foundation where practical.

## 9. Button grammar

### Primary action

- Blue background using `primaryAction` or `primaryActionOnDark`.
- White foreground.
- Pill geometry for high-priority CTAs such as **사람 추가**.
- No shadow or gradient.
- Visible blue focus ring.

### Secondary action

- Neutral or transparent surface.
- Blue label/icon when interactive.
- Hairline outline when additional affordance is needed.
- Compact radius for utility actions; pill only when the whole control family uses capsule grammar.

### Destructive action

- Red is reserved for destructive meaning.
- Confirmation and copy must make the consequence clear.
- Archive is not deletion and should remain a neutral utility action.

## 10. Input grammar

- Primary or secondary neutral surface.
- 1 px hairline default outline.
- Blue 2 px focus outline for keyboard visibility.
- Primary and secondary text use semantic text roles.
- Search may use pill geometry; grouped form fields may use the standard `md` radius.
- Error state uses destructive red only.
- Do not tint inputs lavender, green, gold, or purple.

## 11. Selection grammar

- Blue is the only selected and active accent.
- A selected row remains neutral, with a low-alpha blue surface and restrained blue indicator/outline/check.
- Active tabs use a blue underline and blue label.
- Selected controls must also expose state through shape, indicator, icon, or semantics.
- Gold-filled selection, green selection, and mixed-color selection signals are deprecated.

## 12. Card and container grammar

- Prefer one primary surface over the app canvas.
- Use a secondary neutral surface for a navigator or grouped utility region.
- Use a tertiary neutral surface sparingly for rows and muted states.
- Use a 1 px hairline when adjacent surfaces need explicit separation.
- Do not add decorative shadows.
- Avoid card-inside-card-inside-panel nesting. A child region should be a row, section, or divider unless it has a distinct interaction boundary.
- Large module-colored surfaces are prohibited.

## 13. Module identity policy

Ryn identity comes from content, Korean wording, iconography, imagery, layout composition, and the quality of reading/journal experiences. A module does not own a large background color.

- People may use green for a small person/growth identity icon, never for large panels or selection.
- Tarot and Oracle identity should come from deck imagery and reading composition, not a universal purple wash.
- All modules share blue interaction semantics.
- Success, warning, and destructive colors retain the same meaning across modules.

## 14. Responsive desktop principles

- Windows desktop is the primary target.
- 1280 × 720 is the minimum reference viewport for the People master-detail composition.
- Preserve information hierarchy while reducing horizontal grouping before removing functionality.
- Master lists must remain scrollable and usable with 100+ records.
- Search, filter, result count, selection, and the primary action remain discoverable at compact desktop widths.
- Below the master-detail threshold, stack master above detail rather than compressing content into unreadable columns.
- Prevent overflow through flexible rows, wrapping, constrained lists, and content scrolling.
- Touch-sized 44 px controls are preferred for primary actions; precision desktop utilities may remain compact when keyboard focus is clear.

## 15. Migration order

1. Canonical semantic tokens and shared ThemeData wiring.
2. People as the first complete reference implementation.
3. Global shell chrome required to frame migrated content coherently.
4. Home and Records in separately approved tasks.
5. Reading surfaces (Tarot and Oracle) with imagery-aware migration rules.
6. Study, Practice, Settings, and remaining operational modules.
7. Legacy token removal only after all consumers migrate and regressions pass.

A shared token may coexist with compatibility aliases during migration. Compatibility is preferable to an unsafe cross-module redesign.

## 16. Explicitly deprecated legacy patterns

The following patterns must not be introduced and should be removed during each module's approved migration:

- deep navy as the universal canvas
- gold as the universal selected state
- module-wide green or purple surfaces
- mixed accent colors in one screen
- heavy rounded panel nesting
- decorative card, button, text, or navigation shadows
- gradients used only for atmosphere
- inline arbitrary hex colors in feature widgets
- lavender-tinted Light panels as a default surface
- large module identity color blocks
- selection communicated only by fill color
- parallel feature-local theme systems that compete with shared semantic tokens

## People R1 reference contract

People is the first reference migration and establishes the practical interpretation of this foundation:

- neutral Light and Dark workspace, master, detail, row, input, and archived surfaces
- common blue **사람 추가** CTA
- blue active-tab underline
- blue search and role-filter focus treatment
- neutral person rows with a low-alpha blue selected surface and restrained blue indicator
- small green People identity icons only
- hairline/luminance separation and no decorative shadows
- unchanged People repository, search/filter, selection fallback, archive/restore, add-person, Quick Start, overview, and 105-person behavior

## Governance

- `DESIGN-apple.md` remains the source analysis and is not modified by implementation work.
- This R1 document is the canonical project adaptation. If the analysis source conflicts with Windows, Flutter, Pretendard, accessibility, data safety, or Ryn product semantics, this adaptation governs.
- Palette or semantic-role changes require a separately approved design-foundation revision.
- DB schema, persistence, and functional semantics are outside visual migration scope.
