# Ryn Adaptive Workspace Design System R2

- **Task:** `RYN-ADAPTIVE-WORKSPACE-DESIGN-SYSTEM-R2`
- **Status:** Owner review candidate
- **Applies to:** Ryn Universe OS Core, Flutter Desktop, Windows-first
- **Official source baseline:** `419b1b3b847fc518b7eb42391bb2b6c8ade0b316` (`feat: add persistent people groups`)
- **Supersedes:** whole-app deep-navy/champagne-gold direction and the R1 visual direction where this document differs
- **Preserves from R1:** semantic-token consumption, restrained hierarchy, People as the first neutral reference, keyboard and tooltip requirements
- **Normative language:** **MUST / MUST NOT** is a release gate; **SHOULD / SHOULD NOT** requires a documented exception; **MAY** is optional.

> **Canonical formula**
>
> Ryn Adaptive Workspace R2 = Apple-neutral visual base and iOS-inspired adaptive discipline **40%** + Samsung One UI-inspired large-screen workspace structure **40%** + Ryn content and narrative identity **20%**.
>
> This is translation, not imitation. No Apple or Samsung trademarked screen is to be cloned.

---

## 1. Product design vision

Ryn Universe OS is a calm, people-centered, long-term growth workspace. R2 makes the **content itself**—a person, a question, a card spread, a record, a practice, or a study session—the visual center. Shell chrome becomes quiet, predictable, adaptive, and keyboard-complete.

The target experience is:

1. **Apple-neutral discipline:** precise typography, restrained material, low visual noise, direct controls, and coherent Light/Dark behavior.
2. **Large-screen usefulness:** navigation, working content, and optional context divide the desktop into role-based zones rather than stretching a phone page.
3. **Ryn identity through meaning:** Tarot imagery, person narratives, growth records, terminology, composition, and interaction flow—not module-wide color washes.
4. **Windows reality:** clear focus, reliable mouse/keyboard behavior, reduced-transparency fallback, text scaling, and stable performance without assuming backdrop blur.

R2 governs future migrations; it does not itself authorize implementation, DB work, or feature redesign.

## 2. Design principles

1. **Content before chrome.** Navigation and utility controls frame work but never compete with it.
2. **Neutral by default, semantic by exception.** Blue communicates interaction/selection/focus; green success; amber warning; red error/destruction.
3. **Structure before decoration.** Use hierarchy, spacing, pane roles, and typography before borders, tint, shadow, or glass.
4. **One level of containment is usually enough.** Avoid panel-inside-panel dashboards.
5. **Adaptive, not compressed.** Reflow panes and defer inspectors; do not shrink essential content to satisfy a screenshot size.
6. **Stable state.** Rail animation and route changes MUST NOT destroy feature state solely because shell geometry changed.
7. **Keyboard parity.** Every hover or pointer affordance has a focus/click/keyboard equivalent.
8. **Motion explains change.** No bounce, overshoot, glow, decorative parallax, or continuous ambient motion.
9. **Accessible under real Windows settings.** 125% and 150% text-scale smoke is mandatory.
10. **Migration is local and reviewable.** Each module moves to R2 in a separately bounded task.

## 3. Content / Navigation / Context layer model

### 3.1 Content layer

- Contains actual People, Tarot, Records, Study, Saju, Practice, Home, and Settings work.
- Uses opaque or near-opaque neutral surfaces.
- MUST NOT use general-purpose glass cards.
- Large imagery or atmospheric assets are allowed only when they are content, such as Tarot cards or a module illustration.
- Content remains readable and correctly hierarchical with all transparency disabled.

### 3.2 Navigation and utility layer

- Contains the left rail, top search/theme/profile area, page toolbar, filters, commands, tabs, and segmented controls.
- MAY use one restrained translucent/frosted material over an opaque fallback.
- MUST retain readable text, borders, and selection state when blur is unavailable.
- MUST NOT stack glass on glass; a translucent rail cannot contain translucent floating cards.
- Selection uses blue plus shape/icon/text weight, never color alone.

### 3.3 Modal and context layer

- Contains dialogs, modal sheets, popovers, menus, contextual editors, and confirmations.
- SHOULD originate near the source control when space permits; otherwise use a centered dialog or bounded desktop sheet.
- Background dim is restrained; blur is optional, never required for legibility.
- Modal focus is trapped, restoration is deterministic, and Escape follows Section 27.

### 3.4 Windows compatibility fallback

Use the following fallback order:

1. Backdrop/frosted material when supported, performant, and not disabled by user preference.
2. Semi-opaque utility surface (`>= 92%` effective opacity) with hairline border.
3. Fully opaque `raisedUtilityMaterial` token.

No layout, text color, hit target, or control placement may depend on blur. If frame time or contrast degrades, the implementation MUST choose the opaque fallback without changing geometry.

## 4. Light color system

R2 Light is neutral gray/white, not warm ivory. Values below are canonical starting tokens and MUST be consumed semantically.

| Token | Value | Use |
|---|---:|---|
| `appCanvas` | `#F5F6F8` | Window/workspace background |
| `primarySurface` | `#FFFFFF` | Primary content pane |
| `secondarySurface` | `#F8F9FB` | Navigator/list or quiet grouped region |
| `tertiarySurface` | `#ECEFF3` | Selected-neutral/disabled/embedded region |
| `raisedUtilityMaterial` | `#F2F5F9` | Opaque fallback for rail/top utility/popover |
| `primaryText` | `#1B1D21` | Main content, contrast 16.88:1 on white |
| `secondaryText` | `#4E545F` | Supporting text, 7.62:1 on white |
| `mutedText` | `#6D7582` | Metadata, 4.65:1 on white; not for tiny text |
| `hairline` | `#D8DDE5` | Component boundary |
| `divider` | `#C9D0DA` | Stronger structural separator |
| `primaryInteractive` | `#0A63D8` | Primary action/selected/focus family; 5.54:1 with white |
| `focusRing` | `#0067E5` | External focus outline |
| `success` | `#147A39` | Success/status only |
| `warning` | `#9A5A00` | Warning only |
| `destructive` | `#C81E2A` | Error/destructive only |

Selected-state fill is `primaryInteractive` at approximately 8–12% over an opaque surface; its label/icon remains full-strength blue. Hover and pressed overlays are state tokens, not inline alpha choices.

## 5. Dark color system

R2 Dark is neutral charcoal, not a universal deep-navy canvas. Near-black is allowed only where content requires cinematic contrast.

