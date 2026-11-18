---
name: move-data-to-onedrive
description: >-
  Move app data a repo keeps in git into a OneDrive folder, with a fallback for machines without
  OneDrive and a per-machine migration plan. Use when asked to "move the data out of git", "put the
  data in OneDrive", or when every data edit ships as a branch + PR, or the data is public in a
  public repo, in whatever language. A procedure, no script; Cody, the app developer, carries it.
---

# move-data-to-onedrive -- app data out of git, into OneDrive

Data a repo keeps in git has two costs: every edit travels as a branch + PR, and in a public repo the
data is public. This is the procedure for moving the text data to OneDrive. It was measured in
DKJ-Solutions/dkj-music-library PR #175, which moved `data/library/export/*.ndjson` (about 12,500
tracks). Owner: Cody (#13); recorded in #4320.

## The folder convention

The data folder is `%OneDrive%\<org>\<repo>\<data-name>\`, for example
`%OneDrive%\dkj-solutions\dkj-music-library\library-export\`. One org folder, one folder per repo,
one folder per data set, so two repos never share a folder by accident.

## The procedure

### 1. Keep binary stores local; move only text

A SQLite database stays local: a synced SQLite file corrupts, because OneDrive copies it while it is
being written. What moves is the text export (NDJSON, JSON, CSV) the database is rebuilt from.

### 2. Resolve the folder in code, not in `.env.local`

One function in the repo's code resolves the data folder, in this order:

1. an explicit env-var override (named for the repo, for example `<REPO>_DATA_DIR`);
2. `%OneDrive%` -- try `OneDrive`, then `OneDriveConsumer`, then `OneDriveCommercial` -- plus the
   convention path above;
3. the old in-repo path, now git-ignored: the fallback for CI and for machines without OneDrive.

Do not put the path in `.env.local`. In a Next.js repo `.env.local` is read only by the dev server,
not by `tsx` scripts, so an env var placed there splits the dev server and the scripts across two
folders: one writes where the other never reads. Code that every caller imports cannot disagree
with itself.

### 3. Guard the tests

In the test setup, point the override at a temp folder. A test run on a machine with OneDrive would
otherwise resolve to the real folder, overwrite the real data, and OneDrive would propagate the
overwrite to every machine. Add a test that fails when the resolved folder is not the temp one.

### 4. Remove the data from git and ignore it

- `git rm` the data files and add the in-repo path to `.gitignore` (the fallback of step 2 still
  writes there on CI and on machines without OneDrive, and that must never be committed).
- Drop tooling that existed only to publish the data. In the measured repo that was a
  `library:publish` script and its docs; with the data out of git there is nothing to publish.
- Update the docs and the `README` to name the folder and the resolution order.

### 5. The migration plan, per machine

Write it into the PR body, in this order:

1. **First, on the machine that changed the data last.** Restore or commit any unpublished
   working-tree change to the data first, so the pull that removes the files does not refuse, then
   pull, then copy the data into the OneDrive folder.
2. **Then the other machines, only after OneDrive has synced the folder down.** Pulling first, with
   no folder yet, leaves the app running on the empty fallback. Check the folder is there and
   complete, then pull.
3. **Say plainly that the old data stays in the git history.** Removing a file from git does not
   remove it from history; in a public repo the earlier copies stay public. Data that must not be
   public needs a history rewrite, which is a separate, owner-approved act (force push).

### 6. Name the trade-offs

State both in the PR body, so the owner chooses knowing them:

- **One machine at a time.** OneDrive makes conflict copies when two machines write at once, and the
  last writer wins. The data has no merge step like git has.
- **OneDrive version history is the backup,** instead of git history. It is shorter and not
  reviewable as a diff.

## Important

- Moving data is a change in what the app reads at run time: run the repo's tests and start the app
  yourself with both paths (OneDrive present, and the override pointing at an empty folder) before
  the PR.
- Do not move a binary store, and do not merge the PR before the guard in step 3 is in place.
- This page is a procedure only; there is no script behind it, because the code in step 2 belongs to
  the repo and its language.
