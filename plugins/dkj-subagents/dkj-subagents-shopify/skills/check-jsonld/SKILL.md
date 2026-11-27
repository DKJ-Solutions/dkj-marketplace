---
name: check-jsonld
description: >-
  Validate the JSON-LD structured data of Shopify storefront pages per market, also on a preview theme. Use after a structured-data change, or to prove a preview emits valid schema.
argument-hint: "[-Path <path>[,<path>]] [-Market <market>] [-ThemeId <id>] | -Url <url> [-PlanOnly]"
---

# check-jsonld -- prove the structured data mechanically

Preview URLs are publicly reachable, but Google's Rich Results Test does not follow the preview cookie
reliably, so the dependable check is to fetch the page and parse the JSON-LD yourself. Inbound
[#4290](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4290).

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/check-jsonld.ps1" -ThemeId 123456789012 -Path '/','/pages/reviews' -Market UK
```

`${CLAUDE_PLUGIN_ROOT}` resolves **only inside a plugin-owned component**. From an ordinary shell, spell the
plugin cache path out.

| Parameter | What it is for |
|---|---|
| `-Path` | storefront path(s), default `/`, each starting with `/`, crossed with every market the store's `Get-StorefrontMarkets` seam lists. Unanswered, it refuses and names `-Url`. |
| `-Market` | only these markets (the seam's `Market` labels, case-insensitive). Default: all. |
| `-ThemeId` | measure a preview theme: adds `preview_theme_id` plus `_ab=0&_fd=0&_sc=1`, and fails the page when it served another theme. Leave out for live. |
| `-Url` | full URL(s) instead of `-Path`/`-Market`. No preview suffix is added: put it in yourself. |
| `-PlanOnly` | print the targets and stop, touching no network. Use it to check the invocation form first. |
| `-Full` | print the raw JSON per block (to paste into validator.schema.org) instead of the summary. |
| `-SaveTo` | folder to keep the fetched HTML in. |

## What it reports

Per page, per block: the `@type`, `JSON OK` or `JSON INVALID` (with the first 400 characters of the block),
then a summary of only the fields that go wrong in practice: breadcrumb `@id`s, `Product` url / offer /
rating, `Organization` and `WebSite` details, `ItemList` per-product ratings (flagged when every product
carries the same value), `NewsArticle` where `BlogPosting` belongs, and for `FAQPage` the **answer text**
(empty or still the rich-text object, a metafield wrapper div, leftover HTML tags, an HTML entity), because
the answer is what breaks while the Liquid and the JSON stay valid. Protocol-relative `"image": "//..."`
values are counted.

Exit code 1 when a block holds invalid JSON, a page cannot be fetched, or a page served another theme than
`-ThemeId`; 0 otherwise. Shopify serves a bot-protection page (HTTP 429) after a few dozen automated
requests; it is reported as a fetch failure rather than "no JSON-LD". Measure fewer pages per run, or wait.

## The comma trap, and why the script splits and checks

`powershell -File <script> -Path '/a','/b'` binds the **whole list as one string**: with `-File` every
argument is a bare string. In a store this produced two paths asked, **one** measured (a single path with a
comma in it, which Shopify resolved to the product page), "all valid", exit 0, over a page nobody asked for.
So the script splits `-Path`, `-Market` and `-Url` itself (`scripts/lib/comma-list.ps1`) and then refuses
every target of the wrong shape, so a comma inside a query string stops the run instead of being glued onto
a domain. The split is generic; the shape check is not, so it stays with the script
(`Get-TargetShapeErrors`).

## The seam

| seam | required? | what it answers |
|---|---|---|
| `Get-StorefrontMarkets` | only for `-Path` | the same rows `which-theme` reads: `Market`, `Domain` (bare host) and optional `PathPrefix`. Both scripts read it through `scripts/lib/storefront-markets-lib.ps1` and build URLs with `Get-ProbeTargets`, so there is one market-table reader. |

## What is tested, and what cannot be

`scripts/tests/shopify-check-jsonld.tests.ps1` pins the pure rules in `scripts/lib/check-jsonld-rules.ps1`
(block extraction, the per-type findings including the four broken FAQ shapes, market filtering, the shape
check), the comma split, the shared seam reader, and drives the script through `powershell -File ... -PlanOnly`
against a fixture store, which is the form that sets the comma trap. The fetch itself is not driven, because
a suite must not reach a store.