| Token | Value | Use |
|---|---:|---|
| `appCanvas` | `#101216` | Window/workspace background |
| `primarySurface` | `#17191E` | Primary content pane |
| `secondarySurface` | `#1E2127` | Navigator/list or quiet grouped region |
| `tertiarySurface` | `#262A31` | Selected-neutral/disabled/embedded region |
| `raisedUtilityMaterial` | `#2B3038` | Opaque utility fallback |
| `primaryText` | `#F5F7FA` | Main content, 16.38:1 on primary surface |
| `secondaryText` | `#C0C6D0` | Supporting text, 10.24:1 |
| `mutedText` | `#929AA7` | Metadata, 6.20:1 |
| `hairline` | `#343943` | Component boundary |
| `divider` | `#454B57` | Stronger structural separator |
| `primaryInteractiveOnDark` | `#63A8FF` | Action/selection, 7.18:1 on primary surface |
| `focusRing` | `#7CB7FF` | External focus outline |
| `success` | `#45C56A` | Success/status only |
| `warning` | `#F2B84B` | Warning only |
| `destructive` | `#FF6B73` | Error/destructive only |

Dark panes differ mainly by lightness and borders, not blue tint. Tarot viewing areas MAY use content-specific dark staging, but surrounding controls return to neutral R2 surfaces.

## 6. Semantic color roles

- Blue is the only global primary interaction, selection, link, and focus family.
- Green MUST communicate success, availability, completion, or an explicitly labeled positive status only.
- Amber MUST communicate warning/caution only.
- Red MUST communicate destructive action, error, invalid state, or critical failure only.
- Gold and purple MUST NOT be global accents, selected states, focus colors, or module canvases.
- A module MAY own a small identity marker/icon illustration, but MUST NOT tint an entire page, rail, or pane.
- Every status combines color with icon, label, pattern, or shape.
- Inline hex values are prohibited in migrated shared UI. Content assets and mathematically necessary image staging are exceptions documented in code.
- Decorative gradients are prohibited. A photographic/content atmosphere inside an actual content asset is allowed.

Supporting semantic roles are also canonical; they are not new accent families:

| Role | Light | Dark | Contract |
|---|---:|---:|---|
| `onPrimaryInteractive` | `#FFFFFF` | `#0B1524` | Text/icon on the blue action fill |
| `onSuccess` | `#FFFFFF` | `#17191E` | Content on a solid success fill |
| `onWarning` | `#FFFFFF` | `#17191E` | Content on a solid warning fill |
| `onDestructive` | `#FFFFFF` | `#17191E` | Content on a solid destructive fill |
| `scrim` | black at 32% | black at 48% | Modal separation; reduce further when high contrast suffers |
| `hoverOverlay` | primary text at 5% | primary text at 7% | Hover feedback over an opaque surface |
| `pressedOverlay` | primary text at 9% | primary text at 11% | Press feedback over an opaque surface |
| `disabledContent` | muted text at 62% | muted text at 62% | Disabled label/icon; semantics still reports disabled |

Rail/header/pane roles are semantic aliases of the surface tokens, not independent colors: navigation and utility default to `raisedUtilityMaterial`; navigator panes default to `secondarySurface`; content panes default to `primarySurface`. This prevents another parallel palette.

## 7. Typography policy

- Primary family remains **Pretendard**; font assets and package configuration are unchanged by R2.
- Fallback order remains Segoe UI Variable/Text, Segoe UI, and Malgun Gothic.
- Use `ThemeData.textTheme`; do not invent per-widget font sizes in migrated shared components.

| Role | Starting size / line height | Weight | Use |
|---|---|---|---|
| Display | 32 / 40 | 700 | Rare module landing title |
| Page title | 28 / 36 | 700 | One per workspace |
| Section title | 20 / 28 | 700 | Major content section |
| Pane title | 17 / 24 | 650–700 | Navigator/inspector title |
| Body | 15 / 22 | 400–500 | Primary reading text |
| Body small | 13 / 19 | 400–500 | Supporting detail |
| Label | 13 / 18 | 600 | Controls and compact metadata |
| Caption | 12 / 17 | 500 | Secondary metadata only |

- Korean body copy SHOULD use line height 1.45–1.6 for narrative reading.
- All-caps English eyebrow text is optional and never a substitute for a Korean title.
- Avoid weight 800–900 across entire screens; heavy weight is reserved for clear hierarchy.
- Text MUST wrap or reflow under scaling; fixed-height text boxes require a proven overflow strategy.

## 8. Spacing scale

Canonical logical-pixel scale: `0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64`.

- Inline icon gap: 8.
- Related controls: 8–12.
- Field stack: 16.
- Section separation: 24–32.
- Pane internal padding: 20 compact, 24 standard, 32 wide when content benefits.
- Workspace outer gutter: 16 compact, 20–24 standard, 24–32 wide.
- Arbitrary values are prohibited unless a content asset or geometric spread documents the need.

## 9. Radius scale

| Token | Value | Use |
|---|---:|---|
| `radiusNone` | 0 | Edge-to-edge pane/divider |
| `radiusXs` | 4 | Tiny indicator |
| `radiusSm` | 8 | Tooltip, compact control |
| `radiusMd` | 12 | Input, button, standard card |
| `radiusLg` | 16 | Popover, modal region, focus block |
| `radiusXl` | 20 | Large bounded scene only |
| `radiusPill` | 999 | Segmented indicator/chip only |

Nested containers MUST step down radii and MUST NOT repeat multiple large rounded panels.

## 10. Hairline and elevation policy

- Hairline: 1 logical pixel at normal scale; permit 0.5–0.75 only after Windows raster QA.
- Dividers express pane structure; borders express interactive boundaries.
- Content cards default to elevation 0 with hairline or surface contrast.
- Utility material/popover may use elevation equivalent 2–4 with a low-alpha neutral shadow.
- Modal/dialog may use elevation equivalent 8.
- Decorative card shadows, large blurred shadows, and shadow on every panel are prohibited.
- Selected state is not communicated by elevation alone.

## 11. Material and transparency policy

- Content surfaces are opaque or effectively opaque.
- Rail/top utility/popover MAY use one restrained material layer.
- Target utility opacity: 92–96% before blur; exact alpha becomes a theme token.
- Blur radius is implementation-specific and must be performance-tested; it is not a visual dependency.
- Reduced transparency or unsupported backdrop forces the opaque `raisedUtilityMaterial` token.
- No glass-on-glass, glass content cards, rainbow refraction, decorative gradients, or glow.
- Scroll content MUST remain readable when moving behind translucent utility chrome.

## 12. Motion tokens and curves

