# The DKJ-Solutions brand book

**Every DKJ-Solutions app looks like one family, and this folder is where that family is written down**
(Dave, issue [#2695](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2695), October 1,
2026). The style was tuned by hand on the ETF dashboard in `dkj-etf-tracker`. Rebuilding it per repo
means re-tuning it per repo, and two hand-tuned copies drift. So the general half was lifted out once,
with **every value kept exactly as chosen** (spacing and font sizes have since moved to the Figma
library's scales, below), and the copy in this folder is the only one:
[`house-style.css`](house-style.css) and [`house-theme.js`](house-theme.js).

**It lives in the `dkj-policy` plugin**, because the plugin's own Admin and General pages render in it in
every repo, BWJ-Development's included
([#3531](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3531), October 26, 2026). The **rule**
that a DKJ-Solutions app starts from it stays in the `dkj-solutions` plugin, whose `dkj-brandbook` skill
points here and pins the files. It spent October 13 to 18, 2026 in the `dkj-brandbook` repo, came back
into `dkj-solutions` with [#3130](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3130), and
moved one level up into `dkj-policy` with #3531. **A session or a build
fetches a tagged release, never `main`** (owner's decision on
[dkj-brandbook#3](https://github.com/DKJ-Solutions/dkj-brandbook/issues/3), October 13, 2026):
`house-theme.js` is executable and runs with the origin of every page it is inlined into, and `main` is a
moving ref that an admin can push to past the review. A tag is a version somebody chose to release. Raw
URLs, with `<tag>` the release tag the skill pins, which the release cut writes into the skill
([#3133](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3133)):

- `https://raw.githubusercontent.com/DKJ-Solutions/dkj-marketplace/<tag>/plugins/dkj-policy/assets/dkj-brandbook/house-style.css`
- `https://raw.githubusercontent.com/DKJ-Solutions/dkj-marketplace/<tag>/plugins/dkj-policy/assets/dkj-brandbook/house-theme.js`

**These two files, and this README, are the core: everything Admin renders from.** The mobile-first product
layer is a third file, `house-product.css`, in the `dkj-solutions` plugin
([#3831](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3831), November 5, 2026), loaded after
`house-style.css` and never alone, and it has [a README of its own][product-readme]: the app components, the
page patterns of a product page, the site header and the breadcrumb bar. A session doing Admin work reads only
this one. Its raw URL, the same tag:
`https://raw.githubusercontent.com/DKJ-Solutions/dkj-marketplace/<tag>/plugins/dkj-policy/extensions/dkj-solutions/assets/dkj-brandbook-product/house-product.css`.

**The rule that an app starts from it reaches DKJ-Solutions and nothing else**, through the
`dkj-solutions` extension, where an app copies the files in and `check-house-style` holds the copy to the pin:
nothing applies them to a product automatically. BWJ-Development styles its own apps. The files themselves
reach every repo, because the plugin's own screens, Admin, render in them there with no opt-out
([#3643](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3643)); the three-part rule is in
[`apps/admin/README.md`](../../apps/admin/README.md#one-look-in-every-repo).

**Every change to a stylesheet in this folder passes a CSS gate of its own**
([#3493](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3493)): `house-style-css` in this repo's
CI runs `scripts/lint/house-style-css/`, which parses each stylesheet, fails a `var()` that nothing defines
(a parameter the markup sets is documented in a comment as `style="--name: ..."`, as the legend's `--c` is),
and fails a colour code anywhere but a token declaration in `house-style.css`. It reads every `.css` here,
so a stylesheet added later is gated without an edit.

**A house-style change is judged by eye on the House style page**, `specimens.html` in this folder: every
token, the twelve themes and every component with its variants and states, drawn from the stylesheet beside it.
It ships with the plugin, and every Admin that runs `dkj-policy` shows it under Plugins, on
`/dev/plugins/dkj-policy/dkj-brandbook` (#3493, #3629, #3704), as one card per section with a page each
(`/dev/plugins/dkj-policy/dkj-brandbook/<section>`, #3563); in the source repo that page reads the working tree, so a change
shows there before the release that ships it. It replaces the Brandbook app's showcase, which is retired. `house-style-css` is the gate
that checks the stylesheet's syntax and tokens; the page is the look.

## How to use it

1. **Copy `house-style.css` into the output, unchanged**, and `house-theme.js` with it where the app
   lets the user pick a theme (below). Where the output must make no external
   requests (a local report, an e-mail), inline it in a `<style>` block. Where the app has a build,
   vendor it as a file. Either way it is a copy of this file, never a retyped version. **A product page** (DKJ-Solutions' mobile-first
   app, not Admin) copies `house-product.css` as well and links it **after** this file, never alone
   ([the product README][product-readme]).
2. **Add the repo's own layer after it, in a separate block or file.** Domain colours and components
   (one app's series mapping, one app's special panel) go there. They **use** house tokens and may add
   tokens of their own, under a name the house file does not define.
3. **Never redefine a house token or a house class in the repo layer.** A value that is wrong for every
   app is fixed here, through an issue on this repo, so that every app gets the fix. A value that is wrong
   for one app is a new domain token in that app, not an override. Same rule as the constitution:
   extend, never override. One narrow exception: a component subtree may re-declare a house colour token
   (`--bg-2`, `--primary-muted`) so its contents follow a tint, as the info and accent dialogs do;
   the token is never changed for the page. Everything inside such a subtree inherits the re-declared value,
   so a tinted dialog nested inside an info dialog would tint from `--graph-1`; do not nest them.
4. **Design to one screen of about 1300 x 900, at the full width, with nothing the brief did not ask for**
   (the owner, October 26, 2026; about 1300 x 900, a guideline, since October 27, when it replaced 1400 x 600): no scroll where cutting ornament or going wider avoids it, blocks side
   by side rather than stacked, and no eyebrow, sub line, lead or extra row unless the brief asks for
   one. The full rule is in the `dkj-brandbook` skill, under "Density".
5. **A page opens on its `h1` and goes straight to its content: no intro paragraph under it** (Dave, for
   every DKJ-Solutions product, October 27, 2026,
   [#3585](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3585)): *"ik moet zuinig zijn met de
   hoogte van het scherm"* (I have to be economical with screen height). No lead paragraph, no `.lede` of the
   repo's own, and no plain `<p>` that explains the page. A sentence saying what the page is for goes in its
   `<meta name="description">`, not on screen. Real content is not an intro: an empty state that says a list
   is empty stays. Where a page does want to say more, as a plugin's page does with its description, it goes behind a
   `.page-info-button` right of the `h1` (`.page-title`), shown only on hover or focus (Maikel, October 31, 2026).
   **One exception, which a repo opts into: a content product may carry a short lead** (Dave, November 13, 2026,
   [#4051](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4051)). A content product is one whose pages
   brief a reader, as a news app does: a lot of information made digestible, and a dossier summed up before it
   is opened. There a short lead under the `h1` is part of making it digestible, so it is allowed: **one plain
   `<p>` directly under the `h1`, one or two sentences, no box, no class of its own, and only where the page sums
   up content for a reader.** A tool or admin page in that same product keeps the strict rule, and so does a page
   whose lead would only restate its name. **A repo declares it in its own facts** (the unscoped rule its tooling
   loads every session, such as `.claude/rules/this-repo.md`), with the line
   `Content product (brand-book rule 5): yes.` and why. Without that line the strict rule holds, and no lint
   reads the line: it is for the session writing the page.
6. **The `h1` is never framed** (the owner, October 28, 2026). It gets no border, outline, shadow or
   background of its own, and the page's `h1` stands on the page itself, never inside a card, a panel or
   any other bordered box. `house-style.css` clears all four on every `h1`. The rest is a layout rule: the
   page heading always sits outside the boxes.
7. **No `code` element inside an `h1`, `h2` or `h3`** (Maikel, November 2, 2026): a heading in the body
   sans with a fixed-width run of `--font-mono` in the middle of it looks out of place. A heading names
   the thing in words. A file name, a command or an identifier it would have quoted goes in plain text in
   the heading, or in a `code` element in the content under it.
8. **A heading has five words at most** (Maikel, November 2, 2026): an `h1`, `h2` or `h3` that runs longer
   reads as a sentence. It names the subject; who it is for and what changed go in the content under it.
   **A page's name has two words at most** (Dave, November 4, 2026,
   [#3797](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3797)): its `h1`, and the crumb that reads
   the same ([the breadcrumb bar][product-bar]). Every ancestor crumb repeats its page's
   name, so a trail of longer names stops fitting its one-line bar. A hyphenated word counts as one, and a
   subtitle after a dash counts in full, so it moves into the page. The five words stay the cap for `h2` and
   `h3`. Admin's page shell checks it on sight: the fit alarm warns when the live page's `h1` or its
   current crumb runs past two words.
9. **A page carries exactly one `h1`** (Maikel, November 2, 2026,
   [#3745](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3745)): two on one page *"mag sowieso
   nooit"* (must never happen at all). Content a page renders (a lens, a release note, any markdown) never
   adds one: its own `# ` title is dropped or demoted to `h2`. The one page without an `h1` is the home page
   under a site header ([the breadcrumb bar][product-bar]). A popup opened as a modal `dialog` is its own
   document to a screen reader, so it may open on its own `h1`, and that `h1` is not the page's second
   (the owner, November 9, 2026, [#3937](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3937)).
   Admin's page shell checks it on sight: the fit alarm also warns when the live page holds more than one
   `h1` outside an open modal, or none where its trail is longer than Home.
10. **The em dash (—, U+2014) is never used** (Maikel, November 3, 2026): not in a heading, a label, a
   button, a card, a page title, a `<meta name="description">` or any other text a DKJ-Solutions app
   renders. Where one would go, write a colon, a comma, parentheses or a new sentence instead.

## What it holds

**A theme's colours are three groups, read by the 60-30-10 rule** (owner, October 28, 2026,
[#3630](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3630)). It is a grouping of the tokens a theme
already has, not a new colour:

| Share | Group | Tokens | What it is |
|---|---|---|---|
| **60%** | Paper | `--bg-1` … `--bg-5` | the ground: the page, the cards, the lines, and the edge of a control (`bg-5`) |
| **30%** | Text | `--fg-1` | what sits on the paper: every paragraph, label, quiet icon, `h2` and `h3` (one text colour since #4046; `fg-2` … `fg-4` were steps too small to tell apart) |
| **10%** | Primary | `--primary`, with `--primary-muted` (its grey), `--primary-raised` and `--primary-hover` (its two shades) | the accent, the theme's colour: `h1`, links, `.btn--primary`, the states; `--primary-raised` is the settings cell in a site header, `--primary-hover` a primary button under the pointer |

**Primary is the 10, text the 30** (Dave, November 12, 2026; from October 28 it was the other way round). The 10 of
the rule is the accent, and the theme's colour is the most saturated colour a theme has, so it stays the scarcest:
it marks what the eye is meant to find (the page's `h1`, a link, the main action, a state) and nothing else. Text
carries the content on every page, so it is the larger share. That moved `h2` and `h3` from `--primary` to the
text steps: a heading below the `h1` in the accent spends the 10 on every section.

**Every colour token of a theme sits in one of the three groups, and a new one joins the group it belongs to**
(the owner, November 12, 2026). A token that fits none is not added: its role is taken by a token that does, or the
need is brought to the owner. It takes the group's name and is computed in the group's way, so a new primary colour is
`--primary-<role>`, in the primary's own hue. The control edge was proposed as a free-standing `--border-strong`
and moved into the primary group as `--primary-border` the same day for exactly this reason; it then moved again, to
the 60 as `--bg-5` (Dave, November 12, 2026), because a control's edge is a line, and the lines are paper, not the
accent. `bg-5` already bordered the Mode toggle and the theme cards, so one token now holds the one role.

**A rule reads a colour only as a token, never derives one** (Maikel, a strict rule, November 1, 2026): no
`color-mix()`, no relative colour (`rgb(from …)`), no `oklch()` or other colour function, **a token's own value
included** (Maikel, November 2, 2026, #3727): `--x: color-mix(…)` is a derived colour too. A shade a component
needs is a new token, typed into every theme line, and `check-colour-literals.mjs` refuses a derived colour
anywhere before it lands. `--primary-raised` and `--primary-hover` were added that way the same day:
`--primary` 15% of the way to `--bg-1` (less where that would drop it under 4.5:1 on `bg-1`, below), and to `--fg-1`, the exact values the two `color-mix()` rules had computed.

**Everything in the primary group reads on all four paper steps**, as the text does (Maikel, November 1, 2026): `--primary`
4.56:1 or better on `bg-4`, `--primary-muted` 5.30:1 or better (WCAG, the worst of the twelve themes); `--primary-raised` and `--primary-hover` are
fills rather than text, so this is not asked of them.

**Every `--primary*` and every `--fg-*` token reads on `bg-1` at 4.5:1 or better, in every theme, with no
exception** (Dave, November 12, 2026). The page is where any of them may end up as text, so the floor holds for the
fills too, and for a token added to either group later. `build-house-palette.ps1` checks it for every token whose name
starts with `--primary` or `--fg`, so a new one is held to it without an edit. **A token that falls under it has two
ways out, and only two**: its contrast is raised until it reads, or it is not a text or primary colour and moves to
the paper as a `--bg-*` token. It never stays in its group below the floor. It moved one token: `--primary-raised`
goes 15% of the way to `bg-1` where that stays at 4.55:1 or better, and less where it would not (teal, ochre and rust,
which were at 4.30:1 to 4.44:1). The worst case now: `--primary-raised` 4.55:1 (ochre), `--primary` 5.90:1 (teal),
`--primary-hover` 7.29:1, `--primary-muted` 7.05:1, `--fg-1` well above all of them (`--fg-4`, 14.1:1, was the lowest text step until #4046).

**And a theme has
these three groups and no fourth**: a colour that fits none of them is not a theme colour. That retired
`--muted-inverse` the same day. It was the grey of an inverted surface, 7:1 on `--fg-1`, and fitted no group: on the
paper it read at 2.1:1 to 2.3:1 on `bg-4`, so not the primary group; on `--primary` at 2.1:1 to 4.0:1, so not the 60; and
no colour at all reaches 4.5:1 on both `bg-4` and `--fg-1` (the best grey reaches 3.9:1 to 4.05:1), so no
change of value could have moved it into the primary group. The quieter line on `.fill-inverse` takes `--bg-4` (15:1 or
better on `--fg-1`), and the house-style gate reports `--muted-inverse` as a retired token.

A repo layer keeps to the same shares: what it adds lands in one of the three groups, and a page whose
primary outweighs its text has spent the accent as ground.

**Tokens**, each in light and dark:

| Group | Tokens | Meaning |
|---|---|---|
| Paper | `--bg-1` … `--bg-5` | what sits **behind** the text, in very small steps, each only just darker on light (lighter on dark) than the one before: the page (`bg-1`), cards and tiles (`bg-2`), every line and the tinted surfaces (`bg-3`: borders, row dividers, grid lines, the meter track, an accent table head, a hover, the accent dialog), a stronger border (`bg-4`: an open card, a selected box), and the edge of a control (`bg-5`, below; one small step past `bg-4` from November 3, 2026, Maikel, until November 12). **`bg-1` to `bg-4` read on `--primary`** (4.55:1 or better, #3235; the primary is measured against `bg-4`, so `bg-5` is not promised there), so they are also the text on a primary fill (`.fill-primary`), `bg-1` the text on a `--primary-muted` fill and the mark inside a status icon, and the paper steps the text on an inverted (`--fg-1`) surface |
| Control edge (60) | `--bg-5` | the boundary of a control: a plain `.btn`, `.seg`, `.info-button`, `.nav-search`, `.toolbar__filter`, and in the product layer `.stepper` and `.combo`. A grey of the primary's own hue, at `--primary-muted`'s chroma, as close to the paper as **3:1 on `bg-3`** allows (WCAG 1.4.11), computed per theme (November 12, 2026; `--primary-border` in the primary group until it became `bg-5` the same day, Dave). Not a small paper step like `bg-1` to `bg-4`, but a clear one. `bg-3` and `bg-4` stay the quiet lines between surfaces, which need not reach 3:1 |
| Categorical | `--graph-1`, `--graph-2`, `--graph-3` | one series each. Never two meanings for one slot in a view. Named `--cat-1` to `--cat-3` until November 1, 2026 (Maikel). **Computed per theme since November 12, 2026** (the owner): a series must not look like the theme's own colour, as the magenta series did in the magenta theme, nor like a status, as the old orange `--graph-2` looked like `--warning-3` (ΔE 4.2). **And a series ALWAYS reads well on `bg-1`, in every theme** (the owner, November 12, 2026): every slot reaches **APCA Lc 45** on `bg-1` and `bg-3`, on top of WCAG's 3:1. The ratio alone could not hold that in a dark theme. It scores a mid tone on a near-black page too kindly: the dark blue series read 4.4:1 there and only Lc 30, where the same slot reads Lc 71 in a light theme. `build-house-palette.ps1` walks a pool per mode (light: blue, purple-magenta, deep teal, wine, violet; dark: blue, pink-magenta, teal, then mauve, periwinkle, aqua, light pink and light sky for the themes whose pastel primary rules out the first ones). It lifts each candidate away from the paper, with hue and chroma held, by the least that brings it to Lc 45. It then takes the first trio, in pool order, whose members stand 18 or more off the theme's primary and 15 off every status fill (OKLab ΔE x100, the dataviz validator's measure), read at 3:1 on `bg-1` and `bg-3`, and stand 15 apart with full colour vision and 6 for a protan or deutan reader (the validator's floor, legal because a chart labels its series directly). No slot is red, orange, yellow or green: those hues are the status colours |
| Direction | `--positive-3` and `--negative-3` (also the gain and the loss in charts, so a direction chart can share a view with any series), `--positive-5`, `--negative-5` (numbers in text) | result and direction, never a category. `--positive-5`/`--negative-5` are the text versions of `--positive-3`/`--negative-3`, a step more contrast so a number reads as text: darker on light, lighter on dark |
| Status | `--positive-3`, `--warning-3`, `--negative-3`, `--warning-5`, `--warning-1`, `--negative-1`, `--positive-1` | badges, meters, notices. `--warning-1`, `--negative-1` and `--positive-1` are the backgrounds of a warning, negative or positive message. Done (work that is finished and closed) takes `--primary-muted`, a variant of the theme's own colour; it was `--done-3`, the purple GitHub gives a completed issue (Dave, November 9, 2026), the same in every theme, until November 12, 2026 (the owner), and the house-style gate reports `--done-3` as a retired token. The mark inside a status icon (check, cross, "!") is `--bg-1` |
| Primary | `--primary` | the theme's colour, **one** step (owner, #3235, October 21, 2026): the most saturated colour of the theme's hue that reads on all four paper steps, so the paper reads on it too. **The highlight**: `h1`, the fill of `.btn--primary` (a filled main action, like the filled icon button; #109) and of `.fill-primary`, a state (hover, pressed, sorted, active, today), `strong`, list markers, links, a value meant to stand out, the accent dialog's title and the settings panel's title, and native controls through `accent-color` |
| Grey | `--primary-muted` | a grey of the theme's colour, for what may recede: it reads extra well (7:1) on the page. `--primary-muted` is every sub line (`.dialog__sub`, a component's `-sub`), every note (`.note`, on a `<p>` too, the line under a heading included), the tile label, the pressed `.seg` button, `.badge--info`, `.meter--info`, done (finished and closed work, `--done-3` until November 12, 2026), focus rings, meters and the `--accent` modifiers ([below](#how-far-a-theme-reaches)); on an inverted surface (`.fill-inverse`) those roles take `--bg-4` (`--muted-inverse` until November 1, 2026). Never a status or a number |
| Text | `--fg-1` | what sits **on** the paper: one colour near black on light (near white on dark). It is **all text**: every paragraph, `h2`, `h3`, `.meta`, labels, table heads, legends, quiet icons, the text on a tinted surface, and the ground of an inverted surface. A quieter text is `--primary-muted`. Until #4046 (November 13, 2026) there were four steps, `fg-1` … `fg-4`, so small that `fg-4` was still very dark (owner, #3235); they were retired because nobody could tell them apart and the wireframes map all text to one token (#4040). On a fill the text switches to the paper ([Fills](#fills-the-text-switches-with-the-ground)) |
| Elevation | `--shadow-pop` | tooltips |
| Spacing | `--spacing-0-5` … `--spacing-96` | the spacing scale, same in both modes: `--spacing-N` is N × 4px, a half step (`-0-5`, `-1-5`, …) adds 2px. Every gap, margin and padding uses one, and a repo layer spaces its own components from the same scale |
| Type | `--text-h1` … `--text-h3`, `--text-base`, `--text-sm`, `--text-xs`, `--text-title` | the type scale, same in both modes. `--text-title` (20px, the `h2` size since November 2, 2026) is the site header's name alone, a step of its own so the header can be tuned without moving every `h2` (Dave, November 2, 2026; it was `--text-h3`). The rest: 36/20/16 for the headings since November 2, 2026 (Maikel; [below](#more-room-and-a-smaller-h2-november-2-2026)), 36/22/16 from November 1 ([below](#the-type-scale-of-november-1-2026)), 32/18/14 before (`h3` at 14px, the body size, and no `h4` or `h5` since October 25, 2026, the owner: [below](#the-heading-cut-of-october-25-2026)) (`h2` 18px since October 25, 2026, the owner; it went from 32 at weight 600 to 24 at 700 on October 24, and keeps the 700), and `.lead` was `--text-base` from the same day (it was `--text-lg`) until it was retired on November 1, 2026 (Maikel), 14/12/11 for running text (`--text-lg`, 18px, was retired on November 1, 2026). `h1`–`h3` each take the token of their own level, body text is `--text-base`. No heading is larger than 32px (owner's decision, October 22, 2026: as much content as possible on a 900px-high screen, since October 27 one of about 1300 x 900), so `h1` stands apart by its size and colour (by its capitals too until October 24, 2026); it was 48px from October 20, when `--text-h0` was retired. The hero figure is set at `--text-h1`. There is no `h6` either: the 24px `h3` was retired the same day, because it stood too close to `h2`, and every level below moved up one ([below](#the-heading-shift-of-october-20-2026)). The section label (`GroupHeading`), a heading at `--text-base`, uppercase and muted (owner's decision, October 15, 2026), was the one exception until November 1, 2026, when it went (Maikel): the house has one `h3`. `--font-serif` was the face of `h1` and `h2` until October 24, 2026, when the owner moved both to the sans; it stayed for a title that kept that face, none did, and it was retired on November 1, 2026 (Maikel) |
| Font family | `--font-mono` | a typeface, not a size: the fixed-width face the house sets `code` and `pre` in, and an app takes for figures or ids that must line up by character. The body face is not a token; it is set on `body` |
| Font weight | `--font-weight-light` 300, `--font-weight-regular` 500, `--font-weight-bold` 700, `--font-weight-black` 900 | the four weights, same in both modes (Maikel, November 1, 2026; bold and black were named semibold and bold until the same day): raised the same day from 400, 600 and 700/800. A rule sets a weight only through one of these four, never a number: what was 300 is light, 400 regular (body text too), 600 semibold, 700 and 800 bold. No house rule sets `--font-weight-black` since the same day: every rule that did now sets `--font-weight-bold` (Maikel), and the token stays for an app that wants it |
| Radius | `--radius-1` … `--radius-3`, `--radius-pill` | the corner radii, same in both modes and named like the spacing scale: `--radius-N` is N × 4px, one step per role: `--radius-1` 4px for a small element, `--radius-2` 8px for a control, `--radius-3` 12px for a container; `--radius-pill` rounds the ends fully. Named `xs` to `lg` with a `md-plus` until October 31, 2026 ([below](#the-radius-rename-of-october-31-2026)), and cut to three steps on November 13, 2026 ([below](#the-radius-scale-of-november-13-2026)) |
| App shell | `--control-h`, `--tap`, `--topbar-h`, `--column-narrow` | sizes for a mobile-first app, same in both modes: 38px for a value field and the button beside it, 44px as the smallest touch target, 56px for the top bar, 512px for the narrow app column |

`--gain` was removed (October 14, 2026). A gain in a chart is `--positive-3` (owner's decision, October 15, 2026, #131); before that it was `--cat-1`.

**The colour tokens were renamed the same day** (owner's decision): the status and direction colours so each
name says which side it is on, and the black, white and grey ones merged into one five-step ramp. An app that takes this update renames them in its own layer:

| Was | Now |
|---|---|
| `--good`, `--up` | `--positive-3`, `--positive-5` |
| `--bad`, `--down` | `--negative-3`, `--negative-5` |
| `--loss` | removed: a loss in a chart takes `--negative-3` (a legend item takes `--negative-3` through its `--c`) |
| `--warn`, `--warn-bg` | `--warning-3`, `--warning-1` |
| `--on-warn` | removed: text on a `--warning-3` fill takes `--neutral-3`, which turns light on the dark themes |
| (new) | `--warning-5`: a warning in text, a step darker on light and lighter on dark, like `--negative-5` |
| (new) | `--negative-1`, `--positive-1`: the backgrounds of a negative or positive message, beside `--warning-1` |
| `--page-base`, `--on-primary`, `--status-mark` | `--primary-1` |
| `--surface-base` | `--neutral-1` |
| `--grid-base`, `--border-base`, `--axis` | `--neutral-2`. `--primary-3` is now a solid line over it instead of a translucent one |
| `--ink-2`, `--ink` | `--neutral-3` |
| `--primary-muted` | removed: notes, quiet icons and chevrons take `--neutral-3`; the `.muted` class keeps its name |
| the five-step neutral ramp (October 14, 2026) | cut to three steps; **the name `--neutral-1` is live again with a new meaning**. Mapping, old → new, in the order to apply it so nothing is renamed twice: |
| old `--neutral-1` (the ground: text and icons on the primary, the mark in a status icon, the dialog backdrop) | `--primary-1` (the theme's own page colour, tinted) |
| old `--neutral-2` (surface base) | `--neutral-1`, with a **new value**: `#ebebe8` / `#262625` instead of `#f9f9f7` / `#1a1a19`, to set it clearly apart from the page |
| old `--neutral-3` (lines) | `--neutral-2`, same value |
| old `--neutral-4` (secondary text) | `--neutral-3`, same value |
| old `--neutral-5` (primary text, focus outlines, the inverted button, the 7% tints), **last** | `--neutral-3`. **Primary text changed value**: `#0b0b0b` / `#ffffff` became `#52514e` / `#c3c2b7`, so primary text has lower contrast and the 7% tints are weaker |
| `--page`, `--surface`, `--primary-soft` | `--primary-1`, `--primary-2`, `--primary-3` |
| `--border`, `--grid` | `--primary-3`, one line colour for both |
| `--primary`, `--primary-ink` | `--primary-4`, `--primary-4` |
| the six-step primary scale (October 14, 2026) | grown to **seven steps with the theme's colour in the middle** (owner's decision: `--primary-4` is the most saturated step, the anchor; `-3` and `-5` the greyest, `-5` the far-side mirror of `-3`). **`--primary-4` and `--primary-5` are live again with new meanings.** Mapping, old → new, in the order to apply it so nothing is renamed twice: |
| old `--primary-4` (lines), **first** | `--primary-3`, same value |
| old `--primary-3` (the tinted background) | `--primary-3`: the tinted surfaces now share the line colour, with `--primary-5` as their text |
| old `--primary-5` (the colour: fills, switches, focus rings) | `--primary-4` |
| old `--primary-6` (the colour as text: links, `h1`, `h2`), **last** | `--primary-4`. On dark the fills and the links change value: they were near-white and are now the theme's colour itself (Oranje `#f5873a`) |
| (new) | `--primary-5` (all text), `--primary-6` (no role yet), `--primary-7` (an inverted surface) |
| the three-step neutral ramp (October 14, 2026) | **removed** (owner's decision): the greys are the primary scale's own `-3` and `-5`, tinted towards the theme. Apply after the primary rows above |
| `--neutral-3` (all text, labels, focus outlines, the inverted button) | `--primary-5`. Same lightness (`#52514e` became e.g. `#524a5e` in Paars, `#c3c2b7` became e.g. `#c39b85` in Oranje), now in the theme's tint |
| `--neutral-2` (the grey line: borders, the info-button outline, the neutral badge, the blockquote bar) | `--primary-3`; a chart's zero line, axis and crosshair take `--primary-5`, so they stay apart from the `--primary-3` gridlines |
| `--neutral-1` (the next plane: the info dialog's base) | `--primary-2` |

**Check after migrating:** an undefined `var(--neutral-*)` or `var(--primary-6)` used in its old meaning fails silently or wrongly (text inherits its colour, an SVG fill or stroke goes black). Find leftovers with `grep -rn "neutral-" src`.

The class modifiers keep their names: `.badge--good`, `.badge--bad`, `.badge--warn`, `.meter--good`,
`.meter--bad`, `.meter--warn`, `.delta--up`, `.delta--down`.

**The primary scale grew from seven to nine steps on October 15, 2026** (owner's decision): two new greys sit
either side of the old `-4`, so the greys are now a trio, `-4`, `-5` and `-6`, with `-5` in the middle. Every role
keeps its colour and moves with its step; only the number changes. An app that takes this update renames in its own
layer, in this order so nothing is renamed twice:

| Was | Now |
|---|---|
| `--primary-7` (every paragraph, all text, an inverted surface), **first** | `--primary-9` |
| `--primary-6` (`h3`–`h6`) | `--primary-8` |
| `--primary-5` (the highlight: `h1`, `h2`, a state, `accent-color`) | `--primary-7` |
| `--primary-4` (the fills, focus rings, links, the picker's dot), **last** | `--primary-5` |
| (new) | `--primary-4`, a grey a step towards the ground (darker on dark, lighter on light), no role yet |
| (new) | `--primary-6`, a grey a step towards the far end (lighter on dark, darker on light): sub lines, notes and `.muted` |
| links (`a:any-link`, `.dkj-prose a`, `.dkj-msg a`) | `--primary-7`, the colour, instead of the grey `--primary-5` (owner's decision, the same day). |
| sub lines and notes (`.sub`, `.dialog__sub`, `.note`, `.footer-note`, `.muted`, `.dkj-muted`, `.dkj-card-sub`, `.dkj-dialog-sub`, `.dkj-row-sub`, `.dkj-daterow-sub`, `.dkj-calc-sub`) | `--primary-6` instead of `--primary-9`, on a `<p>` too (owner's decision, the same day) |

**The primary scale grew from nine to twelve steps on October 19, 2026** (owner's decision): three groups of four,
the light steps `-1` to `-4`, the greys `-5` to `-8` and the dark steps `-9` to `-12`. Every role moves to a new
number, the four anchors (`-1`, `-4`, `-9`, `-12`) take new values and the lines stay on `-3`. The headings change:
`h2` takes `-10` (it was the h1's colour) and `h3`–`h6` take `-11`. **The names stay valid, so nothing fails on a stale
number: it just shows another colour.** An app that takes this update renames in its own layer, highest first so
nothing is renamed twice:

| Was | Now |
|---|---|
| `--primary-9` (all text, an inverted surface), **first** | `--primary-12` |
| `--primary-8` (`h3`–`h6`) | `--primary-10`, now `h2` only; `h3`–`h6` take the new `--primary-11` |
| `--primary-7` (the highlight: `h1`, `h2`, links, states, `accent-color`) | `--primary-9`, now `h1` without `h2` |
| `--primary-6` (sub lines, notes, `.muted`) | `--primary-7` |
| `--primary-5` (the fills, focus rings, meters) | `--primary-6` |
| `--primary-4` (a grey, no role yet) | `--primary-5`, a stronger border |
| `--primary-3` (every line, the tinted surfaces), **last** | `--primary-3` (unchanged) |
| (new) | `--primary-4`, the light anchor; `--primary-8`, the far grey; `--primary-11`, `h3`–`h6` |

**Check after migrating:** list every use with `grep -rnE -- "--primary-[0-9]+" src` and read each hit against the
table; a missed rename shows the wrong colour rather than an error.

**The primary scale split into paper and ink on October 20, 2026** (owner's decision): the colours behind
the text are paper, in very small steps, and the colours on it are ink, in large steps. `--primary-*` no longer
exists. The paper roles keep their colours except the stronger border, which turns from a grey into a tint a
step beyond the line: `--bg-4` sits 36% of the way from the page to the light anchor, as `-2` and `-3` sit at 4%
and 16%. The ink steps take **new values**: seven steps evenly spaced in lightness from the highlight to the far end, so
`h2` and `h3`–`h5` shift slightly and the muted greys read darker on light and lighter on dark. `--primary-4`, the
light anchor, had no role and is no token any more. An app that takes this update renames
in its own layer; the names do not overlap, so the order does not matter:

| Was | Now |
|---|---|
| `--primary-1` (the page) | `--bg-1` |
| `--primary-2` (cards, tiles) | `--bg-2` |
| `--primary-3` (every line, the tinted surfaces) | `--bg-3` |
| `--primary-4` (the light anchor, no role) | removed |
| `--primary-5` (a stronger border) | `--bg-4`, with a **new value**: a tint instead of a grey |
| `--primary-6` (the eyebrow, the fills, focus rings, meters) | `--ink-3` |
| `--primary-7` (sub lines, notes, `.muted`) | `--ink-4` |
| `--primary-8` (the breadcrumb's current page) | `--ink-5` |
| `--primary-9` (the highlight: `h1`, links, states, `accent-color`) | `--ink-1` |
| `--primary-10` (`h2`) | `--ink-2` |
| `--primary-11` (`h3`–`h5`) | `--ink-6` |
| `--primary-12` (all text, an inverted surface) | `--ink-7` |

**`--ink-2` is live again with a new meaning**: it was retired on October 14, 2026 (the old secondary text). The
gate reports every `--primary-*` left behind as a retired token, so nothing is missed silently; on an inverted
surface `h1` follows `h2` to `--bg-3`, since the light anchor it took is gone.

**The ink split into one primary, two greys and four text steps on October 21, 2026** (owner, issue
[#3235](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3235)). Every theme still has eleven colours, now
computed by `scripts/build/build-house-palette.ps1` in the `dkj-solutions` plugin from the theme's hue and mode: one primary that
reads on all four paper steps (and they on it), two greys that read extra well on the page and on the far end, four
paper steps and four text steps in very small steps. **Every value changes**: the primary is a little darker on
light (it has to read on `--bg-4` now, not only on the page), the paper steps are a little lighter, and `h2` and
`h3`–`h5` are no longer in the colour but in the text steps. `--ink-*` no longer exists; `--primary` and `--primary-muted`
were retired on October 14, 2026 and are **live again**, in the same sense they had then (the theme's colour, a muted
grey). An app that takes this update renames in its own layer; the names do not overlap, so the order does not
matter:

| Was | Now |
|---|---|
| `--ink-1` (the highlight: `h1`, links, states, `accent-color`) | `--primary` |
| `--ink-2` (`h2`, `.meta`) | `--fg-2` |
| `--ink-3` (the eyebrow, the fills, focus rings, meters) | `--primary-muted` |
| `--ink-4` (sub lines, notes, `.muted`) | `--primary-muted` |
| `--ink-5` (the breadcrumb's current page) | `--fg-4` |
| `--ink-6` (`h3`–`h5`) | `--fg-3` |
| `--ink-7` (all text, an inverted surface) | `--fg-1` |
| (new) | `--muted-inverse`: the grey on an inverted surface, where `--primary-muted` would not read |
| (new) | `.fill-primary` and `.fill-inverse`: a block on the primary or on the far end, where the text switches to the paper |

**On an inverted surface**, a grey that was `--ink-3` or `--ink-4` takes `--muted-inverse`, not `--primary-muted` (and `--bg-4` since November 1, 2026, when `--muted-inverse` was retired). The gate
reports every `--ink-*` left behind as a retired token, so nothing is missed silently.

**An app still on the twelve `--primary-*` steps** (v5.26.0 and earlier) skips the ink names and maps straight
across: `--primary-1`, `-2`, `-3` → `--bg-1`, `-2`, `-3`; `--primary-4` → removed; `--primary-5` → `--bg-4`;
`--primary-6` and `-7` → `--primary-muted`; `--primary-8` → `--fg-4`; `--primary-9` → `--primary`; `--primary-10` →
`--fg-2`; `--primary-11` → `--fg-3`; `--primary-12` → `--fg-1`. Bare `--primary` is a token of its own, not one of the twelve steps: the
gate tells `--primary-9` from it.

**A number in a colour token is a step away from the page** (owner's decisions, October 14 and 20, 2026). For
`--negative-*`, `--positive-*` and `--warning-*` that is `-1`, `-3`, `-5`: `-1` is light on the light themes and dark
on the dark themes (the ground end) and `-5` the opposite (the text end). The theme's own colour has two numbered
groups (#3235), and each counts from its own start: `--bg-1` … `--bg-4` from the page outward (page, cards,
lines and tinted surfaces, a stronger border), in very small steps, and `--fg-1`, the one text colour (four steps
until #4046). `--primary` and `--primary-muted` carry no
number: there is one of each. There are no untinted neutrals: the
greys are the theme's own, a greyed step of its colour. For the status families:
`-1` is the background of a message, `-3` the fill (icon, badge, meter, a
loss in a chart), `-5` the text.

**The colour tokens grouped by what a theme switch changes** (the grouping the House style page's tokens
section uses):

| A switch … | Tokens | Why |
|---|---|---|
| to any other theme changes them | `--primary`, `--primary-muted`, `--bg-1` … `--bg-5`, `--fg-1` | each theme sets them as fixed values, computed from its own hue; the House style page lists them as the three groups of the 60-30-10 rule |
| to any other theme changes them: categories | `--graph-1`, `--graph-2`, `--graph-3` | series slots, computed per theme away from its primary and the status hues (November 12, 2026); set once per mode until then |
| changes them only between light and dark: status colours | `--negative-1`, `--negative-3`, `--negative-5`, `--positive-1`, `--positive-3`, `--positive-5`, `--warning-1`, `--warning-3`, `--warning-5` | set once in the light block and once in the dark block, a shade apart. One exception: `--warning-3` also moves in Roest and Geel ([below](#themes-the-user-picks-the-colour)) |

**The spacing and type scales have a source: the Figma library** *Shopify Theme - LIBRARY*, variable
collection "Collection", groups `spacing/` and `text/`. Their names and values are copied exactly, so a
design in Figma and a page built from this file share one set of numbers. A step added there is added
here, in a branch of its own. The spacing values happened to match the dashboard already. The type
scale did not, so taking it over changed sizes: body 15 → 14, `h2` 29 → 32, `h3` 18 → 24, the 13px
small text → 12, a mini-card value 20 → 18, the info button's mark 10 → 11 (Maikel, October 12, 2026).
Two departures from the library followed on October 20, 2026: its `h0` was retired with `h1` taking the 48px,
and its 24px `h3` was retired with every level below it moving up one.
**No heading is larger than 36px** (owner's decision, October 22, 2026, at 32px; 36px since November 1, 2026, Maikel): every pixel of a 900px-high screen goes to content,
so `h1` came down from 48px to `h2`'s 32px, and the hero figure with it. The target screen is now about 1300 x 900 (the owner, October 27, 2026, after 1400 x 600 from October 26; rule 4 under [How to use it](#how-to-use-it)), which makes the reason stronger.
**On a phone the headings step down a size** (Dave, November 13, 2026): below the 760px breakpoint the
grids already use, `--text-h1` is 28px, `--text-h2` and `--text-title` 18px; `--text-h3` stays 16px and the
body sizes do not move. The Figma library's `Scale` collection carries the same pair as its `Desktop` and
`Mobile` modes, with the `text/` and `font-weight/` variables the text styles bind to.
**The `h1` is in the body sans and its own case, at the bold weight** (`--font-weight-bold`; it was `--font-weight-black` for part of November 1, 2026, until every black rule moved to bold the same day, Maikel) (owner's decision, October 24, 2026). From
October 21, 2026 ([#3247](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3247)) it was set in
capitals, and before that day in `--font-serif`; both went, so it stands apart from the `h2` by its size and
weight (`h2` is bold, `--font-weight-bold`, since November 1, 2026, Maikel).

### The heading shift of October 20, 2026

**The 24px `h3` stood too close to the 32px `h2`, so it is gone and every level below it moved up one**
(owner's decision, October 20, 2026). There are five heading levels now and no `h6`:

| Was | Now |
|---|---|
| `h3`, `--text-h3`, 24px | retired |
| `h4`, `--text-h4`, 22px | `h3`, `--text-h3`, 22px |
| `h5`, `--text-h5`, 18px | `h4`, `--text-h4`, 18px |
| `h6`, `--text-h6`, 16px | `h5`, `--text-h5`, 16px |

**A size token kept its name and changed its value**, so an app that takes this update moves each use one level
up in its own layer, lowest first so nothing moves twice: `--text-h4` → `--text-h3`, then `--text-h5` →
`--text-h4`, then `--text-h6` → `--text-h5`, and the same for the heading elements (`h4` → `h3`, `h5` → `h4`,
`h6` → `h5`). An `h3` that was an `h3` (a card title) stays one and simply renders at 22px. `--text-h6` is a
retired token, so the gate reports a use left behind; a missed `--text-h4` or `--text-h5` shows a size one
step too small rather than an error.

### The heading cut of October 25, 2026

**`h3` is 14px, the body size, and `h4` and `h5` are gone with their tokens** (owner's decision, October 25,
2026). Three heading levels remain, and `h3` stands apart from running text by its weight and its colour
alone (semibold and `--fg-3` until November 1, 2026; light and `--primary` since, Maikel):

| Was | Now |
|---|---|
| `h3`, `--text-h3`, 22px | `h3`, `--text-h3`, 14px |
| `h4`, `--text-h4`, 18px | retired: an `h3` |
| `h5`, `--text-h5`, 16px | retired: an `h3` |

**An app that takes this update makes every `h4` and `h5` an `h3`**, and moves each use of a retired token in its
own layer: a heading-like use (a title) to `--text-h3`, running text that borrowed `--text-h5` to `--text-base`. A
large figure that borrowed `--text-h3` for its size (a tile value, a secondary hero value, a large stepper) moves to
`--text-lg`, because a figure at the body size no longer stands out. `--text-h4` and `--text-h5` are retired tokens,
so the gate reports a use left behind. The house rules for an `h4` and an `h5` are gone, so one left in markup
renders at the browser's default size.

### The radius rename of October 31, 2026

**The radius tokens are named like the spacing scale** (owner, October 31, 2026): `--radius-N` is N × 4px and a
half step adds 2px, so a name says its size and a new step has an obvious name. The T-shirt names had run out at
10px, which became `md-plus`. Every value is unchanged, so nothing looks different:

| Was | Now |
|---|---|
| `--radius-xs`, 4px | `--radius-1`, 4px |
| `--radius-sm`, 6px | `--radius-1-5`, 6px |
| `--radius-md`, 8px | `--radius-2`, 8px |
| `--radius-md-plus`, 10px | `--radius-2-5`, 10px |
| `--radius-lg`, 12px | `--radius-3`, 12px |
| `--radius-pill` | `--radius-pill`, unchanged |
| (new, November 1, 2026) | `--radius-4`, 16px: the dialog and the drawer, which had it hard-coded (Maikel). The card groups (`.grid-2`, `.grid-3`, `.card-grid`) had 16px too and take `--radius-3` since that day, because it looks better |

**An app that takes this update renames each use in its own layer** by the table. The old names are retired
tokens, so the gate reports a use left behind; one that slips past renders with square corners rather than an
error.

### The radius scale of November 13, 2026

**Three radius steps, one per role, plus the pill** (Dave, November 13, 2026). Six steps had three of them
within 4px of each other (4, 6 and 8px) and two more 2px apart (10 and 12px), which nobody can tell apart on
screen; `--radius-2-5` was bound nowhere in the Figma file at all. So each role keeps one radius: a small
element `--radius-1` (4px), a control `--radius-2` (8px), a container `--radius-3` (12px).

| Retired | Now | What changes on screen |
|---|---|---|
| `--radius-1-5`, 6px | `--radius-2`, 8px | the bar's theme toggle, the brand mark, the nav search, the toolbar filter, a combo option, a goal milestone |
| `--radius-2-5`, 10px | `--radius-3`, 12px | the mini card, the answer row, the calculator box |
| `--radius-4`, 16px | `--radius-3`, 12px | the dialog and the drawer |

**An app that takes this update renames each use in its own layer** by the table. The three old names are
retired tokens, so the gate reports a use left behind. The Figma library's `Scale` collection carries the same
four steps.

### The type scale of November 1, 2026

**The headings grow a step and `--text-lg` is retired** (Maikel, November 1, 2026). `h3` no longer shares the body
size, and the three headings stand further apart:

| Token | Was | Now |
|---|---|---|
| `--text-h1` | 32px | 36px |
| `--text-h2` | 18px | 22px |
| `--text-h3` | 14px | 16px |
| `--text-lg` | 18px | retired: `--text-h3` |

Every house rule that was set in `--text-lg` (a tile or panel value, the site name, the stepper, the combo input,
which must stay at 16px or more or iOS zooms in) takes `--text-h3`, 2px smaller than before. `.prose` keeps its
headings one step below the page: its `h1` is `--text-h2` now, where it was `--text-lg` (until `.prose` was retired the next day, [below](#prose-retired-november-2-2026)). **An app that takes this
update moves each use of `--text-lg` in its own layer to `--text-h3`.** It is a retired token, so the gate reports a
use left behind; one that slips past renders at the inherited size rather than raising an error.

### More room, and a smaller h2, November 2, 2026

**The page breathes a step more and `h2` comes down a step** (Maikel, November 2, 2026). No token is renamed or
retired, so an app that takes this update changes nothing of its own:

| What | Was | Now |
|---|---|---|
| `--text-h2` | 22px | 20px, the size `--text-title` already had |
| `.page-column`'s `gap` | `--spacing-3` (12px) | `--spacing-5` (20px) |
| `.menu-item`'s `gap`, between icon, label and chevron | `--spacing-4` (16px) | `--spacing-6` (24px) |
| A card title's `.menu-item__sub` under its `h2` or `h3` | no space | `--spacing-1` (4px) |

### `.prose` retired, November 2, 2026

**There is no `.prose` any more** (Maikel, November 2, 2026): a rendered markdown body is plain elements, and the
house styles those itself, with no wrapper class. Headings are the ordinary `h1`-`h3` at `--text-h1`-`--text-h3`.
`code`, `pre`, `ul`/`ol`, `blockquote` and `hr` have zero-specificity base rules under "Running text" in
[`house-style.css`](house-style.css), so any class of an app's own still wins, and like a `<p>` they carry no
margins: the place sets the space around a block. A table is a `.table` in a `.table-wrap`, which the house
markdown renderer writes. The last day of `.prose` also took out the three variables it set its headings through
(`--prose-h1`, `--prose-h2`, `--prose-h3`, one step down the scale), which read as tokens without being in the
table.

**An app that used `.prose`, `.prose--sm` or `.prose--fill` drops the class**: its headings and elements take the
house look by themselves, and the space between blocks becomes its own layout (Admin's lens page sets it in its
page layer). **One that read `--prose-h1` … `--prose-h3` moves to the `--text-*` token it means**; the three are
retired tokens, so the gate reports a use left behind. A rendered body never adds a second `h1` to its page.

### The colour renames of November 1, 2026

**The grey, the series slots and the backgrounds are named for what they are** (Maikel, November 1, 2026): the
grey is a muted tone of the theme's primary, the series slots colour graphs, and the four paper steps are the
backgrounds. Every value is unchanged, so nothing looks different:

| Was | Now |
|---|---|
| `--muted` | `--primary-muted` |
| `--cat-1`, `--cat-2`, `--cat-3` | `--graph-1`, `--graph-2`, `--graph-3` |
| `--paper-1`, `--paper-2`, `--paper-3`, `--paper-4` | `--bg-1`, `--bg-2`, `--bg-3`, `--bg-4` |

**An app that takes this update renames each use in its own layer** by the table. The old names are retired
tokens, so the gate reports a use left behind; one that slips past loses its colour rather than raising an error.

### One quiet-text class: `.note` (November 1, 2026)

**`.muted` and `.footer-note` are retired into `.note`** (Maikel, November 1, 2026). All three were `--primary-muted`
at `--text-sm`, so on the page they were the same text under three names; only a top margin told them apart, and in a
`.page-column`, where every footer note stands, the column already took that margin away. `.note` is now the one
class for quiet text: a note under something, a quiet word in a line, and the line that closes a page.

| Was | Now |
|---|---|
| `.muted` | `.note` |
| `.footer-note` | `.note` |

**An app that takes this update renames each use in its own markup** by the table. A use that slips past loses its
grey and reads as plain text rather than raising an error. A footer note outside a `.page-column` loses its
`--spacing-6` top margin with the class; the layout around it sets that space now.

**`--font-serif` is retired the same day** (Maikel, November 1, 2026). It stayed after October 24 for a title that
kept the serif face, and none did: no house class and no app on record read it. A use left behind falls back to the
inherited sans. `--font-mono` stays, because the house sets `code` and `pre` in it and apps read it.

## Themes: the user picks the colour

**Every DKJ-Solutions app has the same form, and a colour of its own that the user picks** (Maikel,
October 12, 2026). The brand book carries twelve themes. Each one is a mode, light or dark, plus a
primary colour, its `--primary` in either mode (the dot the picker draws):

| Mode | Themes (`data-theme`), in hue order |
|---|---|
| Light | `magenta` Magenta `#b90085`, `purple` Paars `#7f00ff`, `blue` Blauw `#0000ff`, `teal` Petrol `#006e79`, `ochre` Oker `#716300`, `rust` Roest `#9c4b00` |
| Dark | `pink` Roze `#ff9fd4`, `lilac` Lila `#d6adff`, `sky` Hemelsblauw `#b8b8ff`, `cyan` Cyaan `#63cfdc`, `yellow` Geel `#e2ba51`, `orange` Oranje `#ffaa74` |

- **No red and no green theme.** Those hues mean bad and good, and a primary colour beside a red "−1,1%"
  makes the number disappear. The status colours are the same in every theme.
- **Two themes move the warning.** In Roest the warning is a dark yellow (`#b88a00`), because the light
  themes' dark orange would sit on the primary. In Geel it is orange (`#f08a24`), because the dark themes'
  yellow would.
- **Every primary reaches 4.5:1** on all four of its paper steps, and so does each paper step on it (#3235).

**Which theme applies.** `house-theme.js`, beside the stylesheet, decides and sets
`<html data-theme="…">`:

1. the user's own choice, remembered per app on the device;
2. otherwise the app's own default theme, declared on the page: `<html data-theme-default="teal">`. Each
   app picks its own, so apps are told apart before anyone has chosen. The theme fixes the mode: a light
   default stays light for a viewer whose OS is dark, until they pick;
3. otherwise, for an app that has not moved to that yet, its default for the OS mode:
   `<html data-theme-light="purple" data-theme-dark="lilac">`;
4. otherwise the house defaults, Blauw (light) and Cyaan (dark).

**Each repo has one default theme of its own** (the owner's decision, October 17, 2026). Twelve themes,
eight repos: all eight differ, four light and four dark. The assignment was made in the Brandbook app
(`src/repos.ts`, until #3493 retired it) and is this table now. Each repo declares its theme on its own `<html>`, as above.

| Repo | Default theme |
|---|---|
| `dkj-brandbook` | `blue` Blauw (light) |
| `dkj-lifehub` | `teal` Petrol (light) |
| `dkj-recipes` | `rust` Roest (light) |
| `dkj-thumbnail-generator` | `purple` Paars (light) |
| `dkj-etf-tracker` | `sky` Hemelsblauw (dark) |
| `dkj-claude-plugins` | `lilac` Lila (dark) |
| `dkj-music-library` | `pink` Roze (dark) |
| `dkj-maplestory-classic-mesowise` | `yellow` Geel (dark) |

Load it in `<head>` so nothing flashes, and call `DKJTheme.picker(element)` where the setting goes: it
draws the twelve swatches in two rows, light and dark. `DKJTheme.set(id)`, `DKJTheme.reset()` and
`DKJTheme.current()` cover everything else. Copy it unchanged, like the stylesheet.

**Or give the app the settings button, and the setting is done** ([#70](https://github.com/DKJ-Solutions/dkj-brandbook/issues/70)).
`DKJTheme.settings(element)` draws a toggle that is the icon alone, in `--fg-1`, with no fill, edge or shadow,
and it stays `--fg-1` under the pointer and while open (Maikel, November 1, 2026; from #3235 until then it stood
on the card colour with a `--primary` edge). The toggle opens a panel with the picker, the page width
(below) and a reset, and returns the panel's slot (`.theme-settings__extra`), where the app puts settings of
its own. The script owns the behaviour, so an app writes none of it: the toggle opens
and closes the panel, Escape closes it and puts focus back on the toggle, and a click outside it or focus
leaving it closes it. A click inside never does. The element is inline by default, for a place such as a
`.topbar`. Give it `theme-settings--floating` and it is fixed at the top right of the screen instead.
The panel lies over the page, so nothing moves when it opens. Every text is optional and Dutch by default:
`DKJTheme.settings(el, { label: 'Settings', title: 'Settings', theme: 'Theme', reset: 'Reset theme', light: 'Light', dark: 'Dark', width: 'Width', fluid: 'Fluid', phone: 'Phone', full: 'Full' })`.

**The page width is part of the settings panel** ([#203](https://github.com/DKJ-Solutions/dkj-brandbook/issues/203)).
The panel has a width group with three choices, and the script sets the one that applies as
`<html data-width="fluid|phone|full">` in `<head>`, before the page paints, like the theme. The
stylesheet sizes `main` and `.container` from it, so the breadcrumb bar's trail keeps lining up with the
column, and `.container--narrow` / `main.narrow` follow too:

- `fluid`: the house column (1080px, or the narrow column where a page uses it);
- `phone`: a 360px column, the smallest phone an app supports;
- `full`: no maximum, the whole width.

Which width applies: the user's own choice, remembered per app on the device (`dkj-width`, with the same
`data-theme-key` suffix as the theme); otherwise the app's own default, `<html data-width-default="fluid">`;
otherwise `full` ([#3269](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3269): a DKJ-Solutions app
opens at the whole width unless it opts out). `DKJTheme.setWidth('phone')` and `DKJTheme.width()` set and read it from code. An app
whose layout has no page column to widen leaves the group out with `widths: false`. The attribute sits
inside `:where()`, so a column class of the app's own still decides its own width. Every `main` and
`.container` without such a class follows the width, a footer's or a demo's too. The top bar's inner row
(`.topbar__inner`) deliberately does not: it stays the narrow column, the width of the app's own controls.
Without the script there is no `data-width`, and the column is fluid, deliberately: the stylesheet alone
also serves e-mail and static reports, which have no settings panel to narrow an unbounded
column back to a reading width.

**The theme names and the picker's row labels are Dutch on purpose**: DKJ-Solutions apps are
Dutch-language, and the names are the ones their users read. An app in another language passes its own
row labels, `DKJTheme.picker(el, { light: 'Light', dark: 'Dark' })`. A page that ships
`data-theme="light"` or `"dark"` keeps that mode under the script: the script picks that mode's default
instead of following the OS, and ignores a `data-theme-default` of the other mode.

**Without the script the stylesheet still works.** No `data-theme` follows the OS with the house defaults,
and `data-theme="light"` / `"dark"` force a mode the way they always did. The dark block therefore appears
twice in the file, once under `prefers-color-scheme` and once for a forced dark theme. CSS cannot share
it, so **an edit to one dark block is made to both**.

**The source is the preview, mirrored in Figma.** The themes were chosen on a preview page and written
to the Figma library *DKJ-Solutions Theme's - LIBRARY*, group `colors/themes/`, one variable per theme
and role (`--oker-light-primary`, `--light-up`). A value changed there is changed here, in a branch of
its own.

**What this changed for an app that takes the update:** the pressed `.seg` button, `.badge--info` and
`.meter--info` take the primary instead of the then `--ink` and `--cat-1`; the light warning is dark orange instead
of amber and the dark one a brighter yellow; `--negative-5` on light is a darker red (`#a32424`); on dark
`--positive-5`/`--negative-5` are a step lighter and `--negative-3` is the dark red it never had; status icons take
the mark colour, now `--bg-1`.

### How far a theme reaches

**A page built only from house classes shows the theme beyond its primary button**
([#72](https://github.com/DKJ-Solutions/dkj-brandbook/issues/72)). Until then a theme set one token,
and only the primary controls and the focus rings used it. Plain links kept the browser's blue in
every theme. Now:

- **By default**, with nothing for the app to do: every link takes the theme's colour as text (`--primary`, owner's decision, October 15, 2026), visited or not, with
  a thicker underline on hover and a `--primary-muted` focus ring. Native checkboxes, radios, sliders and
  progress bars take `--primary` through `accent-color`, the text caret through `caret-color`, and selected
  text gets a primary tint. The link rules sit in `:where()`, so they weigh nothing: any class on an
  `<a>` (a `.btn`, a `.menu-item`, an app's own) wins without an override. An `<a>` without an `href`
  is not a link and is left alone. `accent-color` and `caret-color` are set once on the root, so a
  subtree that sets its own `--primary-muted` or `--primary` keeps the page's theme on its native controls.
- **Opt-in**, one modifier on a house element: `.header--accent` puts a primary rule under the page
  header and `.table--accent` a
  `--bg-3` table head, its text `--fg-1`, as all text. They are modifiers rather than defaults, so an app
  that takes the update keeps its layout until it adds one.
  `.card--accent` and `.tile--accent` drew a primary rule across the top and draw nothing now (owner's
  decision, October 15, 2026); an app that still carries either class loses the rule and nothing else.

**What this changes for an app that takes the update:** its unstyled links, checkboxes, radios and
sliders turn the theme's colour. Links an app already styles through a class keep their look.

**The theme now colours the ground too** (owner's request: the themes were visible but did not stand
out). Three more things follow it by default, in light and in dark (and a measurement):

- **Every theme writes out its own values**, computed rather than tuned (owner, #3235, October 21, 2026).
  `--primary`, `--primary-muted`, `--bg-1` … `--bg-5` and `--fg-1` are fixed hex values
  in each theme's block, not mixes (owner's decision, October 14, 2026: the percentages were too hard to follow), and
  `scripts/build/build-house-palette.ps1` in the `dkj-solutions` plugin computes them from the theme's hue and mode, checks every
  contrast below and writes them in with `-Apply`. A theme is changed there, never by hand in the stylesheet.
- **The model, in the owner's words, for a light theme** (a dark one is the mirror, with white and black swapped):
  - **One primary**: the colour of the theme that reads best on white, and white reads well on it too. Computed as
    the most saturated colour (HSL saturation 100%) of the theme's HSL hue that reaches 4.55:1 on **all four** paper
    steps, so every paper step reads on it as well. **On a dark theme the floor is 9:1**, so the primary is a light
    tint of the colour, and the dark paper on a primary fill reads at 9:1 or better (owner, October 21, 2026: at
    4.55:1 the dark primaries were the colour at full strength, and a primary fill was a vivid band under near-black
    text; a deep fill with light text was tried and dropped the same day). **And no dark primary is more saturated than
    OKLCH chroma 0.13**, Roze's: Cyaan and Geel reach 9:1 at full strength already, so the floor alone left them neon,
    and above the cap they are taken again at that chroma, at the lightness where they reach 9:1. Cyaan read too
    vivid even at 0.13 and has a cap of its own, 0.10, Hemelsblauw's (owner, the same day). The hue is the HSL hue of the owner's original theme colour
    (Blauw and Hemelsblauw 240), held in HSL because at a constant OKLCH hue a saturated blue turns violet; Lila takes
    270, the hue of its light counterpart Paars, because at its own 254 it read as blue (owner, October 19, 2026).
  - **One grey**: a grey of the colour that reads extra well on white (`--primary-muted`), in the primary's own OKLCH hue at
    chroma 0.03 on light and 0.06 on dark, as close to its ground as 7.05:1 allows, so it recedes by colour while it still
    reads. Since November 1, 2026 (Maikel) it follows the primary rather than the theme's base hue: a dark primary is
    lightened in HSL, which drifts its hue (Lila from 292 to 307), and at chroma 0.03 the grey read blue beside a violet primary. Its mirror for black,
    `--muted-inverse`, was retired on November 1, 2026 ([above](#what-it-holds)).
  - **Four colours that read on the primary**: the paper, from white towards a little darker, OKLCH L 0.995, 0.965,
    0.94 and 0.905 on light (0.13, 0.165, 0.195 and 0.235 on dark), with the chroma rising from 0.006 to 0.045. The
    eye is most sensitive to the first tint off white or black, so the card is only a little lifted off the page;
    since November 1, 2026 that step is wider than the rest (Maikel: bg-2 was barely visible in some themes).
  - **One colour that reads on the paper**: the text, near black, OKLCH L 0.12 at chroma 0.03 on light (0.99 at
    0.006 on dark). Three more steps at L 0.16, 0.20 and 0.24 were retired with #4046: too close to tell apart.

  **A role takes the same step in both modes** (owner's decision, October 15, 2026): never `light-dark()` between
  two steps, and no dark-only rule that picks another step. Meters, the fills and most focus rings are `--primary-muted`
  everywhere (a sort header, a `.seg` button, a chart bar and the read-more toggle ring in `--primary`), and the text on a `--primary-muted` or `--primary` fill is `bg-1`. The picker's dot is `--primary` in every
  theme, on its theme's `bg-1` (October 17, 2026). Paper and text both run away from the page: `bg-1` and
  `fg-1` are the two ends, the lightest and the darkest on light, the other way round on dark.
- **A tinted surface takes `--fg-1` as its text.** `--bg-3` is every line and also the surface of the
  `.table--accent` head, the hover of a joined choice, a near or today date row, a date
  row's hover, the accent dialog and an InfoRows box. The text on it is `--fg-1`, like all text (17.2:1 or better).
- **Measured** (WCAG relative luminance, worst and best of the twelve themes, October 21, 2026): `--primary` on
  `bg-1` 5.9:1 to 8.5:1 on light and 10.7:1 to 13.6:1 on dark, on `bg-4` 4.56:1 to 6.5:1 on light and 9.0:1 to
  11.2:1 on dark, the same both ways round. On dark the primary sits close to the text (1.4:1 to 1.8:1 against
  `fg-1`), so `h1` and links stand out from the text by colour rather than by lightness; `fg-1` on
  `bg-1` 19.5:1 to 20.1:1; `--primary-muted` on `bg-1` 7.05:1 to 7.13:1 and on
  a card 6.45:1 to 6.8:1 (measured again November 1, 2026); `bg-4` on `fg-1` 15.1:1 to 16.4:1. Nothing in the model is below 4.5:1, which
  the paper-and-ink model of October 20 missed for `ink-1` on a card in Magenta, Roest and Lila. A `bg-3` line
  on a card is faint: 1.05:1 (Pink) to 1.09:1 (Magenta); a `bg-4` border on it 1.14:1 to 1.22:1. The card on the
  page, `bg-2` on `bg-1`: 1.04:1 to 1.05:1 on dark and 1.09:1 to 1.10:1 on light.
- **The page and the cards are tinted.** On light the page is the whitest layer and a card sits a shade off it;
  on dark the card is a shade lighter than the page. Either way the page is the ground end (owner's decision,
  October 14, 2026: it used to be the other way round on light).
- **Lines are tinted.** `--bg-3` is every line: borders, row dividers, grid lines and the meter track
  (a separate grid colour was dropped on October 14, 2026: it was too close to the border to tell apart).
- **The theme picker previews it:** each swatch shows its own theme's page, with the primary as the dot.
- **Links are the theme's colour**, as `--primary` (owner's decision, October 15, 2026). **`h1` is
  `--primary`; `h2`, `h3` and `.meta` are `--fg-1`, the text** (#4046, November 13, 2026: they were `--fg-2` and
  `--fg-3`, steps too small to tell from `--fg-1`; Dave, November 12, 2026, took `h2` and `h3` off `--primary` when
  primary became the 10 of the 60-30-10 rule; before that they were `--primary` from October 24 and November 1, 2026,
  and before #3235 `h2` and `h3`–`h5` were steps of the colour).
- **On a fill the text switches** (#3235, the owner: *"h2 heeft niet altijd dezelfde kleur"*, an h2 does not always have the same colour). See
  [Fills](#fills-the-text-switches-with-the-ground).
- **Status, direction and categorical colours** (`--positive-3`, `--negative-3`, `--warning-3`, `--graph-*`,
  `--positive-5`, `--negative-5`) are never tinted. The graph slots differ per theme, but only to stay clear of its primary: each is
  picked from a fixed pool, never mixed with the theme's colour.

### Fills: the text switches with the ground

**A block can stand on the theme's colour or on the far end, and its text then takes the paper** (#3235). An `h2`
reads on the page and on the primary alike, so it is not one colour: `--fg-1` on the page, `--bg-1` on a
primary fill.

| Class | Ground | Text | A quieter line (`.note`, `.card__sub`) |
|---|---|---|---|
| `.fill-primary` | `--primary` | `--bg-1`: headings, paragraphs, `.meta` and links | `--bg-3` (all four paper steps read on the primary) |
| `.fill-inverse` | `--fg-1` | `--bg-1`, the same elements | `--bg-4` (15:1 or better on `--fg-1`) |

The switch is written with `:is()` and stands last in the stylesheet, so it beats `.note`, `p.meta` and the
zero-weight headings without an `!important`, and a quieter line on a `<p>` keeps its quieter colour. A link weighs
only one class, so a `.btn` or an app's own class on an `<a>` keeps its colours; its focus ring turns `--bg-1`. A
component an app puts inside a fill (a button, a badge) keeps its own colours, so a `.btn--primary` on
`.fill-primary` does not show: use an outline button there.

**What this changes for an app that takes the update:** every page turns a light shade of its theme, and
the headings take its tint (through `:where()`, so a heading inside a coloured container, or one the app colours itself, keeps that colour). An app that hard-codes a grey next to a house surface will show the seam.

## Components

**The complete list of reserved names**, so a repo layer knows what not to redefine:
the page header (`body > header`, `main > header`, with `.header--accent`) and its `.controls` row, `main`/`.container`,
`.hero`, `.tiles`/`.tile` (with `--accent`), `.card` (with `--accent`, and the head parts `__head` (with a plain `h3` as the title, a `.badge` before its text where it has one) and `__sub`), `.grid-2` (and `.grid-3`, the same three to a row, two below 1000px, one below 760px; both keep `--spacing-5` (20px) of padding round their cards on a `--bg-2` surface, each direct `.card` in them one step further on `--bg-3` with its lines moved to `--bg-4`, as does `.card-grid`, which a repo puts on its own card grid beside the class that sets its columns) (with `.grid__head`, which holds a group's `h2`, and `.grid__full`), `.table-wrap`/`.table` (with `--accent`, `.row-total`, and
sortable headers via `.sort`/`.arrow` on `aria-sort`), `.seg` (a segmented switch), `.legend`/`.legend__item` (with
`--line`), `.swatch`, `.badge` (with `--good`, `--warn`, `--bad`, `--info`, `--neutral`, `--sm`),
`.badge-row`, `.badge-list` (a `<ul>` of `.badge-row` items), `.meter` (with `--good`, `--warn`, `--bad`, `--info`), `.mini-cards`/`.mini-card` (with
`--highlight`), `.item-grid`/`.item`, `.notice`, `.note` (also the line under a heading: it absorbed `.sub`, and `.eyebrow` is gone, Maikel, November 1, 2026), `.meta` (`.lead` is gone too: it read as a plain `<p>`, Maikel, November 1, 2026), `.msg--positive`, `.msg--warn` and `.msg--error` on a plain `<p>` (`.msg` itself is gone, as every `<p>` has no margin, Maikel, November 1, 2026), `.facts` (with `--row`: the facts as one row on the page, label over value, no card), `.fill-primary`, `.fill-inverse`, `.page-column`, `.page-title` (the `h1` with a `.page-info-button` right of it, a drawn "?" on a 24px ring with a 1px solid border, in a 44px button, whose `.tooltip--explain` says what the page is about on hover or focus), `.page-cta`, `.num` (it absorbed `.amount`: an `svg` in it is a small icon beside the figure, Maikel, November 1, 2026) (tabular
numerals), `.delta` (with `--up`/`--down`; its aliases `.pos`/`.neg` are gone, Maikel, November 1, 2026), `.btn` (with `--primary`, and a `:hover`, `:focus-visible` and `:disabled` state for both), `.info-button`, `.tooltip`
(with `--explain`, and `--open` for one anchored to a trigger), `.more` (a disclosure), `.moretoggle` (a full-width read-more button), `.chart` (the SVG chart scope),
`.theme-picker` (with `__row`, `__label`, `__swatches`), `.theme-swatch` (with `--light`, `--dark`) and
`.theme-settings` (with `--floating`, `__toggle`, `__open`, `__close`, `__panel`, `__title`, `__group`,
`__label`, `__picker`, `__width`, `__foot`, `__extra`, `__reset`), which `house-theme.js` draws. The shared components
([below](#shared-components)) reserve these too: `.icon-btn` (with `--ghost`), `.action-row`, `.menu-list`,
`.menu-row` (with `__label`, `__value`), `.menu-item` (with `__icon`, `__label`, `__chevron`),
`.card--link`, `.breadcrumbs` (with `__sep`) and `.sr-only`. The product layer reserves its own names, listed in
[its README][product-readme] under "Reserved names": the app components (`.container--narrow`/`main.narrow`,
`.field`, `.btn--touch`, `.btn--block`, `.dialog`, `.topbar`, `.breadcrumbs-bar`, `.site-header`) and the
brand-book components that are not shared. The desktop shell ([below](#two-layers)) reserves these too: `.shell` (with `--fit`, `--no-aside`,
`__bar`, `__actions`, `__nav`, `__brand`, `__brand__mark`, `__nav-foot`, `__main`, `__list`, `__aside`, `__aside-body`, `__body`), `.page-head` (with `__title`, `__meta`, `__lead`, `__end`), `.empty-state` (with `__mark`, `__text`), `.admin-cols`, `.nav-section`, `.nav-list`, `.nav-item`
(with `__label`, `__count`), `.toolbar` (with `__title`, `__filter`, `__end`), `.pane-head`, `.table--dense` and `.dot`
(with `--good`, `--warn`, `--bad`). The shared brand-book components ([below](#shared-components)) reserve these too: `.alert` (`__title`, `__icon`), `.banner` (`--accent`, `__lead`), `.panel` (`--accent`, `--positive`, `--button`, `__label`, `__value`), `.chip` (`--yes`, `--no`, `--todo`), `.tag` (`--info`, `--warn`), `.filter-chips`/`.filter-chip` (`__check`, `__dot`, and `.filter-chips__clear`), and the additions to existing classes: `.card--open`, `.card--invalid`, `.msg--error`, `.table .row-negative`/`.row-positive`/`.row-warn`, `.table .col-start`/`.col-end`, `.facts__detail`, `.facts__total` and `.chart .bar--active`. Each is commented in the file.

**Focus and targets.** Every interactive house class shows a visible focus ring on keyboard focus (an SVG
`.chart .bar` shows a stroke instead), and its hit area is at least 44px (`--tap`) high where the mark is
smaller: the `.info-button`'s 16px mark, the `.table` header's `.sort` and the `.moretoggle`
([#19](https://github.com/DKJ-Solutions/dkj-brandbook/issues/19)). **The 44px is the product layer's and the
shared core's, not the desktop shell's** (Dave, November 5, 2026,
[#3811](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3811)): Admin is worked with a mouse,
so its dense rows are 28px (`--shell-row-h`) and its navigation items and bar buttons about 32 to 36px, all above the 24px a pointer
target needs (WCAG 2.5.8). A `.sort` header inside a `.table--dense` takes the row's height as its hit area,
so it does not reach over the rows under it. A tooltip opened from a trigger takes
`.tooltip--open`, which shows it and lets the pointer move onto its text; a chart tooltip that follows the
pointer is shown by its own script and stays click-through.

## Shared components

**Some of the old product layer is Admin's too, so it stays in the core** (Maikel,
[#3831](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3831), November 5, 2026). The group sits at the
end of [`house-style.css`](house-style.css), under "Shared components", and both layers take it:

- **The page width** (`data-width`: `full`, `fluid`, `phone`), which the settings panel's Width control sets.
- **`.icon-btn`** (with `--ghost`) and **`.action-row`**.
- **The base `.breadcrumbs` trail** (with `__sep`), which the Admin shell's bar uses; the `.breadcrumbs-bar` that
  carries it above a product page is the product layer's ([the product README][product-readme]).
- **`.menu-list`, `.menu-item`, `.menu-row` and `.card--link`**: the one card link ([Admin](#admin)).
- **`.sr-only`.**
- **The additions to existing classes**: `.card--open`, `.card--invalid`, `.msg--error`, `.table-wrap:focus-visible`,
  `.table .row-negative`, `.row-positive`, `.row-warn`, `.col-start`, `.col-end`, `.facts__detail`,
  `.facts__total` and `.chart .bar--active`. No existing rule changed.
- **Alert, banner and panel**: `.alert` (`__title`, `__icon`), `.banner` (`--accent`, `__lead`), `.panel`
  (`--accent`, `--positive`, `--button`, `__label`, `__value`).
- **Chip, tag and filter chips**: `.chip` (`--yes`, `--no`, `--todo`), `.tag` (`--info`, `--warn`),
  `.filter-chips`/`.filter-chip` (`__check`, `__dot`, and `.filter-chips__clear`).

Each is commented in the file. **The rest of what the Brandbook app and MesoWise gave the house** (the narrow
column, the form field, touch buttons, the dialog and drawer, the top bar, the toggles, the form parts, the value
box, the bill and calculation tables, the date list, the figure) is the product layer's, in
[`house-product.css`](../../extensions/dkj-solutions/assets/dkj-brandbook-product/house-product.css), documented in
[its README][product-readme] under "App components" and "Brandbook-app components". The corner radii, `--control-lg`,
`--datecol` and `--font-mono` those components brought are tokens and stay in the core ([Tokens](#what-it-holds)).

## The product layer

**The mobile-first product has a stylesheet of its own** (Maikel, [#3831](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3831),
November 5, 2026): [`house-product.css`](../../extensions/dkj-solutions/assets/dkj-brandbook-product/house-product.css) in the
`dkj-solutions` plugin, loaded **after** `house-style.css` and never alone. It holds the app components (the
narrow column, the form field, touch buttons, the dialog and drawer, the top bar, the `.breadcrumbs-bar`, the
site header and its menu) and the brand-book components that are not shared. **Its documentation moved with it**:
[`README.md`][product-readme] beside it holds the app and brand-book components, the "Page patterns" for product
pages (the shape of a page's cards, the card overview of a long page, the breadcrumb bar, the site header and its
menu), and how a product page links both sheets. **A session doing Admin work does not need it**: this README is
the whole of what Admin renders from. A product page vendors `house-style.css`, `house-theme.js` and
`house-product.css`, the product file after the core; an Admin-only repo needs the first two.

## Two layers

**The brand book has a shared core and two layers on top of it** (Dave, November 4, 2026,
[#3811](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3811)): Admin is always a desktop tool,
read in VS Code's Simple Browser, and looks like an Explorer or a task board, while the product (the
storefront) stays mobile-first with desktop as an option. The core (tokens, themes, typography, tables) is
shared; the desktop shell is a part of [`house-style.css`](house-style.css), and the product layer is
[`house-product.css`](../../extensions/dkj-solutions/assets/dkj-brandbook-product/house-product.css) in the `dkj-solutions`
plugin ([`README.md`][product-readme] beside it, #3831):

- **Desktop shell** (in [`house-style.css`](house-style.css), the part "Desktop shell: Admin's layer"). **Its structure is the Figma wireframes'** (Dave, November 12, 2026): the *Wireframes* page of the `dkj-brandbook` Figma file (key `w44J5aQPeST96RJ71vU3ev`, node `5-3`) is the highest source for how Admin is laid out, above this README and the stylesheet. The brand book puts its tokens on top of that structure, and where the two disagree the wireframe wins and this layer changes. So: a side navigation the full height of the window (a brand row, the search field, a flat list under section headings with Home and the domain objects on top, then Product and Development, Settings in the foot, after the Shopify Admin, #3815), a bar over the main pane with the trail and a few small actions, a page header (`.page-head`: the one `h1`, an optional lead, an action at its right end) and the content under it with room around it, an optional detail pane, and no site header. A pane's content stands in a `.shell__body`, and a
  set of links is an `.admin-list`: an `h2` over a `.table--dense`, a row per link (#3830). Desktop only, with no phone query. Reference:
  [`patterns/admin-shell.html`](patterns/admin-shell.html) and the "Desktop shell" specimens.

  **The wireframe greys become house tokens by role, and they are never aliased** (#4040, November 13,
  2026). The wireframes' `Wireframe` colour collection stays grey (`#ffffff` to `#262626`), because a
  wireframe is judged on structure and a themed one implies a theme choice. Each of its 13 variables
  names its house token in its Figma **description**, and this table is the same mapping, so the
  translation from wireframe to visual design is read, not guessed:

  | Wireframe | House token | Role |
  |---|---|---|
  | `color/bg` | `--bg-1` | the page |
  | `color/surface` | `--bg-2` | a card or group |
  | `color/surface-subtle` | `--bg-3` | an area inside a card |
  | `color/surface-active` | `--bg-4` | active or hover |
  | `color/border`, `color/divider` | `--bg-3` | a card edge, a rule between rows |
  | `color/placeholder` | `--bg-5` | a control edge |
  | `color/fill-strong` | `--primary` | the main action (the 10 of 60-30-10) |
  | `color/fill-accent` | `--primary-muted` | a quiet fill: a progress fill, as `.meter--info` |
  | `color/text-secondary`, `color/text-muted` | `--primary-muted` | quiet text, as `.note` |
  | `color/text` | `--fg-1` | body text |
  | `color/on-strong` | `--bg-1` | text on the main action |

  **Two wireframe text greys become one token on purpose.** The wireframe draws secondary text
  (`#666666`, the breadcrumbs, a table row's description) a step darker than muted text (`#8c8c8c`, a
  section label, a search placeholder). The brand book has one tone for what may recede,
  `--primary-muted`, and its `--fg-*` steps are kept nearly equal (#3235), so both map to it. The
  wireframe keeps its two greys: they are a nuance of the sketch that the visual design does not carry.
  A page that needs the difference asks for a second quiet tone as a brand book change.
- **Mobile-first app** (`house-product.css`, the part "App components"): the narrow column, touch targets,
  dialogs, the top bar, and the site header and breadcrumb bar under "Page patterns", both in the
  [product README][product-readme].

**The layer follows the task, not the device** (Dave, November 5, 2026, on #3811). Ask of each feature whether
it is for *managing* (composing, ordering, correcting, bulk edits: the maker's or the operator's work) or for
*using* (browsing, searching, playing, viewing: the end user's). Managing is dense, with many columns,
drag-and-drop and multi-select, so it belongs in Admin and is therefore built for the desktop. Using shows
little per screen behind large touch targets, so it belongs in the product, mobile-first. The same data in both
layers is not duplication: these are two views of one source, each built for its own task. A management
action that is really done on the go reaches the product only minimally, such as a drag handle or "up/down"
within one list, and never as the full table. The measured case is `dkj-music-library`, whose playlist tables
with drag-to-reorder stay in Admin while its product shows the same list as a two-line track row.

**So the rules under "How to use it" and "Page patterns" fall to the layers like this.** A rule not named
here is the shared core's and holds in both.

| Rule | Product (mobile-first) | Admin (desktop shell) |
|---|---|---|
| The `h1`'s size ([Type](#what-it-holds)) | `--text-h1`, standing apart by size and colour | `--text-h1` in the wireframes' page header (`.page-head h1`) at the top of the pane body, an action or a figure at its right end (`.page-head__end`) and a date beside it, outside the `h1` (`.page-head__meta`, Today's); only a page that opens no pane body of its own (the release notes) keeps `--text-h3` in the `.toolbar` over the main pane |
| One `h1`, at most two words, reading what the current crumb reads (rules 8 and 9 under [How to use it](#how-to-use-it), [the bar][product-bar]) | holds | holds: the page header's `h1` and the last crumb in the `.shell__bar` are the same words, which is why Today's date stands beside its `h1` and not in it |
| No intro under the `h1`, and the `h1` never framed (rules 5 and 6) | holds | the `h1` is never framed; **one lead line under it is allowed where the wireframe draws one** (`.page-head__lead`, Home's *Admin is for managing, the product for using.*) |
| [The breadcrumb bar][product-bar]: a `.breadcrumbs-bar` above `<main>`, one `--tap` high, on `--primary` | holds | **does not apply.** The trail sits in the `.shell__bar` (the same `nav.breadcrumbs` markup, starting at **Home**), and the shell takes no `.breadcrumbs-bar`. A `<main>` is no pane of the grid: where a pane holds one, its 1080px cap is lifted |
| [The site header][product-header] and [its menu][product-menu] | holds | **does not apply**: the shell's bar and side navigation replace both |
| [Which shape a page's cards take][product-shape], [a long page becomes cards][product-long] and Admin's [card overview](#admin) | holds | **does not apply as written**: the side navigation is how Admin gets you somewhere, so an overview of card links in the pane repeats it, and a list Admin manages is a `.table--dense`. Cards are back where the wireframes draw them (Goals, Today): a `.card` in the shell is the wireframes' card, on `--bg-1` with a line around it, and `.admin-cols` sets two columns of them. A page with nothing to show draws the `.empty-state` with one copy-prompt action (`Format-AdminEmptyStateHtml`), never a blank page. Where a page still lists the pages under it, it is an `.admin-list`, a row per page with its description (#3830) |
| The 44px target ([Focus and targets](#components)) | holds | **does not apply**: the wireframe's navigation rows (about 36px) and a `.table--dense`'s 28px rows, all above the 24px a pointer needs |
| The page width (`data-width`, `full`/`fluid`/`phone`), `.page-column` and the settings panel's Width control | holds | **does not apply**: the panes fill the window, so the shell mounts `DKJTheme.settings` with `widths: false`, and a pane's content stands in a `.shell__body` |
| Admin's fit alarm | reads the page: the document past the window, the `h1`, the bar's trail | reads the shell (#3830): the main pane past its own height (a pane holding a `.table--dense` scrolls by design), the `.toolbar > h1` or the `.page-head h1`, and the `.shell__bar` trail |


## Page patterns

**The product layer's page patterns moved to its own README** (#3831): the shape a page's cards take, an `h2`
that titles a card, the breadcrumb bar on every page, a long page that becomes cards with a page each, and the
site header with its menu are in [the product README][product-readme], under "Page patterns". Which of them
Admin's desktop shell takes is in the table under [Two layers](#two-layers): it takes the page-name rules and
none of the page structure. **Admin** below is the one page pattern Admin keeps.

## Admin

**This section is Admin's home page and its GitHub page, as the desktop shell draws them** (#3830,
[#3843](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3843)). Until #3830 Admin was a page under the
product's site header with a grid of card links, and that form is retired as Admin's. What lives on of it
belongs to the product layer: a product's own home page takes the site header and the breadcrumb bar
(`Format-ProductHomeHeadHtml` in dkj-solutions' `scripts/lib/product-pages-lib.ps1`, #3831), and its cards
take [the shape a page's cards take][product-shape], both in [the product README][product-readme]. The card
itself ([below](#admin), `Format-AdminCardLinkHtml`) stays a shared component, which both layers still use.

It was called a hub, not a dashboard (owner's call, October 17, 2026, [#199](https://github.com/DKJ-Solutions/dkj-brandbook/issues/199)): its job is to get you to the page you want quickly, while a dashboard is a page that shows how something stands, and the pages below it can be dashboards.

**On screen it is called Admin** (#3815, November 5, 2026; **Toolbox** from October 27 until then): Admin is for managing and the product for using, as in the Shopify Admin. The session-start line opens with `Admin:`, its first crumb reads **Home**, a product links it on an **Admin** card, and its development pages sit under `/dev/...`, the old addresses redirecting there. The code said *hub* for the mechanism until #3873 renamed it too: the plugin's `apps/admin/` folder, the `/admin` route (`/hub` answers with a 301 to `/`).

**Every repo's Admin has this one form, and only its content differs** (owner's decision, October 16, 2026,
[#139](https://github.com/DKJ-Solutions/dkj-brandbook/issues/139)). Admin is the dkj-policy plugin's own
server in every repo that runs it, BWJ-Development's included, and the repo's server is its product
([#3245](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3245)). No repo can opt out of it: the
`OwnHub` key that let a repo serve its own Admin went with
[#3643](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3643).

**Admin is one page, on `/`** (owner, October 22, 2026,
[#3289](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3289)). From October 21 it was two
([#3270](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3270)): a portal home page on `/` and
About this repo on `/about`. Once the repo's name stood on every page, the home page had nothing left of its
own but one link to About, so About's blocks moved onto it. `/about` answers 303 to `/`, so an old link still
lands.

**The home page only gets you somewhere, and what the repo IS sits on a page of its own** (owner, October
24, 2026, [#3383](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3383)). The facts, the open
issues and the pull requests are on the **GitHub** page on `/dev/repository` (called Repository until it took
the GitHub name and logo). From #3383 to #3830 the home page was a grid of card links, three to a row. Since
#3830 it is one list: the side navigation already gets you to every page, so the pane adds only what the
navigation cannot carry, each page's description.

**The home page, top to bottom, in this order** (`Format-PluginRepoAdminHtml` in `dkj-policy`'s
`apps/admin/lib/repo-admin-page.ps1`):

| # | Block | House class | Fixed, or the repo's own |
|---|---|---|---|
| 0 | The shell, opened for the home page: the bar with the one crumb **Home**, and the side navigation with **Home** marked. There is **no toolbar**: the page header the wireframe draws (`.page-head`) holds the `h1`, the repo's name, and one lead line, *Admin is for managing, the product for using.* | `.shell.shell--no-aside`, `.shell__bar` holding `nav.breadcrumbs`, `.shell__nav` (`Format-RepoHomeHeadHtml`, which opens `Format-AdminShellOpen -Current '/' -Bare`) | fixed |
| 1 | The general banner, the first thing in the main pane's scroll area, with no margin, border or radius (owner, October 24, 2026): a countdown to the next full hour, and once an hour has passed a tone and a **10 airsquats** checkbox that shows the total owed ([#3250](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3250)), the same on every machine ([#3438](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3438)) | a `.notice` holding one `.msg` line, written by `Format-RepoAdminBanner` in `dkj-policy`'s `apps/admin/lib/general-pages-lib.ps1` | fixed: an Admin a repo builds itself carries it only if it calls that function |
| 2 | Only where a server the page links is not running (the repo's product, or the general pages server): one line saying so, where its row would be | `.msg--warn` with `role="status"` | the plugin's own text |
| 3 | **The pages**, a row each with its description, in this order: the repo's product where it states one, **GitHub**, and the general pages but those on the GitHub page (Issues, the Test gate), a group's pages behind its one row (below) | one `.table--dense` with no heading (`Format-AdminLinkTableHtml`) | fixed form; the product is the repo's own |
| 4 | Only where the plugin's Admin serves a repo that states no product: the two **Set up a product** cards, under their own `h2` | a `.grid-2` with a `.grid__head`, then one `.card.grid__full` per step | the plugin's own text |
| 5 | A footer note naming the script that serves the page | `.note` | fixed |

**The GitHub page, on `/dev/repository`, in the same shell, its trail Home > GitHub** (`Format-PluginRepoRepositoryHtml`):

| # | Block | House class | Fixed, or the repo's own |
|---|---|---|---|
| 0 | The toolbar's `h1` **GitHub** alone, with **GitHub** marked in the side navigation; what the page is for goes in its `<meta name="description">`, not under the `h1` (#3585) | `.toolbar > h1` | fixed title; the description is the repo's own |
| 1 | **The facts**, as one row on the page rather than in a card: label over value | `.facts.facts--row` (a `<dl>`) | the facts are the repo's own |
| 2 | **Its pages**, a row each: **Issues** and the **Test gate** first, then the repo's pages on GitHub (its pull requests, its CI runs) where it has a GitHub remote | one `.table--dense` (`Format-AdminLinkTableHtml`) | Issues and the Test gate fixed; the GitHub rows the repo's own |
| 3 | Where a repo keeps in-flight lists: one stat tile per list, the loading or warning line, and **In flight**, one data card per list under one `h2` | `.tiles` / `.tile`; a `<p>` with `role="status"` / `.msg--warn` with `role="alert"`; a `.grid-2` with a `.grid__head`, then one `.card.grid__full` per list around `.table-wrap` / `.table` | the repo's own lists. A count not read yet shows `--` |
| 4 | A footer note naming where the data comes from | `.note` | the repo's own source |

A repo with no in-flight lists leaves block 3 out; this source repo's Admin and the plugin's are both such
repos. **An open issue is not listed twice**: where the **Issues** row is on the page, an in-flight issues
list is that page's job, and the page links it rather than repeating it.

**The card.** It is the one card link on **every** page, not only on the home page: an overview of
sections, a group page and a plugin's own page all use it ([#3563](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3563)).
Each card is a `.card.card--link` holding one house `.menu-item` row as an `<a>` (label,
optional one-line description beneath it, a chevron at the end) inside a `<nav class="menu-list">`: its link
stretches over the whole card, so a click anywhere on the card follows it, and the whole card tints on hover
([#3298](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3298)). A `.tile` is a figure that does
not respond, so the two cannot be mistaken for each other. Its label is the page's own name as its breadcrumb
reads it, short, in the app's language; its description is one line or nothing. A card links a route on the
same dev server; only the Repository page's GitHub cards leave it. A page that cannot be linked (a product
whose server is not running, a general pages server that is not up) is a plain `.card` holding one `<p>`
saying so, in the place its card would take. `Format-AdminCardLinkHtml` in `dkj-policy`'s
`apps/admin/lib/general-pages-lib.ps1` writes the card; both served Admin servers use it, and **every** card link in Admin's
page code goes through it, since a suite in `dev-pages.tests.ps1` fails on one written by hand
([#3566](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3566)).

**Its slots**, so that no overview needs a card of its own. Each one is optional:

- **A headline figure**, the value that tells you whether the page is worth opening (a size against its
  budget, a run's time), on a line of its own under the description: `.menu-item__value`.
- **A status badge** in the icon's place, where the card stands for something that has a state (a plugin):
  the house `.badge`.
- **The label as an `h2`** (a plain `h2` or `h3` inside a `<div class="menu-item__label">`; `.menu-item__title` is gone, Maikel, November 1, 2026) where the cards
  are a page's sections or groups, so the page's outline still names them.
- **A status mark right after that label** (`-TitleBadgeHtml`: `<h2><span>label</span><span class="badge">`),
  where the state belongs to the name rather than in the icon's place.

**A card's title is always one line** (owner, October 28, 2026): where the label, plain or as an `h2`, does not
fit the card's width it is cut off with an ellipsis, and a mark after it keeps its place. The description and
the value under it still wrap. So a page never shortens a name to make it fit, and never styles this per page.

**No slot holds an `<a>`.** The card is one link, and an `<a>` inside an `<a>` is invalid HTML: the browser
closes the card's link at the inner one and the card falls apart
([#3610](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3610)).
- **An `id` and extra classes** on the card, for an anchor or a tone of the page's own (a run's speed colour).

```html
<section class="card card--link"><nav class="menu-list" aria-label="Repository"><a class="menu-item" href="/dev/repository"><span class="menu-item__label">Repository<span class="menu-item__sub">This repo's facts and its open issues</span></span><svg class="menu-item__chevron">...</svg></a></nav></section>
```

**The order of the home page's rows.** The product comes first, because it is what the repo offers its
visitors; a product is never the page on `/`. Then **GitHub**; then the general pages every repo has
(Release notes, SessionStart), Issues and the Test gate left to the GitHub page. No Admin
carries a Brand book card ([#3475](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3475)), and the
Brandbook app is retired ([#3493](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3493)).

**A card is ALWAYS one link, never two or more** (owner, October 27, 2026). Pages that belong together
are grouped on a **group page** of their own, and Admin carries one card linking that page. **Clock**
(`/dev/clock`) was the first: the page was an `h1` with one card link each for Stopwatch and Logbook. Groups nest,
and a group can also be a **section**, an `h2` over its members' `h3` cards with no page of its own: Clock is
one on Performance's page since November 3, 2026, beside Context, and Performance sits on Claude's, so the
trails read Home > Claude > Performance > the page, and Admin carries only the Claude card. A page joins a group by the
`Group` key in `Get-GeneralPages`; the group itself is a row of `Get-AdminGroups`, and
`Format-AdminGroupPageHtml` draws its page.

**The in-flight lists, where a repo has them:** open pull requests, newest first, with the branch as the
sub line (and "(draft)" on a draft); open issues by their `prio-N` label, unprioritised last and the highest
number first within a priority, with who claimed it as the sub line; every branch off the trunk, with its pull
request where one is open. A repo leaves out a list it has no use for and adds one it needs, each as a tile
and a card. An empty list keeps its card and says so in the table ("No open issues.").

**What is fixed:** the two pages and their routes (with `/about` sending on to `/`), the order, the shell
with its crumbs and its navigation, the one list with no heading, the GitHub row on the home page and the
Issues row on the GitHub page. **What is the repo's own:** the name, its products, its own pages, which lists appear,
the facts, and the data source. A private repo reads its lists without the GitHub API's unauthenticated
access and says how in the footer note.

**On a product's home page, no `<header>` directly inside `<main>`.** The brand book makes `main > header` the
page-header row, a flex row with its controls beside the title. The site header stands above `<main>`, outside
it, and #137 hit exactly this with an intro that was a `<header>`.

**The form is complete from `house-style.css`** ([#141](https://github.com/DKJ-Solutions/dkj-brandbook/issues/141)).
Every block above has a house class, the shell's included, so Admin's two pages need no CSS of their own beyond
the setup cards' `.ph-code`; the stylesheet-only reference for the shell is
[`patterns/admin-shell.html`](patterns/admin-shell.html). **The rest of this paragraph is the product layer's
page column**, where Admin's blocks stood until #3830. The blocks stack in the page column, `.page-column` on `<main>`, which
takes the top margin of its direct `.card`, `.tiles`, `.notice` and `.note`, so they sit one
`--spacing-5` apart; `.grid-2` does the same for a direct `.card`, `.tiles` or `.notice`, so its rows sit
one `--spacing-4` apart ([#207](https://github.com/DKJ-Solutions/dkj-brandbook/issues/207)), and
`.grid__head` and `.grid__full` span every column of it. An in-page anchor scrolls to `5rem` below the top,
clear of the settings button; a card a table links down to carries a compact outline "Back to overview"
button in its card head ([#156](https://github.com/DKJ-Solutions/dkj-brandbook/issues/156)). **For Admin, a
repo without a build copies [`patterns/admin-shell.html`](patterns/admin-shell.html)**; **for a product, it copies
[`patterns/product-home.html`](../../extensions/dkj-solutions/assets/dkj-brandbook-product/patterns/product-home.html) and
[`patterns/product-page.html`](../../extensions/dkj-solutions/assets/dkj-brandbook-product/patterns/product-page.html)**, the
stylesheet-only reference pages for a product's home page and a page one level below it, beside the product layer
in dkj-solutions (#3831). They draw the product layer's own form (the site header with its menu, the breadcrumb
bar, the cards), link `house-style.css`, `house-product.css` and `house-theme.js`, and carry no CSS of their own.
Until [#3849](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3849) they were `repo-dashboard.html` and
`repo-repository.html` and still drew Admin as it was before #3830. **These patterns are the only reference**:
the Brandbook app drew no Admin specimen or previews of other repos' Admin servers from October 21, 2026 (owner,
[#3274](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3274)) and is retired now, so a repo with
a framework builds the form from the blocks above with its own components.

**`.btn` draws no underline on a link any more** (#141): a `.btn` on an `<a>` showed the browser's underline,
because the house link rules set its thickness and not whether it shows. An app with link buttons loses that
underline when it takes this update; a `<button class="btn">` is unchanged.

## What was deliberately left out

The parts of the ETF dashboard that only make sense there stayed there: the hazard-striped advice zone
and its tokens, the market report's layout, the month-note button drawn on a chart bar, the
primary/secondary view switch, the mapping from ETF/share/cash to a colour, and the Dutch status class
names. The three
series colours survive as `--cat-1..3`, with the same values. A generic danger/alert component is **not**
in the brand book yet. Adding one is a design decision for the owner, not something to back-fill from
the advice zone.

## Changing the brand book

A change here reaches every DKJ-Solutions app the next time it takes a copy, so it is a **visible
result**: the branch stops for the owner's look instead of merging. Bring a consumer's improvement here
as an issue on this repo. Don't make a local edit and hope it travels.

**A merged change reaches nobody until it is released.** A release is a tag on `main`, and it is set only
on the owner's explicit request, like any tag. The first four releases were set by hand as
`house-style-v1` to `house-style-v4`. The owner brought those four together as `v0.1.0`, the first
`vX.Y.Z` release (#172, #178), and every release since is cut with the `dkj-policy` plugin's
`cut-release` and tagged `vX.Y.Z`. The cut also writes the release's changelog notes and its row in
[`.dkj/dkj-policy/releases/history.md`](https://github.com/DKJ-Solutions/dkj-brandbook/blob/v0.4.0/dkj-policy/releases/history.md), which lists the four earlier releases
too. A tag is never moved or reused: a fix is a new release. Then the `dkj-brandbook` skill in the
`dkj-solutions` plugin
([DKJ-Solutions/dkj-marketplace](https://github.com/DKJ-Solutions/dkj-marketplace)) is repointed to
the new tag, through an inbound issue there, and the apps get it with that plugin release. So one house-style
change costs one tag here and one pointer update there, and that second step is the point: nothing reaches
the apps that has not been released. **The product layer follows the same process**: `house-product.css` has a
row of its own in that skill's table, and the cut rewrites its URL and checksum with the other two.

[product-readme]: ../../dkj-solutions/assets/dkj-brandbook-product/README.md
[product-bar]: ../../dkj-solutions/assets/dkj-brandbook-product/README.md#every-page-the-breadcrumb-bar
[product-header]: ../../dkj-solutions/assets/dkj-brandbook-product/README.md#the-site-header-above-the-bar
[product-menu]: ../../dkj-solutions/assets/dkj-brandbook-product/README.md#the-menu-in-the-header
[product-shape]: ../../dkj-solutions/assets/dkj-brandbook-product/README.md#which-shape-a-pages-cards-take
[product-long]: ../../dkj-solutions/assets/dkj-brandbook-product/README.md#every-page-a-long-page-becomes-cards-with-a-page-each
