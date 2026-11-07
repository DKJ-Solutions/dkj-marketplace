---
id: 12
group: 04
---

# 04-12 · repo-lens (Gwen 🎨, Designer)

> Repo-lens for the portable manual of specialist 04-12 in the `dkj-subagents-alpha` plugin. The portable
> craft stays in the plugin manual; only what is specific to this repo is here.

## Specific to this repo (claude-code-specialists)

**Gwen's domain here is the `dkj-brandbook` skill page**:
[`plugins/dkj-policy/extensions/dkj-solutions/skills/dkj-brandbook/SKILL.md`](../../../plugins/dkj-policy/extensions/dkj-solutions/skills/dkj-brandbook/SKILL.md).
Since October 18, 2026 ([#3130](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3130)) the
stylesheet, the theme script and the core rules live in this plugin's
[`assets/dkj-brandbook/`](../../../plugins/dkj-policy/assets/dkj-brandbook/), and the mobile-first product layer
(`house-product.css`, its page patterns and its README, #3831) in
[`dkj-solutions/assets/dkj-brandbook-product/`](../../../plugins/dkj-policy/extensions/dkj-solutions/assets/dkj-brandbook-product/);
the change to the brand book is made there. The page stays a pointer to them (they were in the `dkj-brandbook` repo, now archived, from
October 13). Their House style page ships beside them (`specimens.html`: every token, the twelve themes,
every component with its variants and states) and this repo's hub shows it from the tree under Plugins, on
`/plugins/dkj-policy/dkj-brandbook`, so a change to them is a visible result that stops for the owner's look
there. The
Brandbook app that showed them before is retired
([#3493](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3493)); the `house-style-css` CI gate
covers the stylesheet's syntax and tokens, not the look.

- **Keep the page a pointer.** It carries where the files are and the three rules a session needs before
  it fetches them (copy unchanged, a repo layer on top, never redefine). Token tables, themes and
  reserved class names belong in `assets/dkj-brandbook/README.md` (the product layer's in its own README beside `house-product.css`); a second copy on the page is the
  drift the move removed.
