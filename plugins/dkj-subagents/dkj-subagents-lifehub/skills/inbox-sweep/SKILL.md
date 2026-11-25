---
name: inbox-sweep
description: Walk the owner's Gmail inbox the way an issues sweep walks a backlog -- each thread is processed into the owner's Notion life hub and only then archived. Per thread Astrid picks the specialist (herself for appointments and official mail, Fiona for money, Hugo for health and sport, Ian for notes to self, an AI-collection skill for AI posts); Ian places, Onyx links, and a thread is archived only once its fact is verifiably in Notion. Use it for /inbox-sweep, "clean up my inbox", "process my mail" or "inbox zero", in whatever language it is asked.
---

# /inbox-sweep: the inbox into the Notion hub, then archived

**Astrid (02-10, Personal Assistant) owns this skill.** She reads every thread, picks the specialist who
processes it, and archives only once it is in Notion. The material runs the chain *placing in the
hub*: the specialist delivers it, Ian (04-03) places it and Onyx (04-04) lays the links. She works
directly in Notion, Google Calendar and Gmail, with no branch or PR: content in Notion is visible and
reversible at once (#4206).

## 0. Read the settings first

Everything personal lives in the owner's private Notion, never in this public plugin. Search Notion for
the page titled **Instellingen inbox-sweep** and read it before anything else. It names:

- the **owner**, and how to tell the owner's **private Gmail** from a work account (the recipient
  address a thread must carry);
- the **hub page**, and the page with the hub's **conventions**, to read before writing;
- the **Dossiers** data source, the **Agenda** data source with a **view** that shows every row, and
  the **task** data source with the values a new task card gets (its type and its inbox priority);
- the Gmail **labels**: the one a processed thread gets, and the one for a thread that waits on the
  owner's decision;
- where **AI posts** go: the AI dossier, and the skill that collects them, if the consumer has one;
- the **language** rows, notes and the report are written in;
- the **order** the inbox is processed in, if the owner keeps one (otherwise the default in step 1).

**No settings page, or no Gmail, Google Calendar or Notion connector: stop and say so in one line.**
Never guess a database. **Is the Gmail account not the private one** the settings name: stop and say so.

