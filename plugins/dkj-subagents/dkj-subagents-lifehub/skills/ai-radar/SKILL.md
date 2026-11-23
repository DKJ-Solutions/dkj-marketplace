---
name: ai-radar
description: Collect Claude Code tips, tricks and updates into the AI dossier of a life hub in Notion, and merge duplicates into one item. Two modes -- the check walks the followed sources (the Claude Code changelog, the API release notes, Anthropic News, Engineering and the Claude blog) and adds what is new, built to run daily and unattended; the inbox processes a post the owner pastes (a link or text from LinkedIn, Instagram, a team chat). Use it for /ai-radar, "check the AI sources", "any new Claude Code updates?", or when the owner shares a post about Claude or AI to keep, in whatever language it is asked.
---

# /ai-radar: Claude Code tips into the AI dossier, without duplicates

**Ian (04-03, Information Architect) owns this skill: he places.** Rebecca (03-07, Research Specialist,
core team) fetches and summarizes. They work directly in Notion, with no branch or PR: content in Notion
is visible and reversible at once (#4214).

## 0. Read the settings first

Everything personal lives in the owner's private Notion, never in this public plugin. Search Notion for
the page titled **Instellingen ai-radar** and read it before anything else. It names:

- the **AI dossier**: its main page, and how to find its child pages (the data source and the filter);
- the child pages by role: the **sources** page, the page per model family (the tool itself, the models
  and API, the ecosystem) and the **prompts** page;
- the **repo** to compare a shared prompt with (the owner's plugin marketplace), local path or GitHub;
- the **language** items are written in.

**No settings page, or no Notion connector: stop and say so in one line.** Never guess a page.

Then fetch and read, before writing anything:

- **the AI dossier's main page**: the item format, the verdicts (and which one a new item gets), and its
  rule for a duplicate -- *a duplicate is one item*;
- **the sources page**: the table of followed sources, what belongs from each, and how far each was
  processed (its *last processed* version or date).

An item belongs to its model family's page, directly under the marker line that page carries for new
items. Write with `notion-update-page` (insert new text, only ever add to existing text), in exactly the
format the page shows, and **newest first** (Ian's rule, #4379): a new item goes directly under that
marker line, above the older items, and an addition to an existing item goes at the top of it, its
newest source first.

## Mode 1: the inbox (the owner pastes something)

1. **Read the post.** A LinkedIn or Instagram link the owner shares is opened in their own browser
   (Claude in Chrome, that one post only); if that fails, ask them to paste the text. Find the
   **original** the post refers to (the release note, the docs page) and link it as the first source,
   the post as the second.
2. **Is it already there?** Search the dossier's pages (`notion-search` within the dossier) for the
   setting, command or feature name. If it is, add to that item under the duplicate rule. If not, a new
   item with the verdict the main page gives a new item.
3. **A prompt** (somebody shares an instruction to give Claude) goes on the prompts page, in its format.
   Describe it in your own words and link the original; never copy the text. Search the repo the
   settings name for what already exists, give it a value, and say how it would be used. Read the
   replies too: a better variant is often there.
4. **Several tips in one post:** each is its own item, or an addition.
5. **An account the owner names** goes in the sources page's account table. Check whether it has a
   newsletter, blog or YouTube channel with RSS; if so, add that channel to the followed sources.

## Mode 2: the check (walk the sources)

Per followed source on the sources page:

1. **Fetch it** with `curl -sL` (the changelog is plain Markdown, the others HTML). On failure, note it
   and go on with the next source.
2. **Only what is newer than its *last processed***: for the changelog every version above the number
   named, for the others every post dated after the date named.
3. **Filter on what belongs** (the sources table says what, per source). From the changelog only lines
   starting with `Added`, or `Changed` where the change alters how one works. Bug fixes, and what only
   touches Bedrock, Vertex, Foundry or a gateway, drop out. Ten good items beat sixty changelog lines.
4. **Deduplicate** as in mode 1, step 2. The same thing from two sources (the changelog and a blog post)
   is one item with two sources.
5. **Move *last processed* on** to the newest version or date you read, even when nothing belonged.

**Give no verdict during a check.** Every new item gets the verdict for a new item; judging it needs a
look at the owner's own setup, which is a separate pass the main page describes.

## Close

- **Check what you wrote:** fetch the changed pages again and confirm *last processed* moved and no
  item stands twice.
- **Recount every changed dossier page** with [`dossier-wordcount`](../dossier-wordcount/SKILL.md)
  (mode 1), and name a page over the split threshold in the summary.
- **The summary is short:** per source how many new items and how many additions, and the new items'
  names. A source that could not be read is named.
