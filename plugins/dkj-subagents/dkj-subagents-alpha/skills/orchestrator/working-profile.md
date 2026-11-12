# A working profile — how one person likes to work with the team

**A working profile is a fact about a person, not about a repo** ([#4006](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4006)).
It says what gives that person energy, what drains them, and how readily they want to be asked. Chris
reads it and shapes *how* the team works with them. It never shapes *what* the rules are.

## Where it lives: your own `~/.claude/CLAUDE.md`

Claude Code loads the user-level `~/.claude/CLAUDE.md` into every session, in every repo, on that
person's machine. So the profile goes there, as a section of that file, and nowhere else:

- **Not in a repo lens.** A lens belongs to one repo, so the same preferences would be copied into every
  repo and drift. That is the duplication the constitution exists to prevent.
- **Not a fact about "the owner" of a repo.** A repo can have two owners who work differently, and a lens can only state
  one of them. Each person writes their own profile, on their own machine.
- **Not in any repo at all.** Several repos are public, and a person's working profile is personal
  information. It stays in the person's home folder, and the team never quotes or paraphrases it into a
  repo file, a commit message, an issue or a pull request.

## What it can and cannot change

A profile tunes the **manner** of the work: how long a question is, who tests, how a result is shown,
and how readily a reversible choice is asked about rather than taken and reported.

It **never** loosens the constitution, the safety rules or a repo's own facts. The constitution, not the
profile, decides what counts as reversible. An irreversible or outward-facing act, and the owner's look
at a visible result before it merges, stay with the owner whatever a profile says, and a profile that
asks for less care there is ignored on that point. Where a profile and a rule disagree, the rule wins, and Chris says so
once instead of quietly working around it.

## The template

Copy this block into your `~/.claude/CLAUDE.md` and fill it in. Leave out a heading you have nothing to
say under: an absent heading means *no preference*, and the team's defaults apply. Write in whatever
language you like.

```markdown
## My working profile

**Who I am in this work.** <your role: owner, co-owner, client; what you build and why>

**What gives me energy.** <e.g. seeing a result right after a prompt and reacting to it; numbers and
charts that show where something is slow>

**What drains me.** <e.g. long rounds of questions; being asked to test things by hand>

**Decisions.** <how readily a session should stop for your choice. e.g. "take a reversible choice that
has a clear recommendation, and tell me which one you took" or "ask me about every design choice">

**Testing and checking.** <who checks what. e.g. "the team tests; show me the result to look at" or
"I want to click through every flow myself">

**How to show me a result.** <e.g. a link to the page to look at; a number against its target; a short
summary first, detail on request>

**Language.** <the language replies should be in, if it is not the language you write in>
```

## Why the decision dial is a field and not yet a setting

How readily a session stops for a decision is the first field a profile carries. Whether a *setting*
behind it is worth building depends on a measurement of how often the recommended option is simply
picked ([#4005](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4005)). Until then the
**Decisions** line is read as prose, within the rule that approval questions are rare, and it never
reaches an irreversible or outward-facing act.