**Compare a Gmail address the way Gmail delivers to it, not letter for letter** (#4482). For
`gmail.com` and `googlemail.com` alike, lowercase the address, drop a `+tag` after the local part, drop
every dot in the local part, and read `googlemail.com` as `gmail.com`: `First.Last+news@googlemail.com`
and `firstlast@gmail.com` are one mailbox. Any other domain is compared literally, lowercase only, since
a dot there can name a different person. So the settings page needs one spelling of the address.
Measured in an inbox sweep, November 25, 2026: mail to the dot-less spelling read as *not the private
account*, which would either stop the sweep or skip the owner's own threads.

**Google Calendar is the source for appointments.** An appointment from a mail goes into Google
Calendar first (the primary calendar) and only then into the Agenda as a row, with the Google event `id`
in the column **Google ID**. Check first whether it is already in Google (`list_events` around that
date): the owner adds most events on their phone, and an event belongs there once. If it is there, take
over its `id`. The rest is [`agenda-sync`](../agenda-sync/SKILL.md)'s. Fetch the Agenda in **view mode**
on the view the settings name, not in SQL or rows mode: those share an hourly quota.

## 1. Fetch

`search_threads` with `in:inbox`, `pageSize` 50 and `THREAD_VIEW_SUMMARY`; follow `nextPageToken` to
the end. Process **oldest first** by default; an order the settings page or the hub's conventions
name takes precedence over this default (#4483). Read a thread in full (`get_thread`, `PLAIN_TEXT`) only when the
snippet is not enough to decide. A thread is one unit: read every message in it.

Make sure both labels from the settings exist (`list_labels`, otherwise `create_label`). The decision
label is named like the GitHub label `awaiting-decision` on purpose: the same notion, the same name.

**Start with what was already waiting on the owner.** A thread carrying the decision label on which the
owner has since said something (in the conversation, or with a reply of their own in the thread) is now
processed as they decided, and the label comes off. Without a new decision it stays.

## 2. Sort: one kind per thread, with a fixed specialist

| Kind | Recognised by | Specialist | Destination in Notion |
|---|---|---|---|
| Appointment or date | An appointment, a move, an event, a concert ticket, a drinks evening | Astrid | **Google Calendar first**, then an **Agenda** row (Wat, Datum with time, Notitie with place and source) |
| Action for the owner | Something to fill in, sign up for, pay or return, with or without a deadline | Astrid | A card in the **task** data source (the type and inbox priority from the settings, a deadline if there is one, a dossier if one fits) |
| Official document | Policy, government, contract, terms, annual statement | Astrid (+ Fiona for amounts) | The dossier of that subject |
| Money | Invoice, premium, hours, subscription, refund | Fiona | The dossier of that subject (amount, period, counterparty) |
| Health, sport, habits | Sports club, training, nutrition, sleep | Hugo | The dossier of that subject. A medical **appointment** is Astrid's |
| Note to self | Sender and recipient are both the owner | Ian | The dossier the note is about |
| Post about AI or Claude | A newsletter, tip or link about Claude or AI | the AI-collection skill from the settings, otherwise Ian | The AI dossier |
| Nothing lasting | Advertising, a newsletter, a shipping or order confirmation without a date or money that still counts later | nobody | Nothing |

**A task card's deadline and SMART fields are the mail's or the owner's, never the sweep's** (#4399, the
rule in [Ian's manual](../../manuals/specialist-04-03-manual.md)): a date the thread states, or nothing,
and SMART answers only where the thread or the owner gives them. An empty field is correct; a derived
one is not.

A thread can carry two kinds (a sports club: a drinks evening **and** a sign-up). Process each part to
its own destination; the thread is archived only once every part stands.

**An order confirmation with a delivery still under way** (track & trace) stays in the inbox until the
delivery is over. After that it is *nothing lasting*.

## 3. Place: search first, then write

1. **Search whether it is already there** (`notion-search` on the subject, the sender, the order number
   or the date). If it is, add to what stands instead of making a second one, **at the top of the
   heading it belongs to, never appended at the bottom** -- newest first, Ian's rule (#4379). An
   Agenda row with the same Wat and Datum is the same appointment.
2. **Ian picks the place**: an existing dossier (its parent and child relations give the hierarchy), or
   a new dossier when none fits. A new dossier follows the format of the dossiers beside it.
3. **Write facts, not a copy of the mail**: what, when, how much, with whom, and what the owner has to
   do. End with a source line, `Bron: mail van <sender>, <date>` (in the language the settings name),
   with the thread's `viewUrl`. Attachments are not copied; name them in the source line. Where a
   source line lists several mails, the newest comes first. A fact from a mail goes into its dossier
   (or the hub's updates store) on its own: no task card has to exist first (#4468, Ian's manual).
   **On a task card, the facts and the source lines go in the card's page body, never in its short text
   property** (#4497, Ian's manual). That property holds one line: what the owner has to do, or the one
   fact needed to do it. A follow-up mail about the same card goes at the top of the page body, not in
   the property. Measured in a consumer hub: after two mails the property held a paragraph with two source
   lines and two raw URLs, unreadable on the board.
4. **Onyx lays the links** for a new dossier: strong and weak links, with the explanation where the
   conventions page says. No orphan neuron.

## 4. Verify, then archive

**A thread is archived only once its fact is verifiably in Notion.**

1. Fetch every page or row written with `notion-fetch` again, and check that the fact and the source
   line are on it. A dossier page written in this sweep is then recounted with
   [`dossier-wordcount`](../dossier-wordcount/SKILL.md) (mode 1, once per page after its last write),
   and a page over the split threshold is named in the report.
2. If it holds: `label_thread` with the processed label, then `unlabel_thread` with `INBOX`. For
   *nothing lasting* the second step is enough, without the label.
3. If it does not hold, or the write failed: the thread stays in the inbox.

**Doubt gets the decision label**, like an issue on GitHub. If the specialist is not sure what should
happen with the information, or the thread holds something the owner has to judge (advice, a purchase
decision, a personal message from somebody), nothing is written. The thread stays in the inbox with that
label, and the report asks per thread the one question that settles it, with a recommended answer. The
owner answers when it suits them; the next sweep picks it up.

## Hard limits

- **Never** delete a thread, mark it as spam, reply to it or forward it. Archiving is the only thing this
  skill does in Gmail, and it is reversible through the processed label.
- **Never delete anything in Notion or Google Calendar.**
- **Never touch the git checkout**: no branch, commit, push or PR. The content lives in Notion.

## 5. Report

Short, in this shape, in the language the settings name:

- a table with per thread: subject, specialist, the Notion link (or `-`), and `archived`,
  `stays: <reason>` or `waits on a decision: <the question>`;
- one line with the count per specialist, the number of threads that stayed, and the run time of the
  whole sweep (start and end time).
