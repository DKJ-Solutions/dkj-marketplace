---
name: measure-buybox
description: Measure where the add-to-cart button sits in a Shopify product page's buy box, on a really emulated phone viewport (a local headless Chrome, DevTools device emulation), with the offset of every block in the box, the box's place on the page and the sticky add-to-cart bar. Use it when a height requirement on the buy box has to be a number instead of a look, or to check that a layout change moved the button. With the store's expectation answered it prints PASS or FAIL. Read-only: it loads one public page and writes nothing to the store. Needs node 22+ and Chrome.
argument-hint: "(-Url <url> | -Market <market> -Path <path> [-PreviewThemeId <id>]) [-Width 390] [-Height 900] [-SettleMs 5000] [-BoxSelector <css>] [-AtcSelector <css>] [-Json] [-PlanOnly]"
---

# measure-buybox -- a height is a number, so measure it

No gate proves that something looks right, but a height is not taste. This check starts a headless Chrome,
sets a real phone viewport, loads one page and reports where the add-to-cart (ATC) button sits in the buy
box. Inbound [#4290](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4290).

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/measure-buybox.ps1" -Market NL -Path /products/some-product
```

`${CLAUDE_PLUGIN_ROOT}` resolves **only inside a plugin-owned component**. From an ordinary shell, spell the
plugin cache path out.

| Parameter | What it is for |
|---|---|
| `-Url` | the full address to measure. Excludes `-Market`/`-Path`. |
| `-Market` + `-Path` | build the address from the store's `Get-StorefrontMarkets` seam (`https://<Domain><PathPrefix><path>`). |
| `-PreviewThemeId` | measure a preview theme, with the full preview parameters (`_ab=0&_fd=0&_sc=1`), not the id alone. |
| `-Width` / `-Height` | the viewport. Default 390 x 900. |
| `-SettleMs` | the wait after load. Late-filled blocks appear after it; too short a wait measures an incomplete row and so a button that sits too high. Default 5000. |
| `-BoxSelector` / `-AtcSelector` | override the seam's key for a one-off run. With both given the seam is not read. |
| `-Json` | the raw measurement line instead of the report. |
| `-PlanOnly` | print the address and the selectors this run would use, then stop. No node, no browser. |

## The store's facts, through one seam

Which element is the buy box, which one the ATC button and what the store expects is per theme, so it is the
store's: `Get-ShopifyBuyBox` in `scripts/repo-config.ps1`, returning a hashtable. Required: `BoxSelector`,
`AtcSelector`. Optional: `BlockSelectors` (a list), `StickySelector`, `MobileMaxWidth` (default 749), and
the expectation `AtcMaxTop` **with** `AtWidth`. The row shape is in the plugin README's seam table. Unanswered
and no overrides, the check says `REFUSED:` and names the seam and its row shape. Nothing in the harness names
a theme selector: they arrive as input.

## The verdict

Only with `AtcMaxTop` answered **and** a measured `innerWidth` equal to `AtWidth` does it print `PASS` or
`FAIL` (exit 1 on FAIL). The width compared is the **measured** one, never the requested one. Without an
expectation, or at another width, it measures and says why it did not judge.

## Two routes that look right and measure the wrong width

That is why a Chrome is started instead of using the browser you have open:

1. **Shrinking the window** (a resize call, `window.resizeTo`) reports success and leaves
   `window.innerWidth` at the old value once the window is maximised.
2. **A 390px iframe or container.** Media queries look at the viewport, not at the parent's width, and a
   storefront may refuse framing anyway.

Only `Emulation.setDeviceMetricsOverride` really changes the CSS viewport. The failure direction is
asymmetric: a too-high measurement stands out, a silent desktop-width one reads as a met mobile requirement.
So the measured width is always printed, and when it is not the requested one the line says so in red. **Read
the `viewport` line before believing the rest.**

## What the offset does not say

The offset is counted from the top of the buy box, which is not the fold: the box itself starts below the
gallery. And a sticky bar with an ATC button of its own may be pinned to the window, outside the box, where
the offset does not reach. The report therefore ends with the box's place on the page, the ATC button's
distance from the page top, and the sticky bar, so a missed offset is not read as an unreachable button.

## Requirements and failure

node 22 or newer (the harness uses its built-in WebSocket, no `node_modules`) and Chrome (set `CHROME_EXE`
for a non-standard location). **node absent is a refusal, not a skip**: a skipped measurement is green and
measures nothing. The node call is bounded (the settle wait plus 120 s), so a hung Chrome ends the run as a
failure. Exit 1 on a refusal, a failed or timed-out measurement, no buy box, no ATC button, or FAIL.

## What is tested, and what cannot be

`scripts/tests/shopify-measure-buybox.tests.ps1` pins the pure rules in `scripts/lib/measure-buybox-rules.ps1`
(seam validation and overrides, the address, the harness input and its one-line JSON, the verdict including the
width-mismatch case, the report), the seam read, and the whole driver against a stand-in `node.cmd` with canned
harness JSON (Windows only), plus static guards: the harness holds no theme selector, the node call is bounded.
Chrome itself is not driven, because a suite must not need a browser or reach a store; a `node --check` on the
harness runs where node exists.
