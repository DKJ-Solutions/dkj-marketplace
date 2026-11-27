---
name: which-theme
description: >-
  Establish which theme a Shopify storefront URL actually serves, and whether it is fresh or cached. Use when reviewing a preview or checking a live push.
argument-hint: "[-Url <url> | -Path <path>] [-ThemeId <id>] [-ExpectThemeId <id>]"
---

# which-theme -- what the storefront really serves

Reviewing a preview, the question is not "am I in a preview session" but "do I get the content I think I
get". The admin's indicator describes the **session**, not the version of the content, and a cookie can drop
on an internal link or an edge cache can hold the old page. Inbound
[#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289).

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/which-theme.ps1" -Url 'https://your-store.example/products/foo' -ThemeId 123456789012 -ExpectThemeId 123456789012
```

`${CLAUDE_PLUGIN_ROOT}` resolves **only inside a plugin-owned component**. From an ordinary shell, spell the
plugin cache path out.

| Parameter | What it is for |
|---|---|
| `-Url` | full address(es). |
| `-Path` | path(s) such as `/` or `/products/foo`, across every market the store's `Get-StorefrontMarkets` seam lists. Unanswered, it refuses and names `-Url`. |
| `-ThemeId` | adds `preview_theme_id` plus `_ab=0&_fd=0&_sc=1`, the three parameters the admin sends so the preview survives the first internal click. |
| `-ExpectThemeId` | exit 1 when a page serves another theme. |
| `-MustContain` / `-MustNotContain` | fingerprints: text only the new version has, or markup you just removed. The only way to tell a cached copy of the right theme from a fresh one. |
| `-NoCache` | adds a unique parameter; fetch once with and once without to learn whether you are looking at a cache. |

## What it reports

For each page: the theme id and name Shopify embedded in the HTML (the live theme does not always send
them, which is information rather than an error), then each check. A bot-protection challenge is valid HTML
and would look like an empty page, so it is detected and counted as a failure.

**A failed fetch prints the evidence:** status code, `x-request-id`, UTC time and URL. A 500 without its
request id cannot be traced by Shopify, and a 500 carries no theme marker, so the URL is the only trace of
which theme was asked for. Put those values on the issue. The extraction lives in
`scripts/lib/fetch-failure.ps1`, which a later storefront check reuses.

Exit code: 0 when there are no deviations, 1 on any deviation or failure.

## The seam

| seam | required? | what it answers |
|---|---|---|
| `Get-StorefrontMarkets` | only for `-Path` | rows of `Market`, `Domain` (bare host) and optional `PathPrefix` (`''` or `/de`), in the store's display order. The URL is `https://<Domain><PathPrefix><path>`. This plugin reads it itself and depends on no workflow plugin. |

## What is tested, and what cannot be

`scripts/tests/shopify-which-theme.tests.ps1` pins the pure rules in `scripts/lib/which-theme-rules.ps1` and
the evidence extraction in `fetch-failure.ps1`: URL building (including the `.Contains` versus `-like '*?*'`
trap), reading the served theme, bot-protection detection, fingerprint evaluation and the market rows. The
fetch itself is not driven, because a suite must not reach a store.
