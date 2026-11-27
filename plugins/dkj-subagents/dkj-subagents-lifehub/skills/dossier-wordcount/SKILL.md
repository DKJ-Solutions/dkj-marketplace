---
name: dossier-wordcount
description: >-
  Keep a Notion dossier's word-count property in step with its body and flag ones past the split threshold. Use after writing into a dossier, or for "which dossiers are getting too long?".
---

# /dossier-wordcount: the word count follows the page

**Ian (04-03, Information Architect) owns this skill.** A dossier's word count tells the owner which
page nears the limit and must be split into child dossiers. A count nobody updates is enforced against a
stale number, which is worse than no number at all: measured in a consumer, a dossier grew from about 110
to about 1,430 words in one session while its property still read 110 (#4371). Notion cannot compute it
either, because a formula property cannot read the page body. So **the writer recounts**, in the same
step as the write. It works directly in Notion, with no branch or PR (#4214).

## 0. Read the settings first

Everything personal lives in the owner's private Notion, never in this public plugin. Search Notion for
the page titled **Instellingen dossier-wordcount** and read it before anything else. It names:

- the **Dossiers** data source, and a **view** that shows every row;
- the **property** that holds the word count (a number property on that data source);
- the **split threshold**, in words;
- the **language** the close-out line is written in.

**No settings page, or no Notion connector: stop and say so in one line.** Never guess a property or a
limit. A page that is not a row of that data source is not a dossier, and gets no count.

## 1. Count with the shared counter, never by eye

Every writer uses the one counter, so the number means the same whoever wrote last:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/dossier-wordcount/count-words.ps1" -Path <body.md> -Threshold <threshold>
```

Fetch the page with `notion-fetch`, write its body as returned to a file in the scratchpad, and pass that
file. The first line printed is the count. A second line starting `OVER:` appears only when the count is
above the threshold. The rule: a link keeps its text and loses its URL, every tag goes with its
attributes (mentions, callouts, tables), bare URLs and HTML entities go, a code fence loses its marker,
and a token counts when it holds a letter or a digit. **A shell without PowerShell** (a cloud session's
Linux container): install PowerShell first -- `pwsh` from Microsoft's package source, for example
`apt-get install -y powershell` once that source is configured -- and run the same line with `pwsh` in
place of `powershell`. **Never rebuild the counter in another language**: a second implementation per
session is exactly the drift this one counter exists to prevent (#4481). Where the install fails, treat
the session as having no shell, below. **No shell to run it** (a Chat session, or the install failed): apply
the same rule by hand and say the number is a hand count. The counter's suite is `scripts/tests/dossier-wordcount.tests.ps1`
in the source repo.

## Mode 1: after a write (one dossier)

The closing step of **every** write into a dossier's page body, by Ian or by a skill
([`inbox-sweep`](../inbox-sweep/SKILL.md), [`ai-radar`](../ai-radar/SKILL.md), [`agenda`](../agenda/SKILL.md)):

1. Fetch the page again after the last write, and count it (step 1).
2. Set the property the settings name to that count with `notion-update-page`, in the same pass. Only
   that property is touched.
3. **Over the threshold:** say so in the close-out, one line per page: its title, the count, the
   threshold, and a proposed split (which sections become which child dossiers). Propose it; do not
   leave it for later, and do not split without the owner, because which child dossiers to make is a
   judgement about content.

Several writes to one page in one run need one count, after the last of them.

## Mode 2: recount (every dossier, or those edited since a date)

A safety net for edits made by hand in Notion, which no writer counts.

1. Fetch every row at once with `notion-query-data-sources` in **view mode** on the view the settings
   name. Never SQL or rows mode: those share an hourly quota. On `has_more`, follow `start_cursor`.
2. When the owner names a date ("since Monday"), keep only rows last edited on or after it.
3. Per row: count (step 1), and update the property only when it differs from the count.

**Report** in the language the settings name: how many dossiers were counted, how many changed, and every
page over the threshold with its count.