| Token | Duration | Curve | Use |
|---|---:|---|---|
| `motionInstant` | 0 ms | linear | Reduced-motion replacement |
| `motionFast` | 120 ms | `easeOut` | Hover/pressed/focus feedback |
| `motionShort` | 150 ms | `easeOutCubic` | Fade or compact state change |
| `motionStandard` | 200 ms | `easeOutCubic` | Rail width/pane transition |
| `motionEmphasis` | 260 ms | `easeInOutCubic` | Modal or meaningful scene change |

- Label fades may overlap geometry but must not lead to clipped text.
- Transform distance is 4–6 px for shell labels and 8–12 px maximum for contextual surfaces.
- No bounce, overshoot, elastic curve, glow, decorative card lift, or unrelated stagger.
- Tarot shuffle/reveal MAY use longer content motion when it conveys the reading action; it still requires reduced-motion behavior.

## 13. Reduced-motion policy

Honor platform/Flutter disable-animation signals.

- Rail width and label transition become immediate or <= 50 ms crossfade.
- Modal placement uses fade only; no scale/slide requirement.
- Auto-scrolling and staged card reveals become immediate state changes or a user-triggered single transition.
- Focus indicators remain visible; reduced motion never removes state feedback.
- No essential information may exist only during animation.

## 14. Global shell anatomy

`RynAppShell` owns only global chrome and route presentation:

1. **Left:** `RynAdaptiveNavigationRail`.
2. **Top of workspace:** `RynTopUtilityBar` with global search, theme, and profile/owner controls.
3. **Center:** lazy-preserved route page host containing the active feature.
4. **Optional page toolbar:** owned by the feature but aligned to shell gutters.
5. **Context:** optional inspector or contextual overlay above the content layer.

The shell MUST:

- keep destination identity and feature state stable across rail modes;
- avoid a global nested scroll view around every feature;
- let each feature own its content scrolling;
- separate 린님-facing shell from development/governance markers;
- use safe opaque fallback material on Windows;
- avoid rebuilding feature pages solely because rail width, hover, or pin state changed.

## 15. Collapsible navigation rail states

### 15.1 Approved geometry

- **COMPACT:** default, width **72**.
- **PEEK:** temporary hover/focus expansion, width **232**.
- **PINNED:** explicit session-level expansion, width **232**.

These values fit 40–44 px targets plus 14–16 px side padding and a readable Korean label column. They replace the current fixed 168 px rail.

### 15.2 State machine

- COMPACT → PEEK: pointer enters rail or keyboard focus enters a destination/control.
- PEEK → COMPACT: pointer leaves after a 120 ms grace period **and** focus is not inside **and** rail is not pinned.
- PEEK → PINNED: pin control activation.
- PINNED → PEEK/COMPACT: unpin; remain PEEK while pointer/focus stays inside, otherwise COMPACT.
- Route changes never reset PINNED.
- Pinned state lasts for the current app session only. It is not persisted to DB or settings in the first shell task.

### 15.3 Animation and label behavior

- Width: **200 ms**, `Curves.easeOutCubic`.
- Label fade: **140 ms**.
- Label slide: **6 px** from the rail edge toward final position.
- Active indicator transition: 150 ms, no bounce/overshoot/glow.
- Reduced motion: immediate width/state; labels appear without slide.

### 15.4 Active route and controls

- Active route uses a blue-tinted rounded rectangle or side indicator plus full blue icon/label and `Semantics(selected: true)`.
- In COMPACT the active shape remains visible around the icon.
- Every destination and the pin control has a tooltip.
- Tooltip wait duration: **500 ms** pointer hover; keyboard focus may announce immediately through semantics.
- Minimum target: **44 × 44** preferred, never below 40 × 40.
- Pin control sits at the lower utility zone, above profile/help if present, and remains reachable in all states.

### 15.5 Keyboard, Escape, and focus

- Tab enters the rail in visual order; Shift+Tab reverses.
- Up/Down arrows move among destinations without activating; Home/End go to first/last; Enter/Space activates.
- Keyboard focus inside an unpinned rail opens PEEK and prevents collapse.
- Escape in PEEK transfers focus to the active page heading/first content focus target, then collapses. It MUST NOT collapse while leaving focus stranded in hidden labels.
- Escape in PINNED does not unpin.
- Pointer exit cannot collapse while focus remains inside.
- Tooltip does not take focus and must not cover the active target.

### 15.6 State preservation

The rail is an animated sibling of a stable page host. Rail mode changes MUST NOT replace, re-key, or dispose the active page. A lazy-preserved page bucket/host is preferred over rebuilding conditional branches; inactive pages use `Offstage`/`TickerMode`/focus exclusion or an equivalent tested strategy.

## 16. Top utility bar rules

- Contains global search, theme mode, and profile/owner entry only.
- Height is content-driven, typically 56–64; no fixed height that clips 150% text.
- Global search is a real control or clearly disabled placeholder; a production-looking no-op field/button is prohibited.
- At compact widths, search may become an icon that opens `RynAdaptiveSearch`; theme may move into profile/settings, but all actions remain discoverable.
- Theme offers System/Light/Dark and remains under the app-level theme state owner.
- The bar uses restrained utility material and one bottom hairline; it is not a large card.
- Page-specific filters/actions belong below it in a page toolbar, not inside the global bar.
- Profile/owner control has text or tooltip/semantics and a minimum 44 px target.

## 17. Adaptive pane and breakpoint rules

Let `W` be the **usable app viewport width** after window insets, not a screenshot target. Breakpoints are starting decisions and MAY shift by about 80 px when content roles prove it, provided behavior is tested and documented.

| Class | Guidance | Default composition |
|---|---:|---|
| Compact desktop | `W < 1100` | One primary workspace; navigator/context becomes drawer, route, or sheet |
| Standard desktop | `1100 <= W < 1600` | Navigation rail + two-pane feature workspace |
| Wide desktop | `W >= 1600` | Navigation rail + two panes + optional inspector |

Rules:

- Do not show every pane simultaneously merely because width exists.
- Pane minimums are role-based: navigator ~280–360, primary workspace >=560, inspector ~300–380.
- User-resizable pane widths are deferred until a module proves the need.
- At compact widths, preserve task continuity and focus; do not shrink card boards or charts until illegible.
- 1280×720 is defensive smoke only, not primary acceptance.

Module compositions:

- **People:** people navigator / person workspace / optional context inspector.
- **Records:** filters and list / record detail / optional metadata inspector.
- **Study:** group/session navigator / active operation workspace / member-attendance inspector.
- **Tarot:** question/context / card board / interpretation-action workspace.
- **Saju:** chart viewing area / interpretation interaction area / optional supporting inspector.
- **Practice:** today/practice context / journal entry / progress-reflection inspector.

