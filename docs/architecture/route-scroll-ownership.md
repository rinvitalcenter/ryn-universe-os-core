# Route scroll ownership

`GLOBAL-SCROLL-OWNERSHIP1` makes vertical ownership explicit without changing domain or persistence contracts.

## Global contract

- `RynWorkspaceHost` owns finite viewport constraints, workspace padding, alignment, width envelopes, and `DesktopViewportMetrics`.
- The host never inserts a vertical `SingleChildScrollView`.
- `RynWorkspacePresentation` declares `featurePage`, `viewportBounded`, or `independentPanels`.
- One vertical axis has one primary owner. Same-axis nesting is forbidden unless a child is an intentional independent panel.
- Scroll controllers remain widget-owned; this migration does not create controllers in `build`.

## Ownership matrix

| Route or stage | Mode | Primary vertical owner | Independent panel scroll | Bounded | CTA behavior |
| --- | --- | --- | --- | --- | --- |
| Home | `featurePage` | Home page scroll | No | No | First-view actions remain in the scene |
| Reading Atelier | `featurePage` | Atelier page scroll | No | No | Tarot and Oracle entry remain reachable |
| Records list | `featurePage` | Records page scroll | No | No | Record actions move with the document |
| Tarot result detail | `featurePage` | Detail page scroll | No | No | Back and Home actions remain reachable |
| People | `independentPanels` | Master/detail panels | Yes | Yes | Search, filters, selection remain panel-local |
| Tarot target/question | `featurePage` | Tarot setup page scroll | No | No | Next action is reachable by page scroll |
| Tarot deck selection | `featurePage` | Tarot setup page scroll | No | No | Carousel reveal is preserved |
| Tarot detailed preparation | `featurePage` | Tarot setup page scroll | No | No | Long preparation continues below viewport |
| Ritual | `viewportBounded` | None | No | Yes | Toolbar actions remain fixed and reachable |
| Selection | `viewportBounded` | None | No | Yes | Toolbar stays visible; fan crop is intentional |
| Revelation | `viewportBounded` | None | No | Yes | Interpretation action remains reachable |
| Interpretation | `independentPanels` | Story region | Yes | Yes | Completion dock remains outside story scroll |

## Constraint and input rules

- Normal pages receive finite width and height and own overflow locally.
- Ritual, Selection, and Revelation do not gain document scroll at reduced height.
- Selection preserves the 78-card fan geometry inside a clipped bounded board.
- Keyboard, wheel, focus, and page-storage behavior stay with each existing feature scrollable.
- Width coordinates 419/420, 719/720, and 2199/2200/2201 remain audit coordinates, not new breakpoints.

## Deferred and protected

QHD/UHD visual expansion, Home tall-screen polish, Reading wide-screen polish, and `TAROT-LARGE-DISPLAY-POLISH-R1` remain deferred. Tarot context/person semantics, card engine and 78-card contracts, result/draft lifecycles, DB, schema, migrations, repositories, persistence, and backup/restore are unchanged.
