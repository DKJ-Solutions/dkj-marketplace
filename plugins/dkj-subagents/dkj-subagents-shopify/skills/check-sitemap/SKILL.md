---
name: check-sitemap
description: Report the layout of a Shopify store's sitemap per domain and market -- how many sub-sitemaps there are and why, which sitemap holds a URL, URLs that sit in more than one sitemap, the per-kind URL count difference between the locales of one domain, and with -Catalog the products, collections and pages the public JSON lists have that the sitemap does not (a noindex page is told apart from a real gap). Use it to find out whether a page is in the sitemap and in which one, or to check a sitemap for duplicates and gaps. Read-only: it only fetches public storefront URLs.
argument-hint: "[-Market <market>[,<market>]] [-Locale <locale>] [-Find <term>] [-Catalog] [-IndexOnly] [-CsvOut <file>] [-PlanOnly]"
---

# check-sitemap -- make the sitemap visible, and check it for mistakes

Shopify generates the sitemap index itself, splits product sitemaps at 1,000 URLs and puts every locale of
a domain in one index. There is no theme file or setting to shorten it, so this check does not make the
sitemap smaller: it shows what is in it and finds what is wrong. Inbound
[#4290](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4290).

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/check-sitemap.ps1" -Market NL -Catalog -CsvOut sitemap-nl.csv
```

`${CLAUDE_PLUGIN_ROOT}` resolves **only inside a plugin-owned component**. From an ordinary shell, spell the
plugin cache path out. Start with `-IndexOnly` (one request per domain) before a full crawl.

| Parameter | What it is for |
|---|---|
| `-Market` | the markets to measure (the seam's `Market` labels, case-insensitive; a comma separates them). Default: all. It picks **domains**; it does not narrow the locales of a shared domain. |
| `-Locale` | only these locales of the index (`(root)` is the main locale without a path prefix), e.g. `en`. |
| `-Find` | which sitemap holds a URL containing the term (a full URL or a handle). |
| `-Catalog` | compare the sitemap with `products.json`, `collections.json` and `pages.json` of the main locale. |
| `-IndexOnly` | fetch and split only the index; leave the sub-sitemaps unread. |
| `-CsvOut` | the full URL-to-sitemap table as CSV (`Domain, Market, Locale, Kind, Url, Sitemap`). |
| `-SaveTo` | folder to keep the fetched XML in. |
| `-DelayMs` / `-MaxRetries` / `-AbortAfter` | pacing, retries on a 429, and the stop after consecutive failures (defaults 500, 4, 5). |
| `-PlanOnly` | print the index URLs and stop, touching no network. Use it to check the invocation form first. |

## Markets and domains

Shopify serves **one** sitemap index per domain, at `/sitemap.xml`. So the check groups the selected market
rows by `Domain`, fetches each index once, and reports per domain. A market with a `PathPrefix` shares its
domain's index with the other prefixes: the locale of a sub-sitemap (`(root)`, `en`, `de`, ...) is matched to
the market whose `PathPrefix` is that locale, in the report and in the CSV. A locale no market row names is
still reported, with no market. The rows come from the store's `Get-StorefrontMarkets` seam through
`scripts/lib/storefront-markets-lib.ps1`, the one reader `which-theme` and `check-jsonld` use; unanswered, the
check refuses and names the seam.

## What it reports

1. **The index**, split by locale and kind, with the locales named.
2. **URLs per locale** (total, unique, duplicate) and every **duplicate**: a URL in more than one sitemap,
   with the sitemaps (labelled `en/sitemap_products_1.xml`, because the bare file name repeats across locales).
3. **The locale difference, as a count per kind.** Not a path comparison: Shopify translates the handle per
   locale and the sitemap carries no hreflang alternates, so paths side by side report the whole catalogue as
   a gap on a healthy sitemap (measured: ~200,000 false "missing" paths). A kind that exists in one locale only
   is not a gap.
4. **With `-Catalog`**, both directions per kind: in the catalogue but not in the sitemap, and in the sitemap
   but not in the catalogue. A missing page is first tested for a robots `noindex`: Shopify leaves those out on
   purpose, so their absence is correct and is not counted. A list the public endpoint cuts off at its
   25,000 limit (`page * limit`) is **not compared** and the output says so, because a comparison on the first
   25,000 is a "missing" list that only marks where the limit is. Articles have no public list and are not
   compared.
5. **With `-Find`**, where a URL sits; **with `-CsvOut`**, the same for every URL.

**An incomplete crawl draws no conclusion.** If any sitemap could not be fetched, every conclusion carries
`INCOMPLETE`, the duplicate, locale and catalogue results are withdrawn or skipped, and the green outcome is
withheld. The first measurement reported "duplicates: none" over a crawl in which 188 of 207 sitemaps were
never fetched.

Exit code 1 on a fetch failure, a duplicate, a locale difference or (with `-Catalog`) a catalogue item missing
from the sitemap; 0 otherwise.

## Rate limit

A full crawl of a large store is 200+ requests (~80 MB). Unthrottled, Shopify serves its bot-protection page
(HTTP 429, "Verifying your connection...") after about twenty. The check paces itself (`-DelayMs`), retries a
429 with a growing wait (5s, 15s, 45s, 135s), counts a bot-protection page that arrives with HTTP 200 as a 429
too, and stops a domain after `-AbortAfter` consecutive failures instead of printing hundreds of identical lines.

## The comma trap

`powershell -File <script> -Market A,B` binds the **whole list as one string**. The script splits `-Market`,
`-Locale` and `-Find` itself (`scripts/lib/comma-list.ps1`).

## What is tested, and what cannot be

`scripts/tests/shopify-check-sitemap.tests.ps1` pins the pure rules in `scripts/lib/check-sitemap-rules.ps1`
(the entity decoding, locale and kind from a sub-sitemap URL, grouping by domain, the backoff schedule with a
fake fetcher, catalogue paging and its ceiling, the catalogue comparison, the noindex test, the per-kind locale
difference), the shared market selection, the invocation form through `powershell -File ... -PlanOnly` against
a fixture store, and static guards for the incompleteness flag and the read-only promise. The crawl itself is
not driven, because a suite must not reach a store.