## 18. Viewing-area / interaction-area model

A **viewing area** protects complex, image-led, or spatial content (Tarot board, Saju chart, timeline). An **interaction area** contains writing, decisions, filters, and actions.

- Viewing areas may use content-specific staging but do not recolor global chrome.
- Interaction areas use neutral R2 surfaces and standard controls.
- In Standard/Wide, both may coexist as panes.
- In Compact, viewing appears first for inspect tasks; interaction appears first for compose tasks, with an explicit toggle/step between them.
- Persistent primary CTA belongs to the interaction area, not floating over content imagery.
- Optional inspector contains metadata/reference, never the only path to a primary action.

## 19. Focus-block rules

`RynFocusBlock` groups one coherent task such as “question”, “person summary”, or “today’s practice”.

- One surface, one heading, one main action cluster.
- Default radius `radiusLg`, elevation 0, optional hairline.
- Internal subgroups use spacing/dividers rather than nested cards.
- Focus blocks can become panes but MUST NOT create a dashboard grid of empty equal cards.
- A focus block is prohibited for single labels, decorative wrappers, or every list row.

## 20. Button grammar

- **Primary:** one dominant next action per focus block; filled blue.
- **Secondary:** outlined or neutral filled; for alternatives.
- **Tertiary:** text button; for low-priority navigation.
- **Destructive:** red, explicit verb, separated from routine actions; confirmation when loss is meaningful.
- Icon-only buttons are reserved for universally understood compact actions and always require tooltip/semantics.
- Minimum target 44 px preferred; label must remain readable at 150% scale.
- Disabled state reduces contrast but retains readable label; do not rely on opacity alone.
- Loading preserves width and prevents duplicate activation.
- Pill shape is not universal; use `radiusMd` by default and pill only when grammar calls for it.

## 21. Input and search grammar

- Inputs use primary/secondary surfaces, 1 px border, `radiusMd`, visible 2 px focus ring.
- Label persists above or within the field according to Material grammar; placeholder is example/help, never the only label.
- Error combines red border/icon/message and is announced.
- Search includes search icon, descriptive hint, clear action when non-empty, Escape-to-clear first, and a no-results response.
- Global search and page search are visually related but scoped and labeled distinctly.
- Search filtering should be immediate for local collections; expensive operations use explicit progress.
- Do not put developer-only sample text in production placeholders.

## 22. Tab and segmented-filter grammar

- **Tabs** switch peer content views and support Left/Right arrows, Home/End, and visible focus.
- **Segmented filters** select one small mode/filter set; selection is blue tint + icon/check/weight, not color alone.
- More than five options should become tabs, a dropdown, or a filter popover.
- Filter state is separate from persisted domain state unless explicitly approved.
- People group filter remains a single selected group; R2 MUST NOT imply multi-select behavior.
- Tab/segment rows can scroll at compact widths without shrinking labels below readability.

## 23. Card and container grammar

- Prefer list rows, whitespace, and pane boundaries over cards.
- A card represents a self-contained content object with a clear affordance or summary.
- Standard: opaque surface, radius 12, elevation 0, optional hairline.
- Selected card: blue indicator/tint plus semantics; no gold border or shadow lift.
- Image/card content may cast a restrained physical shadow when object realism is meaningful; generic UI cards may not.
- Do not nest more than one card level. A card inside a focus block requires explicit information hierarchy.
- Large empty dashboard card grids are prohibited.

## 24. Modal / sheet / popover grammar

- **Popover:** source-linked, non-destructive context, bounded width 280–420; closes on outside click/Escape.
- **Dialog:** focused decision or confirmation; centered, width ~400–640; focus trapped.
- **Modal sheet:** complex editor or management flow; on desktop bounded to ~560–760 and source/center aligned, not a full-width mobile bottom sheet by default.
- **Context sheet/drawer:** compact-width replacement for an inspector or navigator.
- Opening stores source focus; closing restores it unless the source was removed.
- Primary action is last in reading/focus order; destructive action is explicit.
- Backdrop dim is restrained; blur optional; reduced transparency uses dim only.
- Nested modal over modal is prohibited except an essential confirmation from an editor.

## 25. Empty and no-results states

- **Empty:** explains why the collection has no content and offers one safe first action.
- **No results:** preserves current filters/search, states that nothing matched, and offers clear/reset—not a create action unless appropriate.
- Use compact icon or contextual illustration; no oversized decorative empty panel.
- Avoid blame, developer terminology, and fake sample data.
- Empty/no-results states retain page title, navigation, and relevant filters.

## 26. Tooltip and icon-only control policy

- Every icon-only actionable control MUST have `Tooltip` and semantic label.
- Pointer wait: 500 ms; prefer 50–400 px readable tooltip width and concise Korean copy.
- Tooltip describes the action (“그룹 관리”), not the icon (“설정 아이콘”).
- Disabled controls that need explanation use a wrapper/adjacent helper that remains discoverable.
- Tooltips do not replace visible labels for unfamiliar primary actions.
- Hover-only content or controls are prohibited.

## 27. Keyboard navigation and focus order

- Global order: rail → top utility → page toolbar → page primary content → inspector → transient context.
- Within panes, order follows visual reading order, not widget construction accidents.
- Enter/Space activates buttons, rows, cards, and pin controls.
- Arrow keys operate rail destinations, tabs, segments, menus, and listboxes where appropriate.
- Escape priority: close tooltip/menu/popover → close sheet/dialog → clear active search when documented → exit temporary PEEK with safe focus transfer → no-op.
- Modal focus is trapped and restored to source.
- Route change focuses the new page heading/primary landmark; returning restores a meaningful prior control when practical.
- Visible focus ring is never removed for keyboard input. Focus must not be hidden behind clipping or translucent material.

## 28. Text scaling and accessibility

Mandatory:

- keyboard-complete operation;
- visible focus ring and logical focus order;
- tooltips/semantic labels for icons;
- selection/status not communicated by color alone;
- Windows 100%, 125%, and 150% text-scale smoke;
- reduced motion and reduced transparency fallback;
- high-contrast readability review;
- minimum target 40 px, 44 px preferred;
- Enter/Space/Escape/arrow behavior from Section 27.

Implementation rules:

- Honor `MediaQuery.textScaler`; do not forcibly cap system scale in shared UI.
- Replace fixed heights with minimum constraints where labels can wrap.
- At 150%, controls may reflow to a second row; clipping, overlap, or inaccessible action is HOLD.
- Text contrast targets WCAG AA: 4.5:1 normal text, 3:1 large text and non-text UI boundaries where applicable.
- Semantics identify selected, expanded, disabled, busy, and destructive states.
- High contrast must remain usable without transparency or subtle tint distinctions.

