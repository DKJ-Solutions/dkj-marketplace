---
name: agenda-sync
description: Sync the owner's Google Calendar into the Notion Agenda database of a life hub, with Google as the source. New events are added, changed ones updated, vanished ones marked Vervallen (never deleted), and a row that exists only in Notion goes to Google once. A likely duplicate or a same-day clash is reported to the owner as a question, once per pair, and never fixed by the sync itself. Built to run unattended, as a daily scheduled task or cloud routine. Use it for /agenda-sync, "sync the agenda", "put Google Calendar in Notion" or "is the agenda still right", in whatever language it is asked.
---

# /agenda-sync: Google Calendar into the Notion Agenda

**Astrid (02-10, Personal Assistant) owns this skill.** She works directly in Notion and Google
Calendar, with no branch or PR: content in Notion is visible and reversible at once.

**Google Calendar is the source, Notion follows.** The owner adds most events on their phone, so on
any difference Google wins (#4204).

## 0. Read the settings first

Everything personal lives in the owner's private Notion, never in this public plugin. Search Notion
for the page titled **Instellingen agenda-sync** and read it before anything else. It names:

- the **owner**, the default for the Wie column;
- the **Agenda data source** (`collection://...`) and a **view** (`view://...`) that shows every row;
- which Google calendars **do not count** (the primary calendar is the source);
- the **row conventions**: the language rows are written in, how a birthday title becomes Wat and
  Wie, how Google names birthdays imported from contacts, and the closing text of a new row's Notitie;
- optionally, **words that do not count** for the near-duplicate signal (step 4): common title words in
  the owner's language, such as "bij" or "verjaardag".

**No settings page, or no Google Calendar or Notion connector: stop and say so in one line.** Never
guess a database.

## The Agenda columns

Wat (title), Datum, Jaarlijks, Wie, Sinds, Vooraf (dagen), Dossier, Notitie, **Google ID**,
**Vervallen** and **Gesignaleerd** (text, step 4). If Gesignaleerd is missing, add it once as a text
property. Adding a column deletes nothing. Fetch the rows in **view mode** on the view the settings name, not in SQL or rows mode:
those share an hourly quota.

**The key is `Google ID`**: the `id` of a single event, or the `recurringEventId` of a series. With it
an event is found again after it was moved or renamed.

## 1. Fetch

1. **Google:** `list_events` on the primary calendar, from today to 12 months ahead, `orderBy`
   `startTime`, with `eventType` `DEFAULT` **and** `BIRTHDAY`. Follow `nextPageToken` to the end. Skip
   events whose `status` is `cancelled`.
2. **Fold a series into one event**: every instance with the same `recurringEventId` is one row, dated
   at its next instance. Read the recurrence with `get_event` on the `recurringEventId` (the
   `recurrence` field).
3. **Notion:** every Agenda row in view mode (follow `has_more`).

## 2. Compare and update

Per Google event (or series):

| What Notion has | What you do |
|---|---|
| A row with the same `Google ID` | Update what differs: Wat, Datum and Jaarlijks. Leave the rest |
| No row with that ID, but a row without an ID on the same date with (nearly) the same name | The same event: set its `Google ID` and update as above |
| No row | Create one (below) |

**How a Google event becomes a row:**

- **Wat** = the Google title, **Wie** = the owner, unless the title names someone else; the settings
  page says how a birthday title splits into Wat and Wie.
- **Datum**: an event with a time becomes a datetime (`is_datetime` 1, in UTC); an all-day event a
  date without a time.
- **Jaarlijks**: on for `RRULE:FREQ=YEARLY` or `eventType` `BIRTHDAY`; **Sinds** = the year of the
  first instance.
- **Any other recurrence** (monthly, every 4 months): Jaarlijks off, Datum = the next instance, and a
  Notitie saying how it repeats in Google (wording from the settings). Every run moves the date on.
- **Notitie** on creation: the Google description and location, plus the closing text from the
  settings.

**The sync never overwrites** Notitie (after creation), Dossier, Vooraf (dagen) or Wie. The owner or
another skill fills those in Notion, and they do not exist in Google.

## 3. What only Notion still has

- **A row with a `Google ID` whose event is no longer in the fetched list**: check with `get_event`
  whether it is really gone. An event more than 12 months out, or a yearly series, is not gone. If it
  is cancelled or not found (404), switch **Vervallen** on. Never delete the row: Notion asks the
  owner to confirm a delete, and the report names the row.
- **A row without a `Google ID` dated today or later**: it was made outside Google. **First check
  whether Google already has it under another name**, with `eventType` `BIRTHDAY` included: Google
  adds birthdays from the owner's contacts under its own titles (the settings page gives examples). A
  birthday of the same person on the same day is the same event: only set the `Google ID`. Leaving
  `BIRTHDAY` out of that search once produced duplicate birthdays. Only when it is really missing,
  create it in Google once (`create_event`; yearly with `RRULE:FREQ=YEARLY`; an all-day event with
  `allDay`; a reminder or deadline as `AVAILABILITY_FREE`), then set the `Google ID` on the row.
- **Rows in the past** stay as they are, except yearly ones: their date moves on to the next year.

## 4. Signals: ask the owner, never fix

The sync can spot entries that look wrong but cannot know which one is right. **It reports them to the
owner and changes nothing in Google or in the dates.** A note in a row's Notitie does not count as
reporting, because nobody reads it there (#4369). In the case behind that issue, a wrong all-day event
two days before the right one was only noted in a row, and the owner found it weeks later by chance.

Look at every row dated today or later that is not Vervallen:

1. **Possible duplicate:** two events at most **7 days** apart whose titles share a **distinctive
   word**, meaning a word of 4 letters or more that is not a number and not on the settings page's list
   of words that do not count. Example: "Sinterklaas bij de Hoogies" (Fri) and "Sinterklaas bij fam"
   (Sun). Ask: *possible duplicate, which one is right?*
2. **Possible clash:** on the same day, a single-day all-day event and a timed event, or two timed
   events that overlap. Ask: *these fall on the same day, is that right?* Leave out birthdays (`eventType`
   `BIRTHDAY` or a yearly birthday row), events marked free (`AVAILABILITY_FREE`), and all-day events
   that span more than one day, such as a holiday. Those do not take up the day.

**Each pair is reported once.** Before reporting, read **Gesignaleerd** on both rows. If one of them
already holds the other's Google ID, skip the pair. After reporting, add the other's Google ID to
Gesignaleerd on both rows, comma-separated if there is more than one. A pair whose date or title changes
afterwards is not reported again until the owner clears the column. This one write is the only thing the
sync puts into a row because of a signal. Notitie stays untouched, as in step 2.

## Hard limits for an unattended run

## Hard limits for an unattended run

- **Never delete anything**, in Google Calendar or in Notion. A vanished event gets Vervallen.
- **Never touch the git checkout**: no branch, commit, push or PR. Write only to Notion, and to Google
  only for a row that exists in Notion alone.
- **Check Google before creating anything there**, birthdays from contacts included.
- **Never resolve a signal yourself**: no moving, renaming or marking Vervallen because of step 4.

## 5. Report

**New signals come first**, before the counts, so the first lines of the run's summary carry them
wherever it lands (a push notification, the scheduled task's output). Give one line per pair: both titles
with their dates (and times, if they have them), the question, and both row links. Then, keep it short:
how many rows were new, updated, pushed to Google and marked Vervallen, with their names, and
the start and end time of the run. A row marked Vervallen carries its link, so the owner can delete
it. With nothing to do and no new signal, the report is one line. Write it in the language the settings name.
