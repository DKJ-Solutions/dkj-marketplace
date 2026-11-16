---
name: bwj-release-prep
description: The BWJ Friday release prep -- stage the Monday store release in this store repo, read-only, and report what needs attention before the weekend.
schedule: Weekly, Friday 14:07
cron: 7 14 * * 5
folder: the store repo's checkout (one task per store repo)
requires: bwj-development
---

Stage this week's store release in this repo, read-only. This is the preparation for Monday's release,
not the release itself: never push to the store, cut, tag, commit, open a pull request, or write the
live authorisation marker. A release is cut only on a person's explicit request.

1. **Find where the checkout stands.** Run `git status --short` and `git branch --show-current`, and
   read the trunk from `scripts/repo-config.ps1`'s `Get-TrunkBranchName` (default `main`).
   - On the trunk and clean: run `git fetch origin` and `git merge --ff-only`, then work in the checkout.
   - On another branch, or with uncommitted changes: leave the checkout exactly as it is. Run
     `git fetch origin`, create a throwaway worktree with
     `git worktree add --detach "<temp>/bwj-release-prep-<repo>-<yyyyMMdd>" origin/<trunk>`, and run
     step 2 there with `-RootOverride <that worktree>`. Remove it afterwards with
     `git worktree remove --force <that worktree>`, even when step 2 fails.

2. **Run the prepare-release skill's script** (`bwj-development:prepare-release`), as its page says,
   writing the runbook outside the repo:

   ```powershell
   -OutFile "$env:TEMP\bwj-release-prep-<repo>-<yyyyMMdd>.md"
   ```

   where `<repo>` is the repo folder's name and `<yyyyMMdd>` today's date. The Monday companion task
   (`bwj-release-prep-monday`) reads this file back, so keep the name exactly.

3. **Report, in at most ten lines:** the exit code (`0` nothing needs attention, `1` something does),
   each item the run flagged and the step that flagged it, every step it reported as skipped, the
   version the pending entries add up to, and the runbook file's full path. Report the facts the run
   printed and add no advice of your own.

Where the run cannot start (no `bwj-development` plugin in this repo, no `pwsh`/`powershell`, no `gh`
login), say which, and stop.
