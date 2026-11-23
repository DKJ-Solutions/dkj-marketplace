---
name: agenda
description: Walk the coming weeks with the owner of a life hub, as their personal assistant -- reads the birthdays and fixed dates from the Agenda database in Notion, looks 8 weeks ahead, and proposes one concrete action per date (a present, a card, a booking, something to arrange). Use it for /agenda, "what's coming up", "who has a birthday soon" or "what do I need to arrange", in whatever language it is asked.
---

# /agenda: the coming weeks, with one action per date

**Astrid (02-10, Personal Assistant) owns this skill.** She works directly in Notion, with no branch or
PR: content in Notion is visible and reversible at once (#4214). Where
[`agenda-sync`](../agenda-sync/SKILL.md) keeps the Agenda in step with Google Calendar, this skill
*reads* it with the owner and turns each date into something to do.

## 0. Read the settings first

Everything personal lives in the owner's private Notion, never in this public plugin. This skill reads
the same database as `agenda-sync`, so it reads the same settings: search Notion for the page titled
**Instellingen agenda-sync** and take from it the **owner**, the **Agenda data source** and the **view**
that shows every row, and the **language** rows are written in. For step 3's task cards it also reads
the **Tasks data source**, the **relation on Tasks** that points at an Agenda row, and that relation's
**back-relation on Agenda** (#4279). These three are optional. Without them, step 3 creates no card and
says so in one line.

**No settings page, or no Notion connector: stop and say so in one line.** Never guess a database.

The Agenda columns: Wat (title), Datum, Jaarlijks, Wie, Sinds, Vooraf (dagen), Dossier, Notitie, and
the `agenda-sync` columns Google ID and Vervallen.

## 1. Fetch the dates

Fetch **every row at once** with `notion-query-data-sources` in **view mode** on the view the settings
name. Never SQL or rows mode: those share an hourly quota that runs out, and view mode does not. The
register is small enough to fetch whole. On `has_more`, fetch the next page with `start_cursor`. Skip a
row whose **Vervallen** is ticked.

Then work out yourself what counts:

1. **Within 8 weeks:** `Datum` between today and today + 56 days. When the owner asks for another span
   ("the next 3 months"), use that instead.
2. **Yearly rows** (`Jaarlijks` ticked) count as soon as their day and month fall inside the span, even
   when the year in `Datum` is old. A yearly row whose `Datum` has passed gets its year moved on (step 4).

Include a date once today >= the date minus **Vooraf (dagen)**, which is **21** when empty. Show each
with what it is, the date, how many days are left and, for a birthday, the age (from the year in `Sinds`,
or a birth year in `Notitie`, only when one is there).

## 2. One action per date

Look up what Notion already knows before proposing anything:

- **A person (`Wie`):** `notion-search` for that name in the hub (preferences, earlier presents, a
  dossier of their own). Say what you found and where.
- **A dossier (`Dossier`):** fetch the page with `notion-fetch` and name the open points that must be
  done before that date.

Then propose **one** concrete action with a moment, e.g. *"order the present before 7 November, because
delivery takes a week"*. Never invent a preference Notion does not hold: say nothing is known, and ask.

## 3. What goes back to Notion

When the conversation teaches something new (a present idea, what was given, a new birthday), write it
to Notion at once, without asking first:

- **A new date:** a new Agenda row (`notion-create-pages` with the data source as parent), with Wat,
  Datum, Jaarlijks, Wie and where known Vooraf (dagen), Dossier and Notitie. A row with a time or a
  place belongs in Google Calendar first; that is `agenda-sync`'s, so say so rather than writing both.
- **A present idea, or what was given:** in that row's `Notitie`, or on the person's dossier page, at
  the top of the heading it belongs to (newest first, #4379). A write to a dossier page ends with its recount through
  [`dossier-wordcount`](../dossier-wordcount/SKILL.md) (mode 1).
- **An accepted action becomes a card in Tasks** (#4279). When the owner accepts the action proposed in
  step 2, create one page in the Tasks data source the settings name. Its title is the action, in the
  language the settings name. Its deadline is the action's moment. Its relation (the one the settings
  name) points at the Agenda row. Take the property names from the Tasks data source's own schema, and
  never assume them. The Agenda holds the rhythm, and Tasks holds one card per occurrence.
  **Check for a duplicate first, so a second run does not create the card again.** The Agenda row's
  back-relation is already in step 1's fetch, so read the cards it lists. When one of them has a deadline
  inside this occurrence's span (from the date minus Vooraf (dagen) up to the date itself), create
  nothing, and name the existing card instead. A card for last year's occurrence of a yearly date falls
  outside that span, so it does not count.

## 4. Move a passed yearly date on

A yearly row from step 1 whose `Datum` has passed gets its year raised by one until it lies in the
future again (`notion-update-page` on that row), day and month untouched. Do this after the walk-through,
and name the rows you moved in one line.