## 29. Module identity policy

Ryn identity comes from content, imagery, composition, terminology, and task flow. It MUST NOT depend on large tinted backgrounds.

Permitted identity:

- meaningful module icon and small marker;
- actual Tarot/Oracle art;
- person portrait/initial and relationship narrative;
- chart geometry, spread geometry, timeline, journal composition;
- module-specific verbs and Korean UX copy;
- contextual illustration inside content bounds.

Prohibited identity:

- module-wide green/purple/gold canvas;
- different global button color per module;
- decorative gradient theme;
- module-specific rail/top-bar tint;
- inconsistent radii/motion/focus behavior.

## 30. Home application rules

- Home is the “next useful action” surface, not a dashboard of equal cards or governance controls.
- Prioritize self Tarot continuation/result, today’s person/record/practice, and one clear start action.
- Use one dominant content scene plus a restrained supporting flow.
- Remove universal cinematic gradient/shadow treatments from shell containers; Tarot imagery may retain content staging.
- Development/governance markers never appear in normal user Home/menu.
- At Compact, supporting content follows the primary scene; at Wide, it may become a narrow context pane.
- Home content redesign is deferred to its dedicated migration; shell compatibility must not rewrite Home narratives.

## 31. People application rules

- People remains the R1 neutral reference and migrates mainly through shell compatibility.
- Standard: people navigator + person workspace; Wide: optional timeline/context inspector.
- Preserve search + primary role + one selected group as AND semantics.
- Group management and membership editing become bounded desktop modal sheets/popovers without changing behavior.
- Group-management errors MUST be announced inside the active modal as a live region; a notice hidden behind the modal is insufficient.
- Fixed list/detail heights and one-row group creation controls MUST reflow or scroll safely at 125% and 150% text scale.
- Green remains status/success only; People identity uses person content, labels, and composition—not a green page.
- Preserve repository/controller/domain behavior exactly during visual migration.

## 32. Records application rules

- Standard: filters/list navigator + record detail; Wide: optional metadata/provenance inspector.
- Record narrative and actual spread/attachments are primary.
- Replace repeated rounded result cards with rows or grouped list sections where practical.
- “Home에 표시” is a secondary stateful action, not a special accent theme.
- Preserve read-only projection and persistence semantics; visual work does not alter record contracts.

## 33. Tarot application rules

- Tarot is image/content-led, but global shell and interaction areas remain neutral R2.
- Setup: question/context interaction + deck/spread viewing.
- Shuffle/draw/result: card board is the viewing area; controls are a separate interaction area.
- Interpretation: preserve left snapshot/card scene + right narrative/story notes; do not relayout cards into a meaning list.
- Existing 78-card/deck/spread contracts remain untouched.
- Gold/purple may exist inside card artwork or a tiny content marker, never as global selection/focus.
- Replace arbitrary inline durations with motion tokens; content reveal may use a documented exception and reduced-motion path.
- Tarot internals are not redesigned by the shell task.

## 34. Oracle application rules

- Oracle remains a parallel experience inside **리딩**, not an independent top-level OS module.
- Identity comes from the deck art and 1/3-card message flow.
- Remove large decorative gradients and gold selected borders; use neutral stage + blue interaction.
- Standard/Wide result: card snapshot/viewing left, story/action right.
- Preserve current controller/session flow and first complete deck contract; avoid premature generic engine abstraction.

## 35. Saju application rules

- Build directly on R2 when authorized.
- Chart is a protected viewing area; interpretation is an interaction area; references may use an inspector.
- Use typography, grid, line, and hierarchy rather than module-wide red/gold palettes.
- Technical chart labels must support zoom/text scaling and keyboard traversal where interactive.
- No schema, engine, or data contract is implied by this design document.

## 36. Practice application rules

- Today/practice context + journal entry + optional progress/reflection inspector.
- Calmness comes from spacing and copy, not muted illegible contrast or decorative nature gradients.
- Completion uses semantic success with label/icon.
- Progress is not gamified by default; no streak pressure without product approval.
- Build directly on R2 only in a separately approved module task.

## 37. Study application rules

- Group/session navigator + active operation workspace + member/attendance inspector.
- Dense operations use rows, table/list patterns, and sticky page toolbars instead of card grids.
- Member identity and attendance status remain readable in high contrast and without color.
- Study must be separated from deprecated Study_OS_V2/Tauri workspaces; this contract applies only to Ryn Universe OS Core.

## 38. Settings application rules

- Use a categorized navigator + settings workspace at Standard/Wide; single grouped list at Compact.
- Theme System/Light/Dark belongs here and in top utility only if duplication remains synchronized.
- Data safety actions are a clearly labeled section; destructive/recovery actions use explicit confirmation.
- Do not style settings as generic placeholder chips/cards.
- Developer-only details stay behind an admin/developer disclosure and out of normal user navigation.

## 39. Legacy-pattern deprecation list

The following are explicitly deprecated for whole-app migrations:

1. Universal deep-navy canvas.
2. Universal gold selected state.
3. Module-wide green or purple backgrounds.
4. Mixed accent colors on one screen.
5. Excessive rounded panel nesting.
6. Panel-inside-panel dashboards.
7. Decorative card shadows.
8. Decorative gradients.
9. Large empty dashboard grids.
10. Developer placeholders/forms in production UI.
11. Icon-only controls without tooltips.
12. Hover-only navigation without keyboard/click alternative.
13. Page recreation caused by navigation animation.
14. 1280×720 as the primary visual acceptance viewport.
15. Arbitrary inline durations, radii, and colors.
16. Global utility controls presented as large cards.
17. No-op search controls that look operational.
18. Color-only selected/status/error states.
19. Mobile full-width bottom sheets used by default on desktop.
20. Governance/development markers in 린님-facing Home or normal menus.

Legacy aliases may remain temporarily for unmigrated modules but MUST NOT be used by newly migrated R2 shared components.

## 40. Whole-app migration order

Each stage is separately authorized and should end with Owner QA before the next visual migration.

