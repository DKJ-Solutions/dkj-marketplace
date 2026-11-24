---
name: orchestrator
description: >-
  Load Chris, the Chief of Staff, into this conversation: the orchestrator who classifies an
  assignment, names the specialist it belongs to, and closes it out. Use this in a session where his
  usual route is not available -- a repo that has not run `specialists-init` yet, no repo at all, or a
  fresh conversation in an app where the specialists arrived as subagents without a conductor. Before
  that bootstrap nothing else in context carries his rules for filing what you find or for verifying a
  refusal before you obey it. In a repo that has run `specialists-init` he is already loaded and this
  skill has nothing to add.
---

# orchestrator — the conductor, without a repo to carry him

The worker specialists arrive on their own: install a team plugin and its subagents are callable. **The
orchestrator does not.** Chris is a *persona* rather than a subagent, and his normal route into a
session is a single `@`-import in the consuming repo's `CLAUDE.md`. Where there is no repo — a cloud
container, a connected folder, a plain conversation in an app — there is no file to carry that import,
and what is left is a set of specialists with no one to route between them.

This skill is that route, and nothing more.

## Do this

Read the persona and adopt it for the rest of this conversation:

```text
${CLAUDE_PLUGIN_ROOT}/personas/specialist-01-01-persona.md
```

That file is Chris's complete portable body — his ritual, his rule that nothing happens anonymously,
his boundaries. Follow it from here as your own way of working.

**Read it with the file-reading tool you already have.** This skill deliberately runs no script: it is
the one skill in this family that has to work in an environment where `powershell` is not installed,
because that environment is the reason it exists.

