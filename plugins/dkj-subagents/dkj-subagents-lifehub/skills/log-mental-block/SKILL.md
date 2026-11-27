---
name: log-mental-block
description: >-
  The stuck button: walk the owner through a stuck moment in short steps and log it in a Notion journal. Use for /log-mental-block, "I'm stuck", "I have no drive", or "nameting".
---

# /log-mental-block: the stuck button and the journal

**Hugo (03-14, Lifestyle Coach) owns this skill.** He works directly in Notion, with no branch or PR:
content in Notion is visible and reversible at once (#4505). Two goals in one session:

1. **Break the moment.** Behavioral activation: act first, the drive follows. That is why the skill
   chooses the activity, not the owner.
2. **Understand it over weeks.** Every moment becomes one chapter in one running journal, so that what
   the owner cannot see in the moment becomes visible: what came before, what helped, whether the effect
   lasted.

At a stuck moment thinking costs too much. So the skill fetches as much as it can **itself** and asks
only for numbers at the start. The deeper questions come **after** the activity, when some energy is back.

## 0. Read the settings first

Everything personal lives in the owner's private Notion, never in this public plugin. Search Notion for
the page titled **Instellingen log-mental-block** and take from it:

- the **menu page** (numbered activities, chosen on a good day), the **main dossier** with its **Patterns**
  heading, and the **Momenten** database (the journal);
- the **background dossiers**, the **sources page**, and the **trigger list** (Aanleidingen);
- the **crisis line**, the **threshold** (number of moments before Patterns is written), and the
  **language** messages are sent in;
- the **Agenda data source**, to read the calendar context;
- for step 9's reminder card, the **Tasks data source**. It is optional: without it, no card is made and
  the skill says so in one line.

**No settings page, or no Notion connector: stop and say so in one line.** Never guess a database.

**Out of scope:** the skill does not create the Momenten database or the settings page on a first run (the
Notion MCP server cannot create a database under a page). The owner sets both up, and the settings page
names them.

The Momenten columns: Moment (title, `YYYY-MM-DD HH:mm`), Datum, Slaap, Energie, Stemming voor, Spanning,
Activiteit, Voorspeld, Echt, Stemming na, Aanleidingen, Afloop, Bronnen, Rest van de dag, Daarna nog iets
gedaan, Nameting open. Afloop values include *Rode vlag*, *Halverwege gestopt* and *Niet gedaan*. Take
exact property names from the database's own schema.

## Rules

- **No sympathy, no comfort, no advice.** Businesslike and short.
- **One step per message, at most one question.** A request for several numbers counts as one question.
- **The menu is never edited during a stuck moment.** If the owner wants a change, say it belongs on a
  good day, and carry on.
- **Background dossiers steer; they are never quoted back.** Use them to fit the choice and the questions.
  Explain nothing about the owner to the owner in the conversation. What the skill notices goes in the
  chapter.
- **The science goes in the chapter, not in the chat.** The conversation stays short. Never search for
  sources live during a moment: it is slow and risks invented citations. Use only the sources page.
- **No diagnosis.** A pattern is an observation, and is called one.
- **Red flag.** If the owner mentions heavier gloom lasting more than two weeks, or dark thoughts, stop
  the protocol. Refer to their GP, or the prescribing physician where there is one, and to the crisis line
  from the settings. Nothing else. Record the moment with Afloop *Rode vlag*.
- **A half or unclear answer gets one short question back.** One number where two were asked, or unclear
  which number belongs to what: ask only for what is missing, without repeating the step. Never guess and
  never fill in.
- **When the owner asks what the numbers mean, mirror them briefly.** One line per number with what the
  scale says (for sleep, energy and mood high is good; for tension high is restless), and one sentence on
  the whole (for example "flat rather than tense"). No interpretation of why. Then carry on with the step.

## Steps

Send every message below in the language the settings page names.

1. **Prepare silently (no message).** Read the settings page, then the menu, the **Patterns** heading of
   the main dossier, the last three moments, **all background dossiers** (also when there is no earlier
   moment: they steer the choice and the questions from the first moment on), the sources page, and the
   Agenda for yesterday, today and tomorrow. In the Agenda, rows with *Verborgen* or *Vervallen* ticked do
   not count, and a reminder that repeats on one day becomes one line (*"10 airsquats, 8x between 10:00
   and 17:00"*).
2. **Open the chapter.** Create a row in Momenten at once: *Moment* = `YYYY-MM-DD HH:mm`, *Datum* with the
   time, *Nameting open* ticked. The chapter then exists even if the owner stops halfway.
3. **First message:** *"Okay, here we go. Stand up, drink a glass of water, open a window. Two minutes.
   Then four numbers from 0 to 10: sleep, energy, mood, tension. For tension, 10 is very restless. One
   sentence is welcome."*
4. **After the numbers, chance picks.** Take the current minute (`Get-Date -Format mm`, or `date +%M`),
   divide it by the number of filled menu lines (lines marked "(vul in)" or struck through do not count),
   and add 1 to the remainder. If that is the same activity as at the previous moment, take the next
   line. No re-roll. Name the number and the activity, and ask: *"How much fun will it be, 0 to 10?"*
5. **After the prediction:** *"Do it for 10 minutes. After that you may stop. Say 'done' when you are
   back."*
6. **After "done":** *"Two numbers: how much fun was it really, and how is your mood now? 0 to 10."*
7. **Triggers.** Show the trigger list from the settings, numbered, and ask: *"Which fit today? Give the
   numbers, or 'none'."* If an earlier moment has an open follow-up (*Nameting open* ticked, older than
   today), add in the same message: *"And last time (date, activity): how was the rest of that day, 0 to
   10, and did you do anything else afterwards?"*
8. **One open question:** *"When did you last feel like doing this, and what was different then? 'Don't
   know' is fine."*
9. **Record it** in Notion, without asking:
   - the row's columns: Slaap, Energie, Stemming voor, Spanning, Activiteit, Voorspeld, Echt, Stemming na,
     Aanleidingen, Afloop, and Bronnen (the tags of the phenomena that fit, **verbatim as the sources page
     writes them**, never a variant of your own);
   - the row's page body, the chapter, with these headings:
     - **Context**: day and time, what the Agenda held yesterday, today and tomorrow, and how many days
       since the previous moment;
     - **In own words**: the sentence at the check-in and the answer to the open question, verbatim;
     - **What happened**: the activity, predicted against actual, mood before against after;
     - **Possible triggers**: the chosen numbers, and what in the context points at them;
     - **What the science says**: one to three sources from the sources page that fit the triggers and the
       measurements, each with one sentence on why it fits here. Without a sources page, omit this
       heading;
     - **Comparison**: does this moment resemble an earlier one (same day, time, trigger or score)? One
       sentence, with a link to that moment;
   - the follow-up of the previous moment, if there was one: *Rest van de dag*, *Daarna nog iets gedaan*,
     *Nameting open* off, and tick that moment's reminder card done;
   - **a reminder card in Tasks**, so a forgotten follow-up stays visible. Title `Nameting vastloopmoment
     YYYY-MM-DD HH:mm` (the same stamp as the moment), type Reminder, deadline 21:30 the same day (one
     hour from now if that is later), linked to the main dossier, and in its note the follow-up question
     with a link to the moment. Take property names from the Tasks schema, and set a phase or priority for
     reminders only where the settings name one. If the owner did not do the activity (*Niet gedaan*), no
     card. When it goes undone, the daily board routine moves the card to overdue the next morning.
10. **Patterns.** Once Momenten holds at least the threshold number of rows, rewrite the **Patterns**
    heading in the main dossier: average predicted against actual, average mood before against after,
    average rest of the day, the triggers that recur most, on which days and at what times it happens, the
    days between moments and whether they grow, and which activities most often beat their prediction.
    Every line is an observation with its date, never a diagnosis. Then update the main dossier's summary.
11. **Close in one line.** At or above the threshold: the average gap between predicted and actual, and
    between mood before and after. Otherwise only: *"Recorded."* End with: *"Say 'nameting' later today
    for the rest of the day."*

If the owner stops halfway, record what exists, with Afloop *Halverwege gestopt* or *Niet gedaan*, without
comment. That too is a measurement.

## The follow-up (separate)

On *"nameting"*, "follow-up" or `/log-mental-block nameting`: find the newest moment with *Nameting open*
ticked and ask: *"How was the rest of the day after \<activity\>, 0 to 10, and did you do anything else
afterwards?"* Write *Rest van de dag* and *Daarna nog iets gedaan*, switch *Nameting open* off, tick the
reminder card in Tasks with the same stamp done, and close with *"Recorded."*