| Stage | Goal | Expected changed areas | Owner QA target | Regression boundary | Explicit deferred scope |
|---:|---|---|---|---|---|
| 1 | Canonical R2 contract | This document only | Contract coherence | No runtime/source behavior | All implementation |
| 2 | Global shell + collapsible rail | Shell chrome, semantic/motion tokens, shell widget tests | Maximized navigation, Light/Dark, Compact/Peek/Pinned, keyboard | Feature behavior/state and persistence unchanged | Module redesign, DB, packages |
| 3 | Home shell compatibility | Home margins/chrome integration only | Primary content prominence and workspace use | Home actions/results unchanged | Home content redesign |
| 4 | People shell compatibility | People pane fit and desktop modal presentation | Search/role/group AND, master/detail, Light/Dark | Repository/controller/group behavior unchanged | New People features |
| 5 | Records | List/detail/inspector composition | Record hierarchy and spread visibility | Persistence/read-only projection unchanged | New record types |
| 6 | Reading Atelier | Neutral atelier composition and doorway hierarchy | Tarot/Oracle discoverability | Controllers and routes unchanged | Tarot/Oracle internals |
| 7 | Tarot setup | Context/viewing pane structure | Question/deck/spread clarity | 78-card contracts unchanged | Draw/result redesign |
| 8 | Tarot shuffle/draw/result | Card board + command area, motion tokens | Card prominence, restrained motion, reduced motion | Selection/result semantics unchanged | Interpretation data changes |
| 9 | Tarot interpretation | Snapshot left + story/action right | Writing comfort and card continuity | Save/draft contracts unchanged | AI interpretation, schema |
| 10 | Oracle | Neutral 1/3-card flow | Deck art identity and message flow | Controller/deck contract unchanged | Generic oracle engine |
| 11 | Settings | Categorized settings workspace | Theme/data-safety clarity | Backup/restore logic unchanged | New settings persistence |
| 12 | Study/Saju/Practice | Build new modules directly on R2 | Module-specific operational flow | Separate module contracts | Any unapproved DB/engine/API work |

## 41. Owner Visual QA policy

Official acceptance uses the Owner’s actual Windows environment:

- Use maximized or routinely used app window size.
- Record actual physical and logical viewport when practical, including Windows scaling.
- 1280×720 is optional defensive smoke only.
- Scrolling at 1280×720 is not itself a defect.
- Do not compress, remove hierarchy, or downgrade the product to fit 1280×720.
- Compact-window screenshots are not required unless the task explicitly targets compact support.

Owner QA judges:

1. hierarchy and content prominence;
2. usable workspace and pane roles;
3. Light/Dark coherence;
4. navigation clarity, including Compact/Peek/Pinned;
5. interaction and keyboard clarity;
6. motion restraint/reduced-motion behavior;
7. feature identity through content;
8. cross-module consistency;
9. 125% and 150% text-scale resilience;
10. reduced-transparency/high-contrast readability.

Visual claims require screenshots or direct Owner operation. Automated green tests do not replace visual acceptance.

## 42. Automated defensive test policy

Future implementation tasks add focused tests, not broad snapshot churn:

- exact rail state transitions and widths;
- hover/focus/pin/unpin/Escape behavior;
- keyboard order, arrows, Enter/Space, semantics selected state;
- tooltip presence for every icon-only destination/control;
- route change and rail animation do not dispose/recreate preserved feature state;
- PINNED survives route changes but not a fresh app session unless later approved;
- reduced-motion uses instant/near-instant transitions;
- reduced-transparency selects opaque fallback;
- Light/Dark semantic token mapping;
- compact/standard/wide pane decisions at boundary-adjacent widths;
- text-scale smoke at 1.0, 1.25, 1.5 with no overflow in shell controls;
- 2.0 text scale is a recommended defensive stress test for shared shell/modal components, but does not replace the required 1.25/1.5 Windows acceptance smoke;
- no source-level inline color/duration/radius additions in migrated shared components, using existing tooling or review rather than a new package;
- existing feature tests remain the regression boundary.

No full Flutter suite is required for every visual iteration. The authorized task defines focused tests; canonical gates run before commit.

## 43. Implementation checklist

### 43.1 Shared-component contract

All components consume semantic tokens, support Light/Dark, expose semantics, and avoid direct DB/domain ownership.

| Component | Purpose / visual role | Allowed surfaces + Light/Dark | Interaction + keyboard | Adaptive behavior | Prohibited misuse |
|---|---|---|---|---|---|
| `RynAppShell` | Stable global chrome and lazy-preserved page host | Canvas + utility layer; neutral in both modes | Route landmarks; focus new page/restored target | Rail + top bar + content; optional inspector slot | Feature logic, global nested scroll, page recreation |
| `RynAdaptiveNavigationRail` | Compact/Peek/Pinned destination navigation | Utility material with opaque fallback | Tab, arrows, Home/End, Enter/Space, Esc transfer, pin | 72/232; state machine in §15 | Hover-only, route-state ownership, persistent DB setting |
| `RynTopUtilityBar` | Global search/theme/profile | Raised utility material | Tab order, tooltips, Enter/Space | Full search → icon/popover as width tightens | Page filters, no-op production control, large card |
| `RynMaterialSurface` | One restrained utility/material primitive | Navigation/utility/context only; opaque fallback | Does not add focus itself | Transparency disabled/performance fallback | General content glass, nested glass |
| `RynFocusBlock` | One coherent task group | Primary/secondary content surface | Heading landmark, logical child order | Reflows; no fixed text height | Wrapping every row or nesting panels |
| `RynSplitWorkspace` | Role-based navigator/workspace/inspector layout | Opaque content panes | Pane order and focus handoff | 1/2/3 panes per §17; sheets at compact | Equal dashboard grid, illegible pane shrink |
| `RynInspectorPane` | Optional metadata/reference/context | Secondary surface, divider from primary | Focusable only when visible; Esc closes temporary form | Inline wide; context sheet/drawer compact | Primary action or sole critical information |
| `RynContextPopover` | Source-linked contextual commands/editor | Raised utility/context material | Focus trap where modal, Esc/outside close, restore source | Flip/shift to viewport; dialog fallback | Full workflow, nested popovers, hidden labels |
| `RynAdaptiveSearch` | Global or scoped search grammar | Utility or primary surface | Text input, clear, Esc, results arrows when listbox | Field → icon-triggered popover | Unlabeled/no-op search, shared hidden scope |
| `RynPrimaryButton` | Dominant next action | Blue filled; white/light readable label | Enter/Space, busy/disabled semantics | Wrap label or widen; >=44 target | Multiple competing primaries, semantic status colors |
| `RynSecondaryButton` | Alternative action | Outline/neutral surface | Enter/Space, focus ring | May wrap into action row | Destructive disguised as neutral |
| `RynIconButton` | Compact familiar action | Neutral/utility/content | Tooltip + semantics mandatory, Enter/Space | >=44 target; label replacement if unfamiliar | Primary unfamiliar action, missing tooltip |
| `RynSegmentedFilter` | Small single-choice mode/filter | Neutral with blue selected tint | Arrows, Enter/Space, selected semantics | Scroll/wrap or alternate control | Many options, group multi-select, color-only selection |
| `RynTabBar` | Peer content sections | Content/page toolbar | Left/Right, Home/End, focus ring | Scrollable before label compression | Workflow steps, destructive actions |
| `RynEmptyState` | First-use absence + one next action | Content surface, minimal illustration | CTA in logical order | Compact copy/illustration at narrow width | Fake data, giant decorative card |
| `RynNoResultsState` | Search/filter mismatch + reset | Existing content region | Clear/reset action, announce result count | Does not remove filters/navigation | Treating no-results as empty/create state |
| `RynModalSheet` | Bounded complex editor/management | Modal context, opaque primary surface | Focus trap, Esc, restore source | 560–760 desktop; drawer/sheet compact | Full-width mobile sheet by default, nested modal |
| `RynTooltip` | Concise action explanation | Raised utility material, high contrast | Non-focusable; semantics on source | Repositions within viewport | Primary instruction or hidden required info |
| `RynFocusIndicator` | Consistent keyboard focus | 2 px blue exterior ring in both modes | Input-modality aware; never clips | Follows target geometry | Glow, color-only or mouse-only state |