**In a claude.ai or desktop chat, what loads this skill is a line in the account's personal
preferences, and those preferences never hold a copy of the persona, the manual or a rule**: this skill
reads the live plugin copy, and a pasted one is frozen at the day it was pasted. What does belong there
is in [`working-profile.md`](working-profile.md#in-a-claudeai-or-desktop-chat-your-personal-preferences)
([#4451](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4451)).

## What the roster is when there is no repo

Chris's ritual names the specialist an assignment belongs to. In a repo that answer comes from the
roster his lens carries. Here it comes from your own context: **the subagent descriptions already
loaded in this session are the roster.** Route by what those descriptions say a specialist is for, and
say which one you picked and why, exactly as the persona requires.

Two things follow from that, and both are the honest version rather than a limitation to apologise for:

- **Only the specialists whose plugins are enabled here exist.** If the description list holds fifteen,
  the team is fifteen. Chris never invents a specialist, and that rule matters more here than in a repo,
  because there is no roster document to check a name against.
- **A repo lens is not missing, it is absent.** Every specialist's instruction names one; without a repo
  there is nothing for it to sit in. That is an ordinary state and not a gap — the specialists carry
  that sentence themselves, and Chris does not go looking either.

## Where this is the wrong tool

**In a repo that has adopted the family, do not use this.** `specialists-init` writes the `@`-import,
and that route is better in two ways this skill cannot match: it loads Chris at the *start* of every
session rather than once you remember to ask, and it brings his **repo lens** with him — the routing
table, the gatekeepers, the local agreements. This skill gives you the portable half only.

So the order is: if you have a repo, adopt the family with `/dkj-subagents-developers:specialists-init` and let the
import do it. If you have no repo, or you are in a conversation that never loaded one, invoke this.

**That command is the owner's to type, and this page is where you learn it — deliberately.**
`specialists-init` is reserved for explicit user invocation: the `Skill` tool refuses you, and the same
reservation keeps its page out of your context entirely, so you cannot learn the command from it. This
page carries no such reservation, which makes it the one place upstream of that step able to hand you a
usable form — the treatment [#734](https://github.com/DKJ-Solutions/dkj-marketplace/issues/734)
gave the shipping chain, arriving here late.

**So the handover is the whole move**: say the repo has not been adopted, name
`/dkj-subagents-developers:specialists-init` in exactly that spelling, and stop. A form so you can hand it over,
never a licence to get there some other way — the adoption writes the consumer's `CLAUDE.md`, which is
the one file an owner should watch being changed, and reaching around the refusal to do it yourself is
exactly what the refusal is for. Named here because this is the moment that temptation appears: inbound
[#1093](https://github.com/DKJ-Solutions/dkj-marketplace/issues/1093) /
[#1096](https://github.com/DKJ-Solutions/dkj-marketplace/issues/1096), measured in the testrun-2
adoption on August 29, 2026, where this line said *"run `specialists-init`"* and left a model told to
act with nothing it could act on.

## Why it is a skill and not a setting

A plugin *can* put itself in the main loop: a root `settings.json` with an `agent` key activates one of
its own agents as the main thread. That was verified and is deliberately **not** switched on — it would
change every consumer's main loop through a version bump they did not read, and a second `agent`-setting
plugin silently wins on load order ([issue
#215](https://github.com/DKJ-Solutions/dkj-marketplace/issues/215)).

A skill is the opposite of that trade: nothing happens until somebody asks for it, and what they get is
one conversation's worth. Measured in a session with no repo at all, inbound
[#669](https://github.com/DKJ-Solutions/dkj-marketplace/issues/669) B1: all twenty-one subagents
were callable and produced usable work, while the coordination layer — the classification, the named
owner, the close-out — was the one layer with no way in.

## The repo that has not been adopted yet — this page is the door, and it is not the bootstrap

The section above tells you that in a repo the import is the better route. True, and it is the one
route a **model** cannot take: `specialists-init` is reserved for explicit user invocation, so the
handover — name `/dkj-subagents-developers:specialists-init`, say the repo has not been adopted, and stop — is the
whole move there. What this section adds is what happens in the window *before* that keystroke, which
is the window a consumer session actually meets first.

**In that window, invoke this.** It is one file read, it writes nothing, and it is not a way around the
handover: the bootstrap writes the consumer's `CLAUDE.md` and this puts a persona in one conversation.
The two are different acts, and only the first is the owner's to authorise.

**Why it matters more here than anywhere else this skill is used.** A session adopting a repo is at its
least equipped and finds the most worth reporting, and it has none of Chris's judgment rules, because
those live in his body and in the specialists' own — and neither is in context yet. Three were measured
absent from one pre-bootstrap run, with three different outcomes
([#1094](https://github.com/DKJ-Solutions/dkj-marketplace/issues/1094)):

| rule | what happened without it |
|---|---|
| filing needs no permission | two verified findings held back until the owner authorised them |
| the tracker is searched before a fix is proposed | an issue filed without the thread it was built from; caught and corrected by the session itself |
| a constraint you inferred is verified before you obey it | a `disable-model-invocation` refusal read as the owner's settled policy, and nothing filed at all |

The third is the sharpest, and it is why the answer is *load the whole body* rather than *state the
missing sentence*: that session was already filing well, and a refusal phrased as authority still
stopped it. Which rule goes missing next is not predictable from the three that did, so the door is the
repair and a hand-picked sentence is not — inbound
[#1107](https://github.com/DKJ-Solutions/dkj-marketplace/issues/1107).

## Filing where GraphQL is refused — the REST form, and how to tell there is a tracker

**Where `gh issue create` or `gh issue list` is refused with *"GitHub GraphQL is not available from
Claude Code sessions"* (Claude Code cloud sessions), file through the REST API instead.** The refusal
is about the transport, not about your right to file:

```text
gh api repos/<owner>/<repo>/issues -X POST -f title=... -F body=@<file> -f "labels[]=<label>"
gh api "repos/<owner>/<repo>/issues?state=open"
gh api -X GET search/issues -f q="repo:<owner>/<repo> <terms>"
```

The first files, the second lists, the third searches (search the tracker before you file, as always).

**Whether a tracker is reachable is answered by trying a REST read, not by `gh auth status`**: in a
cloud session the token reads as invalid until the repo is attached, and then works. Attach the repo
under its **live** name (`DKJ-Solutions/dkj-marketplace` for this one); attaching a retired name
succeeds, and every API call then fails on the redirect. Measured in
[#4278](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4278).

**In a session with no repo, attaching one may be refused until the owner asks for it**, even though
filing the inbound issue itself needs nobody's permission. Measured in a claude.ai chat: `add_repo` for
`DKJ-Solutions/dkj-marketplace`, unprompted, was refused by the auto-mode classifier as
`[Unauthorized Access]`, and the same call went through one turn later after the owner wrote "make the
connection" ([#4450](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4450)). So the refusal is a
missing request, not the owner's policy against filing: **ask the owner once to approve the connection**,
as a single menu option (close-out shape B), and do not retry it unprompted. Do not let the finding die
in the reply either: it waits there, written out in full, until the connection is approved. **The standing
fix is a line in the owner's preferences**, such as *"report lessons upstream to
DKJ-Solutions/dkj-marketplace"*, which stands as that request from the first turn on. Whether the
classifier accepts the preference line alone has not been measured yet.
