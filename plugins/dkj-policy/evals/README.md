# dkj-policy evals -- do the key skills still fire?

**These cases prove one thing: that a skill still fires on the words people actually use for it.** The gates
measure structure and cost, not behaviour, and a skill's `description` is the only thing that decides
whether Claude picks it. Shorten one to save tokens and nothing else notices when it stops firing (#3896).

**They run by hand, never in CI** (decided on #3896, November 8, 2026). Every case is a real model call on
the credential of whoever runs it, and CI keeps its token for the review workflow (#3902).

## Run them

From the repo root:

```powershell
claude plugin eval plugins/dkj-policy --ablation none --no-publish --trust-plugin
```

- **`--no-publish` is required.** Without it the CLI publishes its HTML report to claude.ai, and this
  system publishes no Artifacts (the constitution, #3772). The report stays at
  `evals/results/<timestamp>/report.html`, which `.gitignore` keeps out of the tree.
- **`--ablation none`** skips the no-plugin baseline arm. The question here is "does it fire", which a
  baseline cannot answer, so the second arm would only double the cost.
- **`--runs 1`** for a quick look; the cases default to three runs, because skill choice is not
  deterministic.
- **`--case <glob>`** runs one case, for example after editing that skill's description.

Needs Claude Code 2.1.269 or later. Measured November 9, 2026: five cases, one run each, 5/5 passed.

**After a run, stop the Admin servers it left behind** until #3911 is repaired. The plugin's dev-preview
hook starts one per run inside the run's temp workspace, and it holds that directory open:

```powershell
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'claude-eval-' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
```

## The cases

Each case sends one prompt, allows only the `Skill` tool and three turns, and grades with a free
`tool_used` grader on `Skill`, so no judge model is paid for.

| Case | Prompt asks for | Passes when |
|---|---|---|
| `claim-issue-fires` | fixing an issue by number | `claim-issue` fires |
| `new-branch-fires` | starting a new piece of work | `new-branch` fires |
| `sync-trunk-fires` | syncing all repos | `sync-trunk` fires |
| `day-plan-fires` | planning the day | `day-plan` fires |
| `no-skill-on-a-plain-question` | a plain git question | no skill fires at all |

The last case is the other direction: a description widened until it catches everything shows up there.

**A failing `*-fires` case means the skill's `description` no longer matches the phrasing**, so repair
the description rather than the prompt. A new case is a directory with a `prompt.md` and a
`graders/skill-fired.md`, copied from one of these.