### 43.2 Implementation sequence checklist

- [ ] Add/rename semantic tokens without deleting legacy aliases used by unmigrated modules.
- [ ] Add motion and material-fallback tokens; no new package.
- [ ] Extract shell chrome from `main.dart` without moving feature/domain logic.
- [ ] Implement rail state machine with one owner and session-only pinned state.
- [ ] Implement lazy-preserved page host; verify feature `State` identities survive route and rail mode changes.
- [ ] Preserve per-page scroll position with stable `PageStorageKey` or an owned scroll controller; do not rely on subtree coincidence.
- [ ] Disable ticker and focus participation for inactive preserved pages without disposing them.
- [ ] Replace duplicated top utility construction with one shell slot.
- [ ] Preserve global theme state and all callbacks.
- [ ] Keep global search explicitly disabled/hidden until functional if implementation is out of scope.
- [ ] Add keyboard, semantics, reduced-motion, reduced-transparency, and text-scale tests.
- [ ] Run focused regression tests only as authorized.
- [ ] Perform Owner QA in normal maximized Windows environment, Light and Dark.
- [ ] Confirm no DB/schema/repository/domain behavior changed.

### 43.3 Proposed allowlist: `RYN-GLOBAL-SHELL-COLLAPSIBLE-RAIL1`

Smallest practical initial allowlist:

1. `lib/main.dart` — retain `CoreOsShell` state/callback wiring; replace only shell chrome/page-host composition.
2. `lib/core/theme/ryn_tokens.dart` — add R2 semantic, motion, radius, material-fallback tokens while preserving migration aliases.
3. `lib/core/shell/ryn_app_shell.dart` — new stable shell/page-host and workspace slots.
4. `lib/core/shell/ryn_adaptive_navigation_rail.dart` — new Compact/Peek/Pinned state machine and focus behavior.
5. `lib/core/shell/ryn_top_utility_bar.dart` — new global utility component using existing theme scope callbacks.
6. `test/widget_test.dart` — extend existing shell integration coverage.
7. `test/core/shell/ryn_adaptive_navigation_rail_test.dart` — new focused state/keyboard/semantics tests.

Any additional production path requires HOLD and a revised allowlist. Feature presentation, controller, repository, persistence, domain, assets, `pubspec.yaml`, fonts, and generated DB files remain outside the allowlist.

`lib/main.dart` is not a blanket-edit allowance. Existing runtime/bootstrap, `_CoreOsShellState` callbacks, Records identity wiring, Settings/Data Safety behavior, and Reading/Tarot/Oracle transition semantics remain unchanged. The implementation may alter current shell-frame/chrome composition and make the minimum page-host insertion needed for preservation; feature constructors, callback ordering, destination labels/order, and immersive visibility rules are regression contracts.

## 44. PASS / HOLD criteria for future visual migrations

### PASS

A migration may PASS only when:

- authorized paths only changed;
- semantic tokens replace arbitrary shared colors/radii/durations;
- Light/Dark and opaque fallback are coherent;
- keyboard, focus, tooltip, semantics, and Escape contracts pass;
- 125% and 150% text-scale smoke has no clipped/inaccessible shell action;
- reduced motion/transparency works;
- feature state and behavior remain within regression boundary;
- Owner maximized-window QA accepts hierarchy, workspace, identity, and motion;
- no DB/schema/repository/domain/package/font change occurred unless separately authorized;
- staged/commit/push actions follow their own approval.

### HOLD

Return HOLD when any of the following occurs:

- global shell migration needs broad route/domain architecture changes;
- route or rail animation recreates a feature page or loses meaningful transient state;
- blur is required for readability or performance is unstable;
- color alone communicates selection/status;
- icon-only actions lack tooltip/semantics;
- keyboard focus is lost, hidden, trapped incorrectly, or out of order;
- 150% text scale clips a required action;
- module identity relies on large tinted background, decorative gradient, or mixed accents;
- normal Owner viewport evidence is missing for a visual acceptance claim;
- an unapproved package/source/data/schema/repository path is required;
- source behavior changes are bundled into a visual migration without explicit approval.

---

# Appendix A. Current-source architecture audit

Audit baseline: `419b1b3b847fc518b7eb42391bb2b6c8ade0b316`. This audit is read-only and does not authorize implementation.

## A1. Where navigation state currently lives

`CoreOsShell` is a `StatefulWidget`; `_CoreOsShellState._selectedNav` owns the selected destination in `lib/main.dart:461-580`. Destinations are string labels in `CoreOsShell.navigationItems` (`lib/main.dart:467-479`). Navigation is not a Router/Navigator route graph; `_selectNav` calls `setState`.

## A2. Whether routes preserve feature state

**Partially.** Shell-owned state survives route label changes: Oracle controller, session Tarot results/drafts, active result, and selected record detail live in `_CoreOsShellState` (`lib/main.dart:549-572`). Persisted People/domain data survives through repositories. However page-local UI state is not guaranteed: `PeoplePage` owns its controller/search lifecycle, and `_ReadingWorkspacePage` owns `_tarotOpen`/`_oracleOpen` (`lib/main.dart:2977-3071`).

## A3. Whether page widgets are recreated on navigation

**Yes, for conditional feature subtrees.** `_ShellPageContent.build` creates a different `body` list by `selectedLabel` (`lib/main.dart:1006-1123`) with no `IndexedStack`, page bucket, or `PageStorage` host. Leaving and returning can recreate stateful feature roots and reset transient search/tab/scroll/reading-open state. The persisted/domain state may survive, but widget state continuity is insufficient for R2. This can be fixed inside the shell with a lazy-preserved page host; it does not require broad route architecture redesign.

