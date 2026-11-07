# AI radar

**A running log of what is happening in AI, with Claude Code as the main focus, and each item held
against what this marketplace already ships.** Tips, updates and tricks arrive through social feeds and
team chats faster than anyone can remember them. This folder is where they are kept, and where each
one gets a verdict: do our plugins already cover it, is it a gap, or does it not apply to us?

Started by Maikel on November 7, 2026.

## The files

| File | What goes in it |
|---|---|
| [`claude-code.md`](claude-code.md) | Claude Code itself: releases, features, settings, hooks, skills, subagents, plugins, MCP, workflows and tips for using it. **The main focus.** |
| [`models-and-api.md`](models-and-api.md) | Claude models, the API, the Agent SDK, pricing and limits. |
| [`ecosystem.md`](ecosystem.md) | The wider AI world: other coding agents and tools, MCP servers, practices and ideas worth borrowing. |

A file splits when it gets too long to scan. Split it by subject, add the new file to the table above,
and do not repeat its entries anywhere else.

## An entry

New entries go at the **top** of their file, so the newest is always read first.

```markdown
### <Short name of the thing>

- **Seen:** 2026-11-07, <where: a LinkedIn post, a team chat, a changelog, ...>
- **Source:** <link to the public original: the release note, the docs page, the post>
- **What it is:** one to three lines, in our own words.
- **Our setup:** <verdict>, then what it is based on (see below)
- **Notes:** optional: how we would use it, a caveat, a related entry.
```

**Link the original rather than the post that shared it** where one exists. A tip that quotes a
release note is worth less than the release note.

## The verdict: held against our own setup

Each entry gets exactly one of these under **Our setup**:

| Verdict | Meaning | What it must cite |
|---|---|---|
| `Covered` | Our plugins already do this. | The path that does it, e.g. `plugins/dkj-policy/skills/worktree-lane/`. |
| `Partly` | We do some of it. | The path, and what is missing. |
| `Gap` | We do not have it, and we want it. | The issue number filed for it. |
| `Not for us` | It exists, and we choose not to have it. | One line saying why. |
| `To assess` | Not yet compared. | Nothing yet. This is the inbox. |

**"Our setup" means the tree as it stands**: the plugins under [`../plugins/`](../plugins/), the
repo's own [`.claude/`](../.claude/) and the CI under [`../.github/`](../.github/). Look it up in the
tree each time instead of keeping a list of our features here, because such a list would go stale
from the next merge. The cited path is the proof.

**A `Gap` becomes an issue on this repo's tracker**, labelled `feature` (or `bug`), and the entry
cites its number. The issue is where the work happens; the entry is where the reason for the work
is kept. When the issue is shipped, the verdict changes to `Covered` with the path that now does it.

**`To assess` is the inbox, not a resting place.** Ask a session to "go through the radar" and it
takes every `To assess` entry, compares it against the tree and gives each a verdict.

## What does not belong here

- **Anything that is not public.** This repo is public, so an entry only holds what anyone could read
  on the internet. A colleague's tip is fine because it comes from public sources; anything internal
  to a client or an employer is not.
- **Research answering a question.** A finding for an issue lands as a comment on that issue, as
  [Rebecca's lens](../.claude/specialists/lenses/specialist-03-07-lens.md#where-findings-land-here)
  says. The radar is the log of what came in, not the place where a question gets answered.
- **Another language.** The repo is English, so entries are too, whatever language the tip arrived in.
