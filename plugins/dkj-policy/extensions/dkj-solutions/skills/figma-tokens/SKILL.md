---
name: figma-tokens
description: Check whether the brand book's colour variables in Figma still match house-style.css, and sync Figma from the stylesheet on request -- in one direction only, the repo being the source. Use when someone asks whether the Figma tokens are still in sync, after a brand book colour change has merged (a theme, a status colour, a graph slot), or when asked to update the Figma variables from the repo, in whatever language. Runs in dkj-marketplace, where the brand book lives, through the Figma MCP's use_figma. The drift check is read-only; the sync writes only on request.
---

# figma-tokens -- the brand book's colours, mirrored into Figma

**The repo is the source and Figma is a mirror** (Dave, issue
[#4038](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4038), November 12, 2026). Most of the colours
in [`house-style.css`](../../../../assets/dkj-brandbook/house-style.css) are computed by
`build-house-palette.ps1` and held to their contrast floors by the `house-palette` suite, so an edit made in
Figma would bypass both. **Nothing here writes a Figma value back into the stylesheet.** A colour wanted in
Figma is a brand book change: an issue here, then the build, then this sync.

**The scope is the colour tokens only** (the owner, November 13, 2026, on #4038): every custom property whose
value is a `#rrggbb` colour, which is the 25 of today. Spacing, radius and type are not mirrored.

## What the Figma file holds

The target is the brand book's Figma file, key `w44J5aQPeST96RJ71vU3ev` (the one whose *Wireframes* page is
the source for Admin's layout). It already held this layout when the skill was built, measured November 13,
2026, and the sync keeps it rather than inventing a second one:

| Collection | Modes | Variables |
|---|---|---|
| `House / Palette light` | one per light theme: `magenta` ... `rust` | `palette/<token>`, the resolved hex, hidden from the pickers |
| `House / Palette dark` | one per dark theme: `pink` ... `orange` | the same |
| `House / Theme` | `Light`, `Dark` | `color/<token>`, an alias to `palette/<token>` in the palette of that mode, with scopes and `var(--<token>)` as WEB code syntax |

A design binds to `color/*` and picks a theme by setting the palette collection's mode on a frame. **Six modes
in one collection is measured, not assumed**: the file holds two such collections on the owner's Professional
plan. Figma's own reference gives Professional a lower cap, so do not split the palettes on its word.

**A theme resolves the way the browser resolves it**: a light theme is `:root` plus its own theme line, a dark
theme is `:root`, then the forced dark block, then its own line. So the dark status colours, rust's and
yellow's own `--warning-3`, and each theme's graph slots all land in the right mode.

## The drift check -- read-only, run it freely

All three steps run from the root of `dkj-marketplace`. Load the Figma MCP's `figma-use` skill first, and
open a session on the file (`create_session`) before the first `use_figma`.

1. Print the read script:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File plugins/dkj-policy/extensions/dkj-solutions/scripts/task/figma-tokens.ps1 -Emit read-js
   ```

2. Run it unchanged through `use_figma` on the file. It reads the three collections and writes nothing.
3. Save what it returned, as returned, to a file in your scratchpad, and compare:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File plugins/dkj-policy/extensions/dkj-solutions/scripts/task/figma-tokens.ps1 -Compare <saved.json>
   ```

   Exit 0 prints `[OK] Figma matches the stylesheet`. Exit 1 prints one `[DRIFT]` line per missing
   collection, mode or variable, per extra one, and per value that differs (an alias pointing at the wrong
   palette included), naming the value Figma holds and the one the repo holds. Mode order is not drift.

## The sync -- writes Figma, on request only

Run it when somebody asks for the Figma variables to be updated, or after a drift check whose cause is a
merged brand book change. **A drift whose Figma value is the one wanted is not synced away**: say so, and the
change goes to the brand book as an issue first.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File plugins/dkj-policy/extensions/dkj-solutions/scripts/task/figma-tokens.ps1 -Emit sync-js
```

Run the printed script through `use_figma`. It creates any collection, mode or variable that is missing and
overwrites any value that differs, then returns per collection what it created and wrote and which variables
it found that the stylesheet does not have. **It deletes nothing**: an extra variable or mode can still be
bound in a design, so removing it is a person's decision, made in Figma. Close with a drift check; it should
print `[OK]`.

## Where it lives

The script is [`scripts/task/figma-tokens.ps1`](../../scripts/task/figma-tokens.ps1), the model in
`scripts/lib/figma-tokens-lib.ps1`, and the `figma-tokens` suite holds both. It reads the stylesheet from the
brand book's own folder in this tree, so it runs in `dkj-marketplace`, as `build-house-palette.ps1` does; a
consuming repo never syncs the brand book's Figma file.