Rail geometry also switches between two parent compositions at width 1600 (`lib/main.dart:694-772`). R2 must prove that changing rail mode does not dispose the page host.

## A4. Where top utility controls are built

`_TopSystemBar` in `lib/main.dart:3127-3244` builds search placeholder, theme toggle, and owner chip. `_ShellPageContent` inserts it repeatedly for Home, Study, People, Records, and generic areas (`lib/main.dart:1008-1123`); `_ReadingWorkspacePage` also inserts it at `lib/main.dart:3050-3069`. Search buttons/placeholder currently include no-op behavior in compact variants (`lib/main.dart:3151-3155`, `3182-3186`), so R2 shell must hide/disable honestly or implement search in a separately authorized scope.

## A5. Where Light/Dark state is controlled

`_RynUniverseAppState._themeMode` owns session theme state (`lib/main.dart:113-160`). `_ThemeModeScope` distributes mode/change callback (`lib/main.dart:267-283`). `_HeaderThemeToggle` uses that scope (`lib/main.dart:3246-3271`) and Settings reuses the toggle (`lib/main.dart:2724-2747`). Theme choice is session-only in the inspected architecture.

## A6. Current shared theme/token architecture

`lib/core/theme/ryn_tokens.dart` contains:

- `RynSemanticColors extends ThemeExtension` and Light/Dark role values (`lines 9-162`);
- `RynTheme.light/dark` and Material 3 `ThemeData`/`ColorScheme` wiring (`lines 164-311`);
- spacing/radius/border/elevation/interaction constants (`lines 314-508`);
- legacy dark/gold/violet/command/Kanban aliases retained for migration.

`lib/main.dart:285-357` also defines compatibility `RynPalette` and `RynMetrics`, creating a second token access layer. People largely consumes `context.rynColors`; Home/Reading/Tarot/Oracle still contain direct colors, gradients, shadows, and local durations. R2 should extend the semantic architecture, not replace ThemeData or add a package.

## A7. Likely files for Global Shell implementation

Use the seven-path allowlist in Section 43.3. `main.dart` remains necessary because state/callback composition and current shell are private there. New shell components isolate future chrome without moving feature logic.

## A8. Files that should remain untouched

- all `lib/features/**` files in the first shell task;
- `lib/core/persistence/**`, repositories, runtime services, domain models, generated DB code;
- `pubspec.yaml`, assets, fonts, platform runners;
- People custom-group behavior and tests except shell-level integration assertions;
- Tarot/Oracle internal stage widgets and controllers;
- Home content components;
- backup/restore implementation.

## A9. Whether a contained shell refactor is sufficient

**Yes.** Keep `_CoreOsShellState` as the owner of selected destination and existing callbacks, introduce a stable `RynAppShell`, extract rail/top utility, and host pages in a lazy-preserved stack/bucket. This is a contained visual/state-host refactor.

## A10. Whether broad architecture change is necessary

**No.** A Router package, navigation framework, dependency addition, feature-controller move, or domain refactor is not justified for `RYN-GLOBAL-SHELL-COLLAPSIBLE-RAIL1`. If a stable page host cannot be implemented within the allowlist without changing feature ownership, the next task must stop with `HOLD_SHELL_ARCHITECTURE_BLOCKER`.

# Appendix B. Current-surface migration observations

- **People:** strongest neutral reference; master/detail split at 920 px, semantic colors, search/filters/tooltips. Desktop bottom sheets and page-local lifecycle need shell-aware refinement, not behavior change.
- **Home:** useful content-first scene exists, but direct warm/deep gradients, large shadows, and inline colors remain. Shell compatibility comes before content migration.
- **Records:** simple constrained list/detail and an existing two-pane detail at 1000 px; good structural base, with repeated rounded containers and dark Tarot staging to review later.
- **Reading Atelier:** adaptive 1180/900 composition exists, but decorative gradients, shadow, and inline colors conflict with R2.
- **Tarot:** mature staged stateful flow and content viewing areas exist; numerous local colors/durations and gold selected grammar are migration targets, not shell-task scope.
- **Oracle:** complete setup/shuffle/draw/result/interpretation flow; gradients, gold selected border, hover lift, and local motion need a later R2 pass.
- **Settings:** currently generic business-area card/chips plus theme and data safety; requires categorized workspace later while preserving backup/restore behavior.

# Appendix C. Risks and controls

| Risk | Impact | Control |
|---|---|---|
| Conditional page rebuild resets transient state | Lost search/flow/scroll context | Lazy-preserved page host; identity/disposal test |
| Extracting private shell widgets from a very large `main.dart` | Scope drift | Seven-path allowlist; move chrome only, preserve callbacks |
| All lazy pages built at startup | Startup/performance cost | Instantiate on first visit, then preserve |
| Inactive pages keep animations/focus alive | CPU/focus defects | `TickerMode`, `Offstage`, focus exclusion; tests |
| Existing fixed-height People regions or modal-only errors fail under scaling | Clipping or inaccessible feedback | Reflow/scroll at 1.25/1.5 and modal-local live regions in the later People migration |
| Windows blur unavailable/expensive | Unreadable/slow chrome | Opaque token fallback with identical geometry |
| Existing no-op search looks functional | Trust/accessibility defect | Hide or visibly disable until separately implemented |
| Legacy token aliases leak into R2 components | Mixed visual language | New shared components consume semantic R2 roles only |
| Text scaling expands top bar/rail labels | Clipping | Minimum constraints, wrapping/reflow, 1.25/1.5 smoke |
| Rail PEEK collapses during keyboard use | Lost focus | Focus-inside guard and explicit Escape transfer |
| Module migration alters business behavior | Regression/data risk | Stage-specific regression boundary; feature files untouched in shell task |

# Appendix D. Decision summary

- Final shell direction: neutral adaptive workspace, not universal cinematic canvas.
- Final interaction accent: blue only.
- Final rail contract: 72 Compact, 232 Peek/Pinned, 200 ms `easeOutCubic`, 140 ms label fade, 6 px slide, session-only pin.
- Final workspace guidance: Compact `<1100`, Standard `1100–1599`, Wide `>=1600`, adjusted only by content role.
- Final material rule: one restrained utility layer with opaque Windows fallback; content stays opaque.
- Final architecture judgment: contained shell refactor sufficient; broad route architecture change unnecessary.
- Final next boundary: `RYN-GLOBAL-SHELL-COLLAPSIBLE-RAIL1` may begin only under its explicit seven-path allowlist and separate Owner approval.
