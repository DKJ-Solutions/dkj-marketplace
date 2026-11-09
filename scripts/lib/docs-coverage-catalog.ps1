<#
.SYNOPSIS
    Every page of the Claude Code docs, for the Docs coverage overview (#3906): where it sits in the docs navigation
    and how this repo stands to it.

.DESCRIPTION
    WRITTEN IN ONE PASS, November 9, 2026, by a one-off import that is not kept: a later change edits a row here,
    and a full refresh is a new read and a new classification. The page list is llms.txt as read that day: Path is
    the page under /docs/en/, Section its ## heading, Group the nearest #### heading under it (empty where the page
    sits in none), and SectionPath and GroupPath the first page each opens on. Desc is the page's own one-line
    description there.

    Status is how this repo stands to the page, classified on the same day by reading the repo:
      Covered       the repo deliberately uses what the page describes; Evidence names the repo paths that show it
      Open          it would apply to a repo like this one, and the repo does not use it
      Not relevant  it does not apply here (another surface, enterprise administration, the Agent SDK, news, legal)
    Note says how, or why, in a sentence. An Open page also carries Advice (Adopt, Consider or Skip) and
    AdviceWhy: whether this repo should take it up and why, judged the same day against its rules and decisions.
    Every Covered and Open page carries Impact, 1 to 8: how important the feature is to this repo, the higher the
    more important (the owner, November 9, 2026), shown as Tier-1 to Tier-8. A Not relevant page carries none and
    shows N/A. It ranks a Covered page as well as an Open one, so the column sorts the whole table by what matters;
    it replaced the Potential score, 1 to 4, that Open pages carried before (the owner, November 9, 2026).
    A page an issue of its own covers is ALSO an item in
    Get-DocsCoverageItems, which carries that issue's live status beside this page's row.

    Pure ASCII (repo convention for .ps1): the import replaced typographic quotes and dashes.
#>

function Get-DocsCoverageCatalog {
    @(
        @{ Path = 'overview'; Title = 'Overview'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Getting started'; GroupPath = 'overview'
           Status = 'Not relevant'; Note = 'General product overview with no feature of its own to adopt.'; Evidence = @()
           Desc = 'Claude Code is an agentic coding tool that reads your codebase, edits files, runs commands, and integrates with your development tools. Available in your terminal, IDE, desktop app, and browser.' }
        @{ Path = 'quickstart'; Title = 'Quickstart'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Getting started'; GroupPath = 'overview'
           Status = 'Not relevant'; Note = 'Install and first-use tutorial; nothing to adopt.'; Evidence = @()
           Desc = 'Install Claude Code in your terminal, sign in, and use the CLI to explore your codebase and make your first code change.' }
        @{ Path = 'changelog'; Title = 'Claude Code changelog'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Getting started'; GroupPath = 'overview'
           Status = 'Not relevant'; Note = 'Release notes page, not a feature.'; Evidence = @()
           Desc = 'Release notes for Claude Code, including new features, improvements, and bug fixes by version.' }
        @{ Path = 'how-claude-code-works'; Title = 'How Claude Code works'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Core concepts'; GroupPath = 'how-claude-code-works'
           Status = 'Not relevant'; Note = 'Concept page about the agentic loop; no feature to adopt.'; Evidence = @()
           Desc = 'Understand the agentic loop, built-in tools, and how Claude Code interacts with your project.' }
        @{ Path = 'features-overview'; Title = 'Extend Claude Code'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Core concepts'; GroupPath = 'how-claude-code-works'
           Status = 'Covered'; Impact = 6; Note = 'Repo uses CLAUDE.md, skills, subagents, hooks and plugins together, as a plugin marketplace that also consumes itself.'; Evidence = @('CLAUDE.md', '.claude/settings.json', 'plugins', '.claude/specialists')
           Desc = 'Understand when to use CLAUDE.md, Skills, subagents, hooks, MCP, and plugins.' }
        @{ Path = 'claude-directory'; Title = 'Explore the .claude directory'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Core concepts'; GroupPath = 'how-claude-code-works'
           Status = 'Covered'; Impact = 5; Note = 'Repo keeps settings.json, rules, and specialists lenses in its .claude directory.'; Evidence = @('.claude/settings.json', '.claude/rules/this-repo.md', '.claude/specialists')
           Desc = 'Where Claude Code reads CLAUDE.md, settings.json, hooks, skills, commands, subagents, workflows, rules, and auto memory. Explore the .claude directory in your project and ~/.claude in your home directory.' }
        @{ Path = 'context-window'; Title = 'Explore the context window'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Core concepts'; GroupPath = 'how-claude-code-works'
           Status = 'Not relevant'; Note = 'Interactive concept explainer with no feature to adopt.'; Evidence = @()
           Desc = 'An interactive simulation of how Claude Code''s context window fills during a session. See what loads automatically, what each file read costs, and when rules and hooks fire.' }
        @{ Path = 'prompt-caching'; Title = 'How Claude Code uses prompt caching'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Core concepts'; GroupPath = 'how-claude-code-works'
           Status = 'Not relevant'; Note = 'Explains automatic caching behaviour; no setting to adopt.'; Evidence = @()
           Desc = 'Claude Code manages prompt caching automatically. See why a model switch triggers a slow uncached turn, what `/compact` costs, why CLAUDE.md edits don''t apply mid-session, and how to check your cache hit rate.' }
        @{ Path = 'memory'; Title = 'How Claude remembers your project'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Use Claude Code'; GroupPath = 'memory'
           Status = 'Covered'; Impact = 8; Note = 'Root CLAUDE.md holds only @-imports of the constitution and specialists, plus unscoped and paths-scoped rules.'; Evidence = @('CLAUDE.md', '.claude/rules/this-repo.md', '.claude/rules/language-layers.md')
           Desc = 'Give Claude persistent instructions with CLAUDE.md or AGENTS.md files, and let Claude accumulate learnings automatically with auto memory.' }
        @{ Path = 'sessions'; Title = 'Manage sessions'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Use Claude Code'; GroupPath = 'memory'
           Status = 'Not relevant'; Note = 'Session resume and naming are user habits, with no repo config to adopt.'; Evidence = @()
           Desc = 'Name, resume, branch, and switch between Claude Code conversations. Covers `--continue`, `--resume`, `--from-pr`, the `/resume` picker, session naming, exporting transcripts, and where transcripts are stored.' }
        @{ Path = 'common-workflows'; Title = 'Common workflows'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Use Claude Code'; GroupPath = 'memory'
           Status = 'Not relevant'; Note = 'Generic how-to guide, no single feature.'; Evidence = @()
           Desc = 'Step-by-step guides for exploring codebases, fixing bugs, refactoring, testing, and other everyday tasks with Claude Code.' }
        @{ Path = 'prompt-library'; Title = 'Prompt library'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Use Claude Code'; GroupPath = 'memory'
           Status = 'Not relevant'; Note = 'Copy-paste prompt collection; no feature to adopt.'; Evidence = @()
           Desc = 'Copy-paste prompts for Claude Code, tagged by task and role.' }
        @{ Path = 'best-practices'; Title = 'Best practices for Claude Code'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Use Claude Code'; GroupPath = 'memory'
           Status = 'Not relevant'; Note = 'General guidance page with no feature of its own.'; Evidence = @()
           Desc = 'Get more out of Claude Code: tell Claude what it can''t see, give it a check to run, and enforce the rules that can''t have exceptions.' }
        @{ Path = 'platforms'; Title = 'Platforms and integrations'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Overview comparing surfaces; no feature to adopt.'; Evidence = @()
           Desc = 'Choose where to run Claude Code and what to connect it to. Compare the CLI, Desktop, VS Code, JetBrains, web, mobile, and integrations like Chrome, Slack, and CI/CD.' }
        @{ Path = 'remote-control'; Title = 'Continue local sessions from any device with Remote Control'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Open'; Impact = 2; Note = 'No Remote Control usage in repo config or docs.'; Evidence = @(); Advice = 'Consider'; AdviceWhy = 'Personal convenience for the owners, no repo change needed. Catch: it is a per-user setting, and the Claude app or web must reach a Windows session. Worth a try, not a repo rule.'
           Desc = 'Continue a local Claude Code session from your phone, tablet, or any browser using Remote Control. Works with claude.ai/code and the Claude mobile app.' }
        @{ Path = 'claude-projects'; Title = 'Let Claude coordinate ongoing work with Projects'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Cloud Projects product surface, not a CLI repo feature.'; Evidence = @()
           Desc = 'Hand Claude a stream of related tasks in one conversation and let it run them as parallel cloud sessions that share repositories, instructions, and memory.' }
        @{ Path = 'mobile'; Title = 'Claude Code on mobile'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Mobile app surface.'; Evidence = @()
           Desc = 'Start, monitor, and steer Claude Code tasks from your phone with the Claude app for iOS and Android.' }
        @{ Path = 'chrome'; Title = 'Use Claude Code with Chrome'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Browser integration surface; repo is a CLI plugin marketplace with no Chrome use.'; Evidence = @()
           Desc = 'Connect Claude Code to your Chrome browser to test web apps, debug with console logs, automate form filling, and extract data from web pages.' }
        @{ Path = 'computer-use'; Title = 'Let Claude use your computer from the CLI'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'macOS-only feature; owners are on Windows.'; Evidence = @()
           Desc = 'Enable computer use in the Claude Code CLI so Claude can open apps, click, type, and see your screen on macOS. Test native apps, debug visual issues, and automate GUI-only tools without leaving your terminal.' }
        @{ Path = 'vs-code'; Title = 'Use Claude Code in VS Code'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'IDE surface.'; Evidence = @()
           Desc = 'Install and configure the Claude Code extension for VS Code. Get AI coding assistance with inline diffs, @-mentions, plan review, and keyboard shortcuts.' }
        @{ Path = 'jetbrains'; Title = 'JetBrains IDEs'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'IDE surface.'; Evidence = @()
           Desc = 'Use Claude Code with JetBrains IDEs including IntelliJ, PyCharm, WebStorm, and more' }
        @{ Path = 'slack'; Title = 'Claude Code in Slack'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Slack surface.'; Evidence = @()
           Desc = 'Delegate coding tasks from Slack. This earlier version answers mentions only from Pro, Max, and Ultra accounts in workspaces not connected to Claude Tag.' }
        @{ Path = 'claude-tag'; Title = 'Claude Tag'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Slack product surface.'; Evidence = @()
           Desc = 'Bring Claude into your team''s Slack channels with Claude Tag and find its setup and usage documentation on claude.com.' }
        @{ Path = 'web-quickstart'; Title = 'Get started with Claude Code in the cloud'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Cloud web surface onboarding.'; Evidence = @()
           Desc = 'Run Claude Code in the cloud from your browser or phone. Connect a GitHub repository, submit a task, and review the PR without local setup.' }
        @{ Path = 'claude-code-on-the-web'; Title = 'Use Claude Code in the cloud'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Cloud/web surface.'; Evidence = @()
           Desc = 'Run Claude Code sessions in the cloud from your browser, phone, Desktop app, or terminal, move them with `--cloud` and `--teleport`, and auto-fix pull requests.' }
        @{ Path = 'routines'; Title = 'Automate work with scheduled tasks'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Open'; Impact = 1; Note = 'No cloud scheduled tasks or routines configured in the repo; CI uses GitHub cron workflows instead.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'GitHub cron workflows already schedule our recurring jobs. Cloud runs would draw on the shared subscription quota and need approval on first run, as with the declined workflows (#3900).'
           Desc = 'Put Claude Code on autopilot. Create scheduled tasks, formerly routines, that run in the cloud on a schedule, on API calls, or on GitHub events.' }
        @{ Path = 'desktop-quickstart'; Title = 'Get started with the desktop app'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Desktop app surface.'; Evidence = @()
           Desc = 'Install the Claude desktop app, open the Code tab, and start your first Claude Code session on a project folder on your computer.' }
        @{ Path = 'desktop'; Title = 'Desktop application'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Desktop app surface.'; Evidence = @()
           Desc = 'Get more out of Claude Code Desktop: parallel sessions with Git isolation, drag-and-drop pane layout, integrated terminal and file editor, side chats, computer use, Dispatch sessions from your phone, visual diff review, app previews, PR monitoring, connectors, and enterprise configuration.' }
        @{ Path = 'desktop-linux'; Title = 'Claude Desktop on Linux (beta)'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Desktop app on Linux; owners use Windows.'; Evidence = @()
           Desc = 'Install and update the Claude desktop app on Ubuntu and Debian' }
        @{ Path = 'desktop-wsl'; Title = 'Claude Code Desktop in WSL'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Desktop app surface.'; Evidence = @()
           Desc = 'Run Code sessions inside a WSL 2 distribution on Windows' }
        @{ Path = 'desktop-scheduled-tasks'; Title = 'Schedule recurring tasks in Claude Code Desktop'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'Desktop app feature.'; Evidence = @()
           Desc = 'Set up scheduled tasks in Claude Code Desktop to run Claude automatically on a recurring basis for daily code reviews, dependency audits, or morning briefings.' }
        @{ Path = 'desktop-ios-simulator'; Title = 'Test iOS apps in the simulator'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Platforms and integrations'; GroupPath = 'platforms'
           Status = 'Not relevant'; Note = 'iOS desktop feature, no apps here.'; Evidence = @()
           Desc = 'Claude Code Desktop opens your app in the iOS Simulator pane when Claude builds, runs, or checks it.' }
        @{ Path = 'code-review-local'; Title = 'Review locally with /code-review'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Open'; Impact = 2; Note = 'No repo-level adoption of local /code-review in config; it is only available as a built-in skill.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = '/code-review is already a built-in skill needing no config. It overlaps Victor''s pre-PR review chain and CI review, and would add quota use with no new gate.'
           Desc = 'Run `/code-review` in a Claude Code session to find bugs in your branch''s changes, point the review at a pull request or path, and have Claude apply the fixes.' }
        @{ Path = 'ultrareview'; Title = 'Find bugs with ultrareview'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Open'; Impact = 1; Note = 'No ultrareview usage or config found in the repo.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Cloud multi-agent review is costly and uses plan quota that CI review shares. The repo''s small PRs of scripts and docs do not justify it.'
           Desc = 'Run a deep, multi-agent code review in the cloud with /code-review ultra to find and verify bugs before you merge.' }
        @{ Path = 'github-enterprise-server'; Title = 'Claude Code with GitHub Enterprise Server'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Not relevant'; Note = 'Repo is on github.com, not GHES.'; Evidence = @()
           Desc = 'Connect Claude Code to your self-hosted GitHub Enterprise Server instance for cloud sessions, code review, and plugin marketplaces.' }
        @{ Path = 'code-review'; Title = 'Code Review'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Open'; Impact = 1; Note = 'Managed Code Review is not used; the repo runs the code-review plugin through claude-code-action instead.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Managed Code Review is for Team and Enterprise plans, and we are on subscription auth. The claude-code-action review already covers PRs.'
           Desc = 'Catch bugs in GitHub pull requests with Code Review: Claude reviews each change, verifies its findings, and comments inline. For Team and Enterprise plans' }
        @{ Path = 'code-review-setup'; Title = 'Set up Code Review'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Not relevant'; Note = 'Org-level admin setup of managed Code Review.'; Evidence = @()
           Desc = 'Turn on Code Review for your Claude organization: connect GitHub, install the Claude GitHub App, choose repositories, and set when reviews run' }
        @{ Path = 'code-review-customize'; Title = 'Customize Code Review'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Open'; Impact = 1; Note = 'No REVIEW.md in the repo to tune review severity or paths.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'REVIEW.md tunes the managed Code Review, which we do not use. Our CI review reads its own prompt and CLAUDE.md, so it would add an unused file.'
           Desc = 'Tune what Code Review flags on your pull requests with REVIEW.md and CLAUDE.md: recalibrate severity, skip paths, add checks, and see which copy applies.' }
        @{ Path = 'code-review-pull-requests'; Title = 'Read and request reviews on a pull request'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Not relevant'; Note = 'Reading findings of managed Code Review, which is not used.'; Evidence = @()
           Desc = 'Read Code Review findings on your GitHub pull request, respond to or dismiss them, and request a review with `@claude review`.' }
        @{ Path = 'code-review-costs'; Title = 'Code Review costs and usage'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Not relevant'; Note = 'Org billing for managed Code Review.'; Evidence = @()
           Desc = 'Estimate and cap what your organization spends on Claude Code Review: how reviews are billed through usage credits, what drives cost, and where to track usage.' }
        @{ Path = 'code-review-troubleshooting'; Title = 'Troubleshoot Code Review'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Not relevant'; Note = 'Troubleshooting for managed Code Review.'; Evidence = @()
           Desc = 'Fix a Code Review that didn''t start, failed, or was skipped for budget, find missing findings, and resolve setup and `REVIEW.md` problems.' }
        @{ Path = 'security-guidance'; Title = 'Catch security issues as Claude writes code'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Open'; Impact = 2; Note = 'security-guidance plugin is not enabled; security review is done by the Sebastian specialist.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Sebastian already reviews agent defs, hooks and scripts before merge. A per-edit security plugin would add always-on context and overlap, against the token budget gate.'
           Desc = 'Install the security-guidance plugin to have Claude review its own code changes for vulnerabilities and fix them in the same session.' }
        @{ Path = 'claude-security'; Title = 'Scan your codebase for vulnerabilities'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Open'; Impact = 1; Note = 'Claude Security plugin is not installed or enabled.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Duplicates Sebastian''s audits. The tree is mostly PowerShell, markdown and JSON, so a codebase vulnerability scan costs quota for little yield.'
           Desc = 'Install the Claude Security plugin to scan your codebase for vulnerabilities in a Claude Code session and turn findings into patches you review and apply.' }
        @{ Path = 'github-actions'; Title = 'Claude Code GitHub Actions'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Covered'; Impact = 6; Note = 'claude.yml answers @claude mentions and claude-code-review.yml runs the code-review plugin on PRs, both via claude-code-action pinned by SHA.'; Evidence = @('.github/workflows/claude.yml', '.github/workflows/claude-code-review.yml')
           Desc = 'Run Claude Code in GitHub Actions workflows to respond to @claude mentions, automate tasks, and turn issues into pull requests' }
        @{ Path = 'github-actions-cloud-providers'; Title = 'Use Claude Code GitHub Actions with cloud providers'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Not relevant'; Note = 'Bedrock, Vertex or Foundry setup; the repo uses the Claude API directly.'; Evidence = @()
           Desc = 'Run Claude Code GitHub Actions through Amazon Bedrock, Google Cloud''s Agent Platform, or Microsoft Foundry instead of the Claude API' }
        @{ Path = 'gitlab-ci-cd'; Title = 'Claude Code GitLab CI/CD'; Section = 'Getting started'; SectionPath = 'overview'; Group = 'Code review and pull requests'; GroupPath = 'code-review-local'
           Status = 'Not relevant'; Note = 'GitLab CI; the repo is on GitHub.'; Evidence = @()
           Desc = 'Learn about integrating Claude Code into your development workflow with GitLab CI/CD' }
        @{ Path = 'agents'; Title = 'Run agents in parallel'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Agents and parallel work'; GroupPath = 'agents'
           Status = 'Covered'; Impact = 6; Note = 'Parallel work is done with subagents and worktree lanes (worktree-lane and issues-sweep skills), not agent view or teams.'; Evidence = @('plugins/dkj-policy/skills/issues-sweep/SKILL.md', 'plugins/dkj-subagents/dkj-subagents-alpha/subagents/specialist-03-07-subagent.md')
           Desc = 'Compare the ways Claude Code can take on multiple tasks at once: subagents, agent view, agent teams, dynamic workflows, and projects.' }
        @{ Path = 'sub-agents'; Title = 'Create custom subagents'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Agents and parallel work'; GroupPath = 'agents'
           Status = 'Covered'; Impact = 8; Note = 'The core team ships 15 custom subagent definitions, one file per specialist.'; Evidence = @('plugins/dkj-subagents/dkj-subagents-alpha/subagents/specialist-03-07-subagent.md', 'plugins/dkj-subagents/dkj-subagents-alpha/subagents/specialist-06-19-subagent.md')
           Desc = 'Create and use specialized AI subagents in Claude Code for task-specific workflows and improved context management.' }
        @{ Path = 'agent-view'; Title = 'Manage multiple agents with agent view'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Agents and parallel work'; GroupPath = 'agents'
           Status = 'Open'; Impact = 4; Note = 'No use of agent view for dispatching or monitoring sessions found in the repo.'; Evidence = @(); Advice = 'Consider'; AdviceWhy = 'Both owners run parallel sessions and sweeps, so one screen showing which need input could help. It is a personal CLI feature, not repo config, and its Windows support is unverified.'
           Desc = 'Dispatch and manage many Claude Code sessions from one screen. Agent view shows what every session is doing and which ones need your input.' }
        @{ Path = 'agent-teams'; Title = 'Orchestrate teams of Claude Code sessions'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Agents and parallel work'; GroupPath = 'agents'
           Status = 'Open'; Impact = 1; Note = 'No agent teams configuration; the repo uses a persona and subagent roster instead.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Experimental and token-heavy, and it duplicates the Chris-led specialist roster. Parallel agents risk the quota shared with CI review.'
           Desc = 'Coordinate multiple Claude Code instances working together as a team, with shared tasks, inter-agent messaging, and centralized management.' }
        @{ Path = 'cross-session-messaging'; Title = 'Message your other Claude Code sessions'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Agents and parallel work'; GroupPath = 'agents'
           Status = 'Open'; Impact = 1; Note = 'No cross-session messaging set up; sessions are coordinated through issue claims on the tracker.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Session coordination already runs through issue claims on the tracker, which is auditable and works across machines. Messaging adds an untracked channel.'
           Desc = 'Let Claude list and message your other Claude Code sessions on this machine, and reach your sessions on other machines or in the cloud.' }
        @{ Path = 'workflows'; Title = 'Orchestrate subagents at scale with dynamic workflows'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Agents and parallel work'; GroupPath = 'agents'
           Status = 'Open'; Impact = 1; Note = 'No dynamic workflow scripts in the repo; a workflow-authoring skill exists only in the harness.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Plugin workflows were declined in #3900: off by default on Pro, opt-in, approval on first run. Nothing here needs script-driven subagent fan-out.'
           Desc = 'Dynamic workflows orchestrate many subagents from a script Claude writes and you can rerun. Use them for codebase audits, large migrations, and cross-checked research.' }
        @{ Path = 'worktrees'; Title = 'Run parallel sessions with worktrees'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Agents and parallel work'; GroupPath = 'agents'
           Status = 'Covered'; Impact = 6; Note = 'The repo has a worktree-lane skill, tidy-machine cleans stale lanes, and claim-issue handles worktrees.'; Evidence = @('plugins/dkj-policy/skills/worktree-lane', 'plugins/dkj-policy/scripts/lib/claim-issue-lib.ps1')
           Desc = 'Isolate parallel Claude Code sessions in separate git worktrees so changes don''t collide. Covers the `--worktree` flag, subagent isolation, `.worktreeinclude`, cleanup, and non-git VCS hooks.' }
        @{ Path = 'mcp-quickstart'; Title = 'Connect to MCP servers'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'MCP'; GroupPath = 'mcp-quickstart'
           Status = 'Open'; Impact = 1; Note = 'No .mcp.json or project MCP servers configured here.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'The gh CLI and the PowerShell scripts cover every tool need. An MCP server adds always-on tool context, which the token budget gate polices.'
           Desc = 'Add an MCP server to Claude Code, verify the connection, and find the configuration on disk.' }
        @{ Path = 'mcp'; Title = 'Connect Claude Code to tools via MCP'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'MCP'; GroupPath = 'mcp-quickstart'
           Status = 'Open'; Impact = 1; Note = 'No project MCP servers; MCP appears only as tool names in the CI review workflows.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'No tool here lacks a CLI route, and a plugin cannot ship permission rules for MCP tools. Always-on tool definitions would raise every session''s context cost.'
           Desc = 'Learn how to connect Claude Code to your tools with the Model Context Protocol.' }
        @{ Path = 'skills'; Title = 'Extend Claude with skills'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Skills'; GroupPath = 'skills'
           Status = 'Covered'; Impact = 8; Note = 'dkj-policy and dkj-solutions ship many skills, such as new-branch, claim-issue and tidy-machine.'; Evidence = @('plugins/dkj-policy/skills/issues-sweep/SKILL.md', 'plugins/dkj-policy/skills/plan-goal/SKILL.md')
           Desc = 'Create, manage, and share skills to extend Claude''s capabilities in Claude Code. Includes custom commands and bundled skills.' }
        @{ Path = 'artifacts'; Title = 'Share session output as artifacts'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Artifacts'; GroupPath = 'artifacts'
           Status = 'Open'; Impact = 1; Note = 'Deliberately avoided: the constitution forbids claude.ai Artifacts, pages become Admin pages instead.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Hard rule: no claude.ai Artifacts. Pages are local Admin pages, and this public repo''s output must not go to claude.ai links.'
           Desc = 'Artifacts turn Claude Code''s work into live, interactive pages on claude.ai that you can keep private, share with your organization, or publish to a public link.' }
        @{ Path = 'hooks-guide'; Title = 'Automate actions with hooks'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Automation'; GroupPath = 'hooks-guide'
           Status = 'Covered'; Impact = 7; Note = 'The dkj-policy plugin ships SessionStart and Stop hooks, and settings.json defines a statusLine command.'; Evidence = @('plugins/dkj-policy/hooks/hooks.json', '.claude/settings.json')
           Desc = 'Run shell commands automatically when Claude Code edits files, finishes tasks, or needs input. Format code, send notifications, validate commands, and enforce project rules.' }
        @{ Path = 'channels'; Title = 'Push events into a running session with channels'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Automation'; GroupPath = 'hooks-guide'
           Status = 'Open'; Impact = 1; Note = 'No channels or MCP push servers configured.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Pushing CI or webhook events into a session needs an MCP push server. GitHub-side labels, auto-merge and the closeout flow already handle CI results.'
           Desc = 'Use channels to push messages, alerts, and webhooks into your Claude Code session from an MCP server. Forward CI results, chat messages, and monitoring events so Claude can react while you''re away.' }
        @{ Path = 'scheduled-tasks'; Title = 'Run prompts on a schedule'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Automation'; GroupPath = 'hooks-guide'
           Status = 'Open'; Impact = 1; Note = 'No /loop or cron tasks configured in the repo itself; plan-goal mentions them only in skill text.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = '/loop and cron tasks are session-scoped and die with the session; merge-on-green sweeps, hooks and CI already cover repeated work, and polling burns the shared OAuth quota.'
           Desc = 'Use /loop and the cron scheduling tools to run prompts repeatedly, poll for status, or set one-time reminders within a Claude Code session.' }
        @{ Path = 'goal'; Title = 'Keep Claude working toward a goal'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Automation'; GroupPath = 'hooks-guide'
           Status = 'Open'; Impact = 2; Note = 'The /goal command is not used; the repo''s own plan-goal skill is a separate issue-planning feature.'; Evidence = @(); Advice = 'Consider'; AdviceWhy = '/goal could drive sweeps and long chains to a gate-green condition, but each turn adds a model check against the shared quota and it may clash with the three-line close-out and stop hooks.'
           Desc = 'Set a completion condition with /goal and Claude keeps working until it''s met, a model judges it impossible, or an error you have to fix clears the goal.' }
        @{ Path = 'headless'; Title = 'Run Claude Code programmatically'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Automation'; GroupPath = 'hooks-guide'
           Status = 'Covered'; Impact = 5; Note = 'The CI workflows run Claude Code non-interactively through the action with claude_args and allowedTools.'; Evidence = @('.github/workflows/claude.yml', '.github/workflows/claude-code-review.yml')
           Desc = 'Use the Agent SDK to run Claude Code programmatically from the CLI, Python, or TypeScript.' }
        @{ Path = 'deep-links'; Title = 'Launch sessions from links'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Automation'; GroupPath = 'hooks-guide'
           Status = 'Open'; Impact = 4; Note = 'No claude-cli:// deep links found in the repo.'; Evidence = @(); Advice = 'Consider'; AdviceWhy = 'A claude-cli:// link could open the right repo with a prompt from Admin pages, partly replacing the repo-session skill. The catch: the URL handler must be registered per Windows machine and the links are unverified.'
           Desc = 'Open a Claude Code terminal session from a URL. Embed `claude-cli://` links in runbooks, alerts, and dashboards so a click opens Claude Code in the right repo with the right prompt.' }
        @{ Path = 'large-codebases'; Title = 'Set up Claude Code in a monorepo or large codebase'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Guides'; GroupPath = 'large-codebases'
           Status = 'Open'; Impact = 1; Note = 'No nested CLAUDE.md or per-package monorepo setup; there is a single root CLAUDE.md of @-imports.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'This is not a monorepo; the import-only CLAUDE.md and the always-on budget gate already keep context small, and nested CLAUDE.md files would add always-on risk.'
           Desc = 'Configure Claude Code for monorepos and large single-tree codebases with nested CLAUDE.md files, sparse worktrees, code intelligence, and per-package skills so Claude stays focused on the code you''re working in.' }
        @{ Path = 'troubleshoot-install'; Title = 'Troubleshoot installation and login'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Troubleshooting'; GroupPath = 'troubleshoot-install'
           Status = 'Not relevant'; Note = 'Troubleshooting-only page for installation and login errors.'; Evidence = @()
           Desc = 'Fix command not found, PATH, permission, network, and authentication errors when installing or signing in to Claude Code.' }
        @{ Path = 'troubleshooting'; Title = 'Troubleshooting'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Troubleshooting'; GroupPath = 'troubleshoot-install'
           Status = 'Not relevant'; Note = 'Troubleshooting-only page for performance and hangs.'; Evidence = @()
           Desc = 'Fix high CPU or memory usage, hangs, auto-compact thrashing, and search problems in Claude Code, and find the right page for other issues.' }
        @{ Path = 'debug-your-config'; Title = 'Debug your configuration'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Troubleshooting'; GroupPath = 'troubleshoot-install'
           Status = 'Not relevant'; Note = 'Troubleshooting-only page on diagnosing config loading.'; Evidence = @()
           Desc = 'Diagnose why CLAUDE.md, settings, hooks, MCP servers, or skills aren''t taking effect. Use /context, /doctor, /hooks, and /mcp to see what actually loaded.' }
        @{ Path = 'errors'; Title = 'Error reference'; Section = 'Build with Claude Code'; SectionPath = 'agents'; Group = 'Troubleshooting'; GroupPath = 'troubleshoot-install'
           Status = 'Not relevant'; Note = 'Runtime error lookup reference, troubleshooting only.'; Evidence = @()
           Desc = 'Look up Claude Code runtime error messages with what each one means and how to fix it.' }
        @{ Path = 'plugins/overview'; Title = 'Plugins overview'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Plugins'; GroupPath = 'plugins/overview'
           Status = 'Covered'; Impact = 8; Note = 'The repo is a plugin marketplace whose plugins bundle agents, skills, hooks and scripts.'; Evidence = @('.claude-plugin/marketplace.json', 'plugins/dkj-policy/.claude-plugin/plugin.json')
           Desc = 'Understand what a Claude Code plugin is, when you need one instead of a standalone skill or MCP server, and which page to read to install or create one.' }
        @{ Path = 'plugins/install'; Title = 'Install and manage plugins'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Use plugins'; GroupPath = 'plugins/install'
           Status = 'Covered'; Impact = 6; Note = 'The repo enables its own plugins via enabledPlugins at project scope and ships update/version skills for them.'; Evidence = @('.claude/settings.json')
           Desc = 'Install Claude Code plugins from a marketplace on any surface you use, choose an install scope, and update or remove them later.' }
        @{ Path = 'plugins/anthropic-marketplaces'; Title = 'Anthropic''s marketplaces'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Use plugins'; GroupPath = 'plugins/install'
           Status = 'Not relevant'; Note = 'About Anthropic''s own official and community marketplaces, not this repo''s own marketplace.'; Evidence = @()
           Desc = 'Anthropic''s official and community plugin marketplaces for Claude Code: their names, repositories, how you add each, and where to browse their plugins.' }
        @{ Path = 'plugins/code-intelligence'; Title = 'Code intelligence plugins'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Use plugins'; GroupPath = 'plugins/install'
           Status = 'Open'; Impact = 1; Note = 'No LSP/language server plugin is shipped or enabled in this repo.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'The repo is PowerShell, Markdown and JSON, with no suitable LSP plugin; type-error feedback adds little, and a plugin per owner machine is upkeep.'
           Desc = 'Install a language server plugin so Claude sees type errors after edits and navigates code by symbol, and answer the LSP plugin recommendation dialog.' }
        @{ Path = 'plugins/security'; Title = 'Plugin security and trust'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Use plugins'; GroupPath = 'plugins/install'
           Status = 'Open'; Impact = 3; Note = 'No trust or review guidance is adopted from this page; security review is done by a specialist agent (Sebastian) instead.'; Evidence = @(); Advice = 'Consider'; AdviceWhy = 'Our marketplace is public and consumers install its hooks and scripts, so a short README link to this trust and review guide helps them. It does not replace Sebastian''s review, so do not duplicate it.'
           Desc = 'Decide whether to trust a plugin before you install it, from what a plugin can do on your machine to how to review one and remove it.' }
        @{ Path = 'plugins/create'; Title = 'Create a Claude Code plugin'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Create plugins'; GroupPath = 'plugins/create'
           Status = 'Covered'; Impact = 7; Note = 'Plugins are built with .claude-plugin/plugin.json, agents, skills and hooks, and the repo builds on this page''s layout.'; Evidence = @('plugins/dkj-policy/.claude-plugin/plugin.json', 'plugins/dkj-subagents/dkj-subagents-alpha/.claude-plugin/plugin.json')
           Desc = 'Build your first Claude Code plugin from an empty directory, test it without a marketplace, and convert an existing .claude/ setup.' }
        @{ Path = 'plugins/components'; Title = 'Add components to a plugin'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Create plugins'; GroupPath = 'plugins/create'
           Status = 'Covered'; Impact = 7; Note = 'Plugins ship skills, hooks (hooks/hooks.json) and agents as components.'; Evidence = @('plugins/dkj-policy/hooks', 'plugins/dkj-subagents/dkj-subagents-alpha')
           Desc = 'Add skills, hooks, MCP servers, and every other component type to a Claude Code plugin, with an example that validates for each.' }
        @{ Path = 'plugins/dependencies'; Title = 'Plugin dependencies'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Create plugins'; GroupPath = 'plugins/create'
           Status = 'Covered'; Impact = 5; Note = 'The dkj-solutions plugin declares dependencies: ["dkj-policy"] in its plugin.json.'; Evidence = @('plugins/dkj-policy/extensions/dkj-solutions/.claude-plugin/plugin.json')
           Desc = 'Declare the plugins your plugin depends on, with version ranges such as ^1.2, and see how Claude Code installs, resolves, and prunes them.' }
        @{ Path = 'plugin-evals'; Title = 'Test plugins with evals'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Create plugins'; GroupPath = 'plugins/create'
           Status = 'Covered'; Impact = 5; Note = 'dkj-policy ships claude plugin eval suites that prove its key skills still fire (#3896); they run locally, not as a CI gate.'; Evidence = @('plugins/dkj-policy/evals')
           Desc = 'Write eval cases for your Claude Code plugin, run them with claude plugin eval, grade the results, compare against a no-plugin baseline, and gate CI on the score.' }
        @{ Path = 'plugins/publish'; Title = 'Publish and distribute a plugin'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Create plugins'; GroupPath = 'plugins/create'
           Status = 'Covered'; Impact = 7; Note = 'The repo publishes plugins through its own public marketplace, with lockstep versions and a release cut script.'; Evidence = @('.claude-plugin/marketplace.json')
           Desc = 'Publish a Claude Code plugin through your own marketplace or Anthropic''s directory, with a pre-release checklist and how users get updates.' }
        @{ Path = 'plugins/measure'; Title = 'Measure plugin cost and usage'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Create plugins'; GroupPath = 'plugins/create'
           Status = 'Covered'; Impact = 5; Note = 'The measure-skill skill measures a plugin''s always-on and on-invoke token cost via claude plugin details.'; Evidence = @('plugins/dkj-policy/skills')
           Desc = 'Measure a Claude Code plugin''s token cost, find out whether people still use it, and pick the telemetry events for organization-wide plugin questions.' }
        @{ Path = 'plugins/cli-hints'; Title = 'Recommend your plugin from your CLI'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Create plugins'; GroupPath = 'plugins/create'
           Status = 'Not relevant'; Note = 'Applies to CLIs and SDKs recommending an official-marketplace plugin; this repo has no such CLI.'; Evidence = @()
           Desc = 'Prompt Claude Code users to install your official-marketplace plugin by emitting a claude-code-hint tag from your CLI or SDK.' }
        @{ Path = 'plugins/mods/overview'; Title = 'Mods overview'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Mods'; GroupPath = 'plugins/mods/overview'
           Status = 'Open'; Impact = 1; Note = 'No mods (hooks module, panes, commands) exist in any plugin here.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Mods add panes and commands to the interface; hooks, skills and local Admin pages already cover our needs. A new, unproven surface would widen a public plugin''s attack and upkeep footprint.'
           Desc = 'Add panes, commands, and tool call rules to Claude Code with a mod. See what a mod can do, how to make or install one, and where mods run.' }
        @{ Path = 'plugins/mods/create'; Title = 'Create a mod'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Mods'; GroupPath = 'plugins/mods/overview'
           Status = 'Open'; Impact = 1; Note = 'The repo has not created any mod.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'We have no mod use case; writing one would duplicate existing hooks and Admin pages, and the reload loop would be maintenance with no payoff.'
           Desc = 'Have Claude write a Claude Code mod from a description, or write one yourself that counts tool calls and adds a command. Learn the reload and validate loop.' }
        @{ Path = 'plugins/mods/reference'; Title = 'Mods reference'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Mods'; GroupPath = 'plugins/mods/overview'
           Status = 'Open'; Impact = 1; Note = 'No mods hooks module in the repo, so the reference is unused.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'The reference only matters if we build a mod, and we do not; our hooks use the ordinary hooks.json route, which is already tested here.'
           Desc = 'Complete reference for Claude Code mods: hooks module layout, events, mods API methods, render sites, elements by surface, limits, and settings.' }
        @{ Path = 'plugins/mods/interface'; Title = 'Draw in the interface with a mod'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Mods'; GroupPath = 'plugins/mods/overview'
           Status = 'Open'; Impact = 1; Note = 'No mod draws panes or bands in the interface.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Panes and a band above the prompt would duplicate Admin pages and status output; the owners judge visible results in Admin pages, so in-terminal drawing adds nothing.'
           Desc = 'Draw panes, a band above the prompt, buttons, and text fields from a Claude Code mod, handle presses and input, and keep state between redraws and sessions.' }
        @{ Path = 'plugins/mods/gallery'; Title = 'Interface gallery for mods'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Mods'; GroupPath = 'plugins/mods/overview'
           Status = 'Open'; Impact = 1; Note = 'No mod interface elements are used.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'The gallery of interface elements serves mod authors; we ship none, and our visual output follows the brand book on local Admin pages, not terminal widgets.'
           Desc = 'See the interface elements a Claude Code mod can draw, such as text, buttons, fields, Markdown, code, and diffs, with sample code and terminal screenshots.' }
        @{ Path = 'plugins/mods/events'; Title = 'React to events with a mod'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Mods'; GroupPath = 'plugins/mods/overview'
           Status = 'Open'; Impact = 1; Note = 'No mod handles Claude Code events; event handling is done with ordinary hooks.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Our event handling is ordinary PowerShell hooks, already tested by suites. Mod hooks would add a second event stack, and the if/async hook options were already declined (#3898).'
           Desc = 'Handle Claude Code events from a mod: observe, rewrite, or answer tool calls, prompts, and turns, filter which events a hook handles, and plan for other mods.' }
        @{ Path = 'plugins/mods/api'; Title = 'Use the mods API'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Mods'; GroupPath = 'plugins/mods/overview'
           Status = 'Open'; Impact = 1; Note = 'No mod uses the mods API.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Timers, model calls and cross-session messages would add quota use and complexity beyond our hook-and-script model; nothing here needs a mods API.'
           Desc = 'Call the mods API from a Claude Code mod to add commands and tools, call a model, run work on a timer, message other sessions, and reach files and the network.' }
        @{ Path = 'plugins/mods/test'; Title = 'Test a mod'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Mods'; GroupPath = 'plugins/mods/overview'
           Status = 'Open'; Impact = 1; Note = 'There are no mods to test.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'There are no mods to test; our own PowerShell test suites and gates already cover hooks and scripts.'
           Desc = 'Write automated tests for a Claude Code mod that fire events, stub Claude Code''s answers, and press buttons, with no session, sign-in, or network.' }
        @{ Path = 'plugins/mods/troubleshoot'; Title = 'Troubleshoot a mod'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Mods'; GroupPath = 'plugins/mods/overview'
           Status = 'Not relevant'; Note = 'Troubleshooting-only page for mods, which this repo does not use.'; Evidence = @()
           Desc = 'Find out why a Claude Code mod does nothing: match the symptom or message to its cause, look up refusal messages, and read the debug log.' }
        @{ Path = 'plugins/create-marketplace'; Title = 'Create a marketplace'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Run a marketplace'; GroupPath = 'plugins/create-marketplace'
           Status = 'Covered'; Impact = 7; Note = 'The repo is a marketplace built from a marketplace.json and tested locally by its own lint gate.'; Evidence = @('.claude-plugin/marketplace.json', 'scripts/lint/check-plugin-integrity.ps1')
           Desc = 'Build a plugin marketplace from a marketplace.json file and test it locally before you host it.' }
        @{ Path = 'plugins/host-marketplace'; Title = 'Host and maintain a marketplace'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Run a marketplace'; GroupPath = 'plugins/create-marketplace'
           Status = 'Covered'; Impact = 6; Note = 'The marketplace is hosted on a public GitHub repo, read without auth, and consumed through extraKnownMarketplaces.'; Evidence = @('.claude/settings.json', '.claude/rules/this-repo.md')
           Desc = 'Publish a plugin marketplace where users can reach it, grant access to a private one, and release updates and renames without breaking installs.' }
        @{ Path = 'plugins/relevance'; Title = 'Recommend plugins for your org'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Run a marketplace'; GroupPath = 'plugins/create-marketplace'
           Status = 'Open'; Impact = 4; Note = 'No relevance blocks in marketplace plugin entries and no managed-settings allowlist.'; Evidence = @(); Advice = 'Consider'; AdviceWhy = 'Relevance blocks could surface our plugins in consumer repos without manual setup, which suits a marketplace with several consumers. The catch: the managed-settings allowlist is org-level and not ours to set.'
           Desc = 'Add a relevance block to marketplace plugin entries so Claude Code suggests them when a user''s work matches, and allowlist the marketplace in managed settings.' }
        @{ Path = 'plugins/org'; Title = 'Manage Claude Code plugins for your organization'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Manage plugins for your organization'; GroupPath = 'plugins/org'
           Status = 'Not relevant'; Note = 'Organization-wide managed-settings control; this is a two-owner repo with no managed settings.'; Evidence = @()
           Desc = 'Control which plugins Claude Code installs and allows across your organization through managed settings.' }
        @{ Path = 'plugins/mods/admin'; Title = 'Manage mods for your organization'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Manage plugins for your organization'; GroupPath = 'plugins/org'
           Status = 'Not relevant'; Note = 'Organization administration of mods via managed settings.'; Evidence = @()
           Desc = 'Control Claude Code mods with managed settings: stop user-installed mods, allow only your own, review what a mod can do, and enforce policy with your own mod.' }
        @{ Path = 'plugins/troubleshooting'; Title = 'Troubleshoot plugins'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Troubleshooting'; GroupPath = 'plugins/troubleshooting'
           Status = 'Not relevant'; Note = 'Troubleshooting-only page.'; Evidence = @()
           Desc = 'Fix plugin errors in Claude Code. Find the exact message you saw, grouped by stage from where /plugin runs through install and org policy.' }
        @{ Path = 'plugins/loading'; Title = 'Plugin loading reference'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Troubleshooting'; GroupPath = 'plugins/troubleshooting'
           Status = 'Not relevant'; Note = 'Troubleshooting-oriented reference on how plugins load; the repo only documents its own update channels.'; Evidence = @()
           Desc = 'Trace where Claude Code loads each plugin from, which settings file decides whether it loads, and why an update changed nothing.' }
        @{ Path = 'plugins/manifest-reference'; Title = 'Plugin manifest reference'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Reference'; GroupPath = 'plugins/manifest-reference'
           Status = 'Covered'; Impact = 6; Note = 'Every plugin ships a plugin.json with name, version, description and dependencies, and the integrity gate checks them.'; Evidence = @('plugins/dkj-policy/.claude-plugin/plugin.json', 'plugins/dkj-policy/extensions/dkj-solutions/.claude-plugin/plugin.json', 'scripts/lint/check-plugin-integrity.ps1')
           Desc = 'Complete reference for plugin.json: every field with its type and default, accepted path forms, and the userConfig and environment variable schemas.' }
        @{ Path = 'plugins/marketplace-reference'; Title = 'Marketplace reference'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Reference'; GroupPath = 'plugins/manifest-reference'
           Status = 'Covered'; Impact = 6; Note = 'The repo''s marketplace.json lists the plugins and their sources, and the integrity check validates it.'; Evidence = @('.claude-plugin/marketplace.json', 'scripts/lint/check-plugin-integrity.ps1')
           Desc = 'Complete reference for marketplace.json fields, plugin entries, and the plugin and marketplace source objects, with where each is valid.' }
        @{ Path = 'plugins/cli-reference'; Title = 'Plugin commands reference'; Section = 'Plugins'; SectionPath = 'plugins/overview'; Group = 'Reference'; GroupPath = 'plugins/manifest-reference'
           Status = 'Covered'; Impact = 4; Note = 'Scripts and skills use claude plugin update, marketplace update and details, and the lint refers to claude plugin validate.'; Evidence = @('scripts/lint/check-plugin-integrity.ps1', 'plugins/dkj-policy/skills')
           Desc = 'Reference for the claude plugin shell commands, /plugin and /reload-plugins in a session, and the flags that load a plugin for one session.' }
        @{ Path = 'admin-setup'; Title = 'Set up Claude Code for your organization'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Setup and access'; GroupPath = 'admin-setup'
           Status = 'Not relevant'; Note = 'Org administrator decision map; this is not an enterprise deployment.'; Evidence = @()
           Desc = 'A decision map for administrators deploying Claude Code, covering API providers, managed settings, policy enforcement, usage monitoring, and data handling.' }
        @{ Path = 'setup'; Title = 'Advanced setup'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Setup and access'; GroupPath = 'admin-setup'
           Status = 'Not relevant'; Note = 'Installation and version management of the CLI, not a repo feature.'; Evidence = @()
           Desc = 'System requirements, platform-specific installation, version management, and uninstallation for Claude Code.' }
        @{ Path = 'authentication'; Title = 'Authentication'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Setup and access'; GroupPath = 'admin-setup'
           Status = 'Not relevant'; Note = 'Login and org authentication setup, not something a repo configures.'; Evidence = @()
           Desc = 'Log in to Claude Code and configure authentication for individuals, teams, and organizations.' }
        @{ Path = 'managed-settings'; Title = 'Deploy managed settings'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Setup and access'; GroupPath = 'admin-setup'
           Status = 'Not relevant'; Note = 'Enterprise managed settings deployment to developer machines.'; Evidence = @()
           Desc = 'Deploy managed settings to every developer''s machine: delivery mechanisms per OS, how Claude Code combines managed sources, and how to verify enforcement.' }
        @{ Path = 'server-managed-settings'; Title = 'Configure server-managed settings'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Setup and access'; GroupPath = 'admin-setup'
           Status = 'Not relevant'; Note = 'Server-delivered org settings, enterprise only.'; Evidence = @()
           Desc = 'Centrally configure Claude Code for your organization through server-delivered settings, without requiring device management infrastructure.' }
        @{ Path = 'managed-mcp'; Title = 'Control MCP server access for your organization'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Setup and access'; GroupPath = 'admin-setup'
           Status = 'Not relevant'; Note = 'Org-level MCP allowlists and denylists.'; Evidence = @()
           Desc = 'Restrict which MCP servers users can add or connect to, or provide servers to every user, with managed configuration files, managed settings, allowlists, and denylists.' }
        @{ Path = 'auto-mode-config'; Title = 'Configure auto mode'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Setup and access'; GroupPath = 'admin-setup'
           Status = 'Open'; Impact = 5; Note = 'Auto mode classifier trust config could apply to a team repo; none is set in settings.'; Evidence = @(); Advice = 'Consider'; AdviceWhy = 'A shared autoMode block in .claude/settings.json could stop repeated prompts in the branch-PR-merge flow. The catch: it needs a plan that offers auto mode, and a plugin cannot ship it.'
           Desc = 'Tell the auto mode classifier which repos, buckets, and domains your organization trusts. Set environment context, override the default block and allow rules, and inspect your effective config with the auto-mode CLI subcommands.' }
        @{ Path = 'third-party-integrations'; Title = 'Enterprise deployment overview'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Deployment'; GroupPath = 'third-party-integrations'
           Status = 'Not relevant'; Note = 'Enterprise deployment overview.'; Evidence = @()
           Desc = 'Learn how Claude Code can integrate with various third-party services and infrastructure to meet enterprise deployment requirements.' }
        @{ Path = 'feature-availability'; Title = 'Feature availability'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Deployment'; GroupPath = 'third-party-integrations'
           Status = 'Not relevant'; Note = 'Plan and cloud provider feature comparison.'; Evidence = @()
           Desc = 'Compare which Claude Code features are available across Anthropic subscription plans, the Anthropic Console, Amazon Bedrock, Claude Platform on AWS, Google Cloud''s Agent Platform, and Microsoft Foundry.' }
        @{ Path = 'amazon-bedrock'; Title = 'Claude Code on Amazon Bedrock'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Deployment'; GroupPath = 'third-party-integrations'
           Status = 'Not relevant'; Note = 'Cloud provider setup, not used here.'; Evidence = @()
           Desc = 'Learn about configuring Claude Code through Amazon Bedrock, including setup, IAM configuration, and troubleshooting.' }
        @{ Path = 'claude-platform-on-aws'; Title = 'Claude Code on Claude Platform on AWS'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Deployment'; GroupPath = 'third-party-integrations'
           Status = 'Not relevant'; Note = 'Cloud provider setup, not used here.'; Evidence = @()
           Desc = 'Configure Claude Code to use the Anthropic-operated Claude API with AWS authentication, IAM access control, and AWS Marketplace billing.' }
        @{ Path = 'google-vertex-ai'; Title = 'Claude Code on Google Cloud''s Agent Platform'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Deployment'; GroupPath = 'third-party-integrations'
           Status = 'Not relevant'; Note = 'Cloud provider setup, not used here.'; Evidence = @()
           Desc = 'Learn about configuring Claude Code through Google Cloud''s Agent Platform, formerly Vertex AI, including setup, IAM configuration, and troubleshooting.' }
        @{ Path = 'microsoft-foundry'; Title = 'Claude Code on Microsoft Foundry'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Deployment'; GroupPath = 'third-party-integrations'
           Status = 'Not relevant'; Note = 'Cloud provider setup, not used here.'; Evidence = @()
           Desc = 'Learn about configuring Claude Code through Microsoft Foundry, including setup, configuration, and troubleshooting.' }
        @{ Path = 'network-config'; Title = 'Enterprise network configuration'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Deployment'; GroupPath = 'third-party-integrations'
           Status = 'Not relevant'; Note = 'Enterprise proxy, CA and mTLS configuration.'; Evidence = @()
           Desc = 'Configure Claude Code for enterprise environments with proxy servers, custom Certificate Authorities (CA), and mutual Transport Layer Security (mTLS) authentication.' }
        @{ Path = 'corporate-launcher'; Title = 'Run Claude Code behind a corporate launcher'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Deployment'; GroupPath = 'third-party-integrations'
           Status = 'Not relevant'; Note = 'Enterprise process wrapper for corporate launchers.'; Evidence = @()
           Desc = 'Route the processes Claude Code starts from its own binary, including the background service and every agent view session, through a required launcher with CLAUDE_CODE_PROCESS_WRAPPER or the processWrapper setting.' }
        @{ Path = 'devcontainer'; Title = 'Development containers'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Deployment'; GroupPath = 'third-party-integrations'
           Status = 'Open'; Impact = 1; Note = 'Dev containers would suit a team repo, but the repo has no .devcontainer folder.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Two owners on Windows with local checkouts; a devcontainer would add Docker overhead for no shared-environment need, and the repo''s guard hook and gates already protect the working copy.'
           Desc = 'Run Claude Code inside a dev container for consistent, isolated environments across your team.' }
        @{ Path = 'gateways'; Title = 'Run Claude Code through a gateway'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Self-hosted gateway for org credentials and cost controls.'; Evidence = @()
           Desc = 'Route Claude Code through a self-hosted gateway for centralized credentials, usage tracking, and cost controls. Covers the architecture, Anthropic''s Claude apps gateway, and using other gateway products.' }
        @{ Path = 'claude-apps-gateway'; Title = 'Claude apps gateway for Amazon Bedrock, Claude Platform on AWS, Google Cloud, and Microsoft Foundry'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Enterprise gateway product.'; Evidence = @()
           Desc = 'Run Claude Code through Amazon Bedrock, Claude Platform on AWS, Google Cloud, or Microsoft Foundry behind a self-hosted gateway with SSO sign-in, per-group model access, and OTLP telemetry.' }
        @{ Path = 'claude-apps-gateway-config'; Title = 'Claude apps gateway configuration'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Gateway configuration reference.'; Evidence = @()
           Desc = 'Reference for every gateway.yaml option: listener and TLS, OIDC, session, Postgres store, Amazon Bedrock, Claude Platform on AWS, Google Cloud''s Agent Platform, and Microsoft Foundry upstreams, model routing, managed policies, and telemetry.' }
        @{ Path = 'claude-apps-gateway-spend-limits'; Title = 'Claude apps gateway spend limits'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Gateway spend limits for an organization.'; Evidence = @()
           Desc = 'Cap each developer''s spend through the Claude apps gateway by day, week, or month. Set limits with an Admin API and the gateway enforces them live on every request.' }
        @{ Path = 'claude-apps-gateway-deploy'; Title = 'Claude apps gateway deployment and operations'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Gateway deployment and operations.'; Evidence = @()
           Desc = 'Register the gateway with your IdP, build the container, deploy on Kubernetes or Cloud Run, and operate it: health checks, secret rotation, upgrades, and security.' }
        @{ Path = 'claude-apps-gateway-on-aws'; Title = 'Deploy Claude apps gateway on AWS'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Gateway deployment on AWS.'; Evidence = @()
           Desc = 'A worked example of running Claude apps gateway on AWS: ECS Fargate or EKS, Amazon RDS for PostgreSQL, AWS Secrets Manager, and IAM-role auth to Amazon Bedrock.' }
        @{ Path = 'claude-apps-gateway-on-gcp'; Title = 'Deploy Claude apps gateway on Google Cloud'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Gateway deployment on Google Cloud.'; Evidence = @()
           Desc = 'A worked example of running Claude apps gateway on Google Cloud: Cloud Run or GKE, Cloud SQL for PostgreSQL, Secret Manager, and service-account auth to Google Cloud''s Agent Platform.' }
        @{ Path = 'llm-gateway'; Title = 'Other LLM gateways'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Third-party LLM gateway routing.'; Evidence = @()
           Desc = 'Route Claude Code through an LLM gateway your organization already runs. Covers connecting Claude Code to a gateway, rolling one out for your organization, and what Claude Code sends to a gateway.' }
        @{ Path = 'llm-gateway-connect'; Title = 'Connect Claude Code to an LLM gateway'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Connecting to an organization LLM gateway.'; Evidence = @()
           Desc = 'Point Claude Code at your organization''s LLM gateway. Check whether your admin already configured it, or set the base URL and credential yourself, then verify the connection and fix gateway errors.' }
        @{ Path = 'llm-gateway-rollout'; Title = 'Roll out an LLM gateway for your organization'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Rolling out a gateway for an organization.'; Evidence = @()
           Desc = 'Deploy a gateway product for Claude Code: configure it to forward what Claude Code sends, issue developer credentials, distribute the configuration through managed settings, and verify the rollout.' }
        @{ Path = 'llm-gateway-protocol'; Title = 'Claude Code gateway compatibility guide'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Gateways'; GroupPath = 'gateways'
           Status = 'Not relevant'; Note = 'Gateway compatibility guide.'; Evidence = @()
           Desc = 'Keep an LLM gateway compatible with Claude Code: the endpoints it calls, the headers and body fields to forward, and what breaks when they''re stripped.' }
        @{ Path = 'monitoring-usage'; Title = 'Monitoring'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Usage and costs'; GroupPath = 'monitoring-usage'
           Status = 'Open'; Impact = 1; Note = 'OpenTelemetry monitoring could apply, but no telemetry env or settings are configured here.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'OpenTelemetry needs a collector and backend to be useful; two subscription users gain little, and the repo already measures cost with measure-skill and the budget gate.'
           Desc = 'Learn how to enable and configure OpenTelemetry for Claude Code.' }
        @{ Path = 'costs'; Title = 'Manage costs effectively'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Usage and costs'; GroupPath = 'monitoring-usage'
           Status = 'Open'; Impact = 2; Note = 'Cost management applies to any team; no spend limits or cost tracking config in the repo.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'The repo already enforces always-on token budgets and has measure-skill and measure-closeouts; spend limits are for API or team billing, not subscription auth.'
           Desc = 'Track token usage, set team spend limits, and reduce Claude Code costs with context management, model selection, extended thinking settings, and preprocessing hooks.' }
        @{ Path = 'analytics'; Title = 'Track team usage with analytics'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Usage and costs'; GroupPath = 'monitoring-usage'
           Status = 'Open'; Impact = 1; Note = 'Usage analytics dashboard is an admin feature the repo does not configure.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'A team and enterprise admin dashboard; two owners on subscription auth get no useful adoption metrics from it.'
           Desc = 'View Claude Code usage metrics, track adoption, and measure engineering velocity in the analytics dashboard.' }
        @{ Path = 'security'; Title = 'Security'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Security and data'; GroupPath = 'security'
           Status = 'Covered'; Impact = 6; Note = 'The repo''s settings.json carries a deliberate permissions block for safe tool use.'; Evidence = @('.claude/settings.json')
           Desc = 'Learn about Claude Code''s security safeguards and best practices for safe usage.' }
        @{ Path = 'data-usage'; Title = 'Data usage'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Security and data'; GroupPath = 'security'
           Status = 'Not relevant'; Note = 'Anthropic data usage policy, informational and legal.'; Evidence = @()
           Desc = 'Learn about Anthropic''s data usage policies for Claude' }
        @{ Path = 'zero-data-retention'; Title = 'Zero data retention'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Security and data'; GroupPath = 'security'
           Status = 'Not relevant'; Note = 'Enterprise ZDR enablement.'; Evidence = @()
           Desc = 'Learn about Zero Data Retention (ZDR) for Claude Code, available to qualified accounts on Claude for Enterprise, including scope, disabled features, and how to request enablement.' }
        @{ Path = 'hipaa-setup'; Title = 'Set up Claude Code (local mode) for a HIPAA-ready organization'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Security and data'; GroupPath = 'security'
           Status = 'Not relevant'; Note = 'HIPAA-ready organization setup.'; Evidence = @()
           Desc = 'Prepare developers'' computers to run Claude Code (local mode) under the HIPAA configuration. Covers versions, network access, managed settings, and local data.' }
        @{ Path = 'communications-kit'; Title = 'Communications kit'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Adoption'; GroupPath = 'communications-kit'
           Status = 'Not relevant'; Note = 'Org rollout announcements and FAQ material.'; Evidence = @()
           Desc = 'Launch announcements, drip-campaign messages, and FAQ responses for rolling Claude Code out to your engineering organization.' }
        @{ Path = 'champion-kit'; Title = 'Champion kit'; Section = 'Administration'; SectionPath = 'admin-setup'; Group = 'Adoption'; GroupPath = 'communications-kit'
           Status = 'Not relevant'; Note = 'Internal adoption playbook for organizations.'; Evidence = @()
           Desc = 'A playbook for engineers advocating Claude Code internally: what to share, how to answer questions, and how to grow adoption on your team.' }
        @{ Path = 'settings'; Title = 'Settings files and precedence'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Settings'; GroupPath = 'settings'
           Status = 'Covered'; Impact = 7; Note = 'Project-scope settings.json is committed with env, permissions, statusLine, enabledPlugins and extraKnownMarketplaces.'; Evidence = @('.claude/settings.json')
           Desc = 'Change Claude Code settings, pick the scope a key belongs in, verify the change, and learn which value Claude Code uses when a key is set in several places.' }
        @{ Path = 'settings-reference'; Title = 'All settings'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Settings'; GroupPath = 'settings'
           Status = 'Covered'; Impact = 5; Note = 'The repo uses several documented keys (env, permissions.allow, statusLine, enabledPlugins, extraKnownMarketplaces) in its settings.json.'; Evidence = @('.claude/settings.json')
           Desc = 'Complete reference for every Claude Code settings.json key: where each one goes, its type and default, and a paste-ready example, with an index of every key.' }
        @{ Path = 'settings-example'; Title = 'Example settings files'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Settings'; GroupPath = 'settings'
           Status = 'Not relevant'; Note = 'Copy-paste example settings files; a reference page, not a feature the repo adopts.'; Evidence = @()
           Desc = 'Realistic settings.json files for a developer, a team, and an organization: copy one, keep the keys you want, and change the values.' }
        @{ Path = 'permissions'; Title = 'Configure permissions'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Permissions and sandboxing'; GroupPath = 'permissions'
           Status = 'Covered'; Impact = 7; Note = 'A committed permissions.allow list covers git, gh and repo script commands for both Bash and PowerShell.'; Evidence = @('.claude/settings.json')
           Desc = 'Control what Claude Code can access and do with fine-grained permission rules, modes, and managed policies.' }
        @{ Path = 'permission-modes'; Title = 'Choose a permission mode'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Permissions and sandboxing'; GroupPath = 'permissions'
           Status = 'Open'; Impact = 3; Note = 'No defaultMode or permission mode is set in the repo settings.'; Evidence = @(); Advice = 'Consider'; AdviceWhy = 'A defaultMode such as acceptEdits or plan could cut prompts beyond the allow list. The catch: it is a per-user choice, and a plugin cannot ship it.'
           Desc = 'Control whether Claude asks before acting. Switch permission modes with Shift+Tab in the CLI, the mode indicator in VS Code, or the mode selector in Desktop.' }
        @{ Path = 'auto-mode-classifier-billing'; Title = 'Auto mode classifier request charges'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Permissions and sandboxing'; GroupPath = 'permissions'
           Status = 'Not relevant'; Note = 'Billing notice troubleshooting for auto mode.'; Evidence = @()
           Desc = 'Resolve the Claude Code notice saying this session isn''t eligible for auto mode''s no-charge classifier requests: what it means, why it appears, and what to do.' }
        @{ Path = 'sandboxing'; Title = 'Configure the sandboxed Bash tool'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Permissions and sandboxing'; GroupPath = 'permissions'
           Status = 'Open'; Impact = 2; Note = 'No sandbox key in settings.json; the sandboxed Bash tool is not configured.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Native Windows support is limited and the work runs PowerShell 5.1 plus Git Bash; breakage would outweigh the gain, since the guard hook and allow list already cover the working copy.'
           Desc = 'Restrict the files and network hosts Claude Code''s shell commands can reach with the built-in sandbox. Turn it on, set the boundary, and fix what it breaks.' }
        @{ Path = 'sandbox-environments'; Title = 'Choose a sandbox environment'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Permissions and sandboxing'; GroupPath = 'permissions'
           Status = 'Open'; Impact = 1; Note = 'No dev container, Docker or VM isolation setup for Claude sessions.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'A comparison page for isolation options this repo has no threat model for: public repo, nothing confidential, trusted owners, branch and PR flow with gates.'
           Desc = 'Compare Claude Code sandbox options: the built-in sandboxed Bash tool, sandbox runtime, dev containers, Docker, and VMs. Choose the right isolation for your threat model.' }
        @{ Path = 'cloud-environments'; Title = 'Configure cloud environments'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Environments'; GroupPath = 'cloud-environments'
           Status = 'Open'; Impact = 1; Note = 'No cloud environment config or setup scripts for Claude Code cloud sessions.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Cloud sessions would need setup scripts and network config for the PowerShell tooling, and they draw on the same shared OAuth quota as the CI review; no present need.'
           Desc = 'Configure cloud environments for Claude Code cloud sessions: network access levels, environment variables, setup scripts, and environment caching.' }
        @{ Path = 'self-hosted-environments'; Title = 'Self-hosted environments'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Environments'; GroupPath = 'cloud-environments'
           Status = 'Not relevant'; Note = 'Self-hosted cloud session runners are infrastructure administration, not applicable to this repo.'; Evidence = @()
           Desc = 'Run Claude Code cloud sessions on infrastructure you control: set up a self-hosted environment, deploy runners, and route sessions to your own compute.' }
        @{ Path = 'self-hosted-environments-quickstart'; Title = 'Self-hosted environments quickstart'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Environments'; GroupPath = 'cloud-environments'
           Status = 'Not relevant'; Note = 'Self-hosted runner setup guide, not applicable.'; Evidence = @()
           Desc = 'Set up your first self-hosted environment: install Claude Code, create the environment, start a runner, and route a session to it.' }
        @{ Path = 'self-hosted-environments-deploy'; Title = 'Deploy self-hosted environments to production'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Environments'; GroupPath = 'cloud-environments'
           Status = 'Not relevant'; Note = 'Production deployment of self-hosted runners, not applicable.'; Evidence = @()
           Desc = 'Run self-hosted runners in production: security hardening, network egress control, git credentials, Kubernetes and Compose recipes, and troubleshooting.' }
        @{ Path = 'self-hosted-environments-configuration'; Title = 'Customize sessions in self-hosted environments'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Environments'; GroupPath = 'cloud-environments'
           Status = 'Not relevant'; Note = 'Self-hosted runner session customization, not applicable.'; Evidence = @()
           Desc = 'Customize self-hosted environment sessions with wrapper scripts for per-session credentials, lifecycle hooks, and on-demand runner spawning.' }
        @{ Path = 'self-hosted-environments-testing'; Title = 'Test self-hosted environments end to end'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Environments'; GroupPath = 'cloud-environments'
           Status = 'Not relevant'; Note = 'Self-hosted runner testing from CI, not applicable.'; Evidence = @()
           Desc = 'Verify a self-hosted runner image from CI: dispatch a session with the CLI, read Claude''s replies through a Stop hook, and script the full loop.' }
        @{ Path = 'self-hosted-environments-reference'; Title = 'Self-hosted environments reference'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Environments'; GroupPath = 'cloud-environments'
           Status = 'Not relevant'; Note = 'Self-hosted runner and orchestrator reference, not applicable.'; Evidence = @()
           Desc = 'Complete reference for the self-hosted runner and orchestrator: CLI flags, environment variables, and Prometheus metrics.' }
        @{ Path = 'self-hosted-environments-identity'; Title = 'Verify session identity in self-hosted environments'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Environments'; GroupPath = 'cloud-environments'
           Status = 'Not relevant'; Note = 'Session identity JWT verification for self-hosted environments, not applicable.'; Evidence = @()
           Desc = 'Verify the CLAUDE_CODE_SESSION_ACCESS_TOKEN JWT so services on your network can trust requests from sessions in your self-hosted environment.' }
        @{ Path = 'model-config'; Title = 'Model configuration'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Model and responses'; GroupPath = 'model-config'
           Status = 'Covered'; Impact = 4; Note = 'Subagent definitions pin a model in frontmatter (model: sonnet), choosing models deliberately per specialist.'; Evidence = @('plugins/dkj-subagents/dkj-subagents-alpha/subagents/specialist-06-16-subagent.md')
           Desc = 'Configure which model Claude Code uses, effort levels, extended context, and the auto-compact window' }
        @{ Path = 'fast-mode'; Title = 'Speed up responses with fast mode'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Model and responses'; GroupPath = 'model-config'
           Status = 'Open'; Impact = 1; Note = 'No fast mode setting or mention in the repo configuration.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Fast mode costs more per token and would draw the shared subscription quota that CI''s Claude review also uses; the repo''s work is not latency-bound.'
           Desc = 'Get faster Opus responses in Claude Code by toggling fast mode.' }
        @{ Path = 'advisor'; Title = 'Escalate hard decisions with the advisor tool'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Model and responses'; GroupPath = 'model-config'
           Status = 'Open'; Impact = 2; Note = 'No advisor model pairing configured.'; Evidence = @(); Advice = 'Consider'; AdviceWhy = 'A stronger advisor could help on hard routing or research calls. The catch: extra quota use on the shared token, and it is a personal setting that a plugin cannot ship.'
           Desc = 'Pair your main model with a stronger advisor model that Claude consults at key moments during a task.' }
        @{ Path = 'output-styles'; Title = 'Output styles'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Model and responses'; GroupPath = 'model-config'
           Status = 'Open'; Impact = 1; Note = 'No outputStyle setting and no output-styles folder in the repo or plugins.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'The specialist personas and the required visible-sender header already shape tone and format, and a custom output style would compete with them and add always-on context.'
           Desc = 'Change Claude Code''s role, tone, and response format with a built-in output style such as Concise or Explanatory, or write a custom style.' }
        @{ Path = 'terminal-config'; Title = 'Configure your terminal for Claude Code'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Interface'; GroupPath = 'terminal-config'
           Status = 'Not relevant'; Note = 'Personal terminal setup (Shift+Enter, tmux, bell, Vim mode), not repo configuration.'; Evidence = @()
           Desc = 'Fix Shift+Enter for newlines, get a terminal bell when Claude finishes, configure tmux, match the color theme, and enable Vim mode in the Claude Code CLI.' }
        @{ Path = 'fullscreen'; Title = 'Fullscreen rendering'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Interface'; GroupPath = 'terminal-config'
           Status = 'Not relevant'; Note = 'Personal rendering preference, not a repo feature.'; Evidence = @()
           Desc = 'Enable a smoother, flicker-free rendering mode with mouse support and stable memory usage in long conversations.' }
        @{ Path = 'accessibility'; Title = 'Use Claude Code with a screen reader'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Interface'; GroupPath = 'terminal-config'
           Status = 'Not relevant'; Note = 'Per-user screen reader and display settings, not repo configuration.'; Evidence = @()
           Desc = 'Set up Claude Code for screen readers such as VoiceOver and NVDA, plus settings for screen magnifiers, reduced motion, and colorblind-friendly themes.' }
        @{ Path = 'voice-dictation'; Title = 'Voice dictation'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Interface'; GroupPath = 'terminal-config'
           Status = 'Not relevant'; Note = 'Personal input method, not repo configuration.'; Evidence = @()
           Desc = 'Speak your prompts in the Claude Code CLI with hold-to-record or tap-to-record voice dictation.' }
        @{ Path = 'statusline'; Title = 'Customize your status line'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Interface'; GroupPath = 'terminal-config'
           Status = 'Covered'; Impact = 3; Note = 'settings.json defines a custom statusLine command running show-progress.ps1 with a 2 second refresh.'; Evidence = @('.claude/settings.json', 'scripts/task/show-progress.ps1')
           Desc = 'Configure a custom status bar to monitor context window usage, costs, and git status in Claude Code' }
        @{ Path = 'keybindings'; Title = 'Customize keyboard shortcuts'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Interface'; GroupPath = 'terminal-config'
           Status = 'Open'; Impact = 1; Note = 'No keybindings.json is shipped or documented in the repo.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Keybindings are a per-user setting in ~/.claude, not something a plugin repo can ship, and nothing here needs a shared shortcut.'
           Desc = 'Customize keyboard shortcuts in Claude Code with a keybindings configuration file.' }
        @{ Path = 'cli-reference'; Title = 'CLI reference'; Section = 'Reference'; SectionPath = 'cli-reference'; Group = 'Reference'; GroupPath = 'cli-reference'
           Status = 'Covered'; Impact = 4; Note = 'CI passes --allowedTools and --max-turns to the Claude action, and scripts use gh and claude plugin commands.'; Evidence = @('.github/workflows/claude-code-review.yml', '.github/workflows/claude.yml')
           Desc = 'Complete reference for Claude Code command-line interface, including commands and flags.' }
        @{ Path = 'commands'; Title = 'Commands'; Section = 'Reference'; SectionPath = 'cli-reference'; Group = 'Reference'; GroupPath = 'cli-reference'
           Status = 'Covered'; Impact = 4; Note = 'Skills reference built-in commands, and the plugin skills are invoked as slash commands.'; Evidence = @('plugins/dkj-policy/skills/plan-goal/SKILL.md')
           Desc = 'Complete reference for commands available in Claude Code, including built-in commands and bundled skills.' }
        @{ Path = 'env-vars'; Title = 'Environment variables'; Section = 'Reference'; SectionPath = 'cli-reference'; Group = 'Reference'; GroupPath = 'cli-reference'
           Status = 'Covered'; Impact = 3; Note = 'settings.json sets env vars DKJ_RUN_STEP_LOG and DKJ_STOPWATCH_SHARE for sessions.'; Evidence = @('.claude/settings.json')
           Desc = 'Reference for environment variables that control Claude Code behavior.' }
        @{ Path = 'tools-reference'; Title = 'Tools reference'; Section = 'Reference'; SectionPath = 'cli-reference'; Group = 'Reference'; GroupPath = 'cli-reference'
           Status = 'Covered'; Impact = 4; Note = 'CI restricts tools via --allowedTools and settings.json lists permission rules for Bash and PowerShell.'; Evidence = @('.github/workflows/claude.yml', '.claude/settings.json')
           Desc = 'Complete reference for the tools Claude Code can use, including permission requirements and per-tool behavior.' }
        @{ Path = 'interactive-mode'; Title = 'Interactive mode'; Section = 'Reference'; SectionPath = 'cli-reference'; Group = 'Reference'; GroupPath = 'cli-reference'
           Status = 'Not relevant'; Note = 'Keyboard shortcut and input mode reference with no repo-level configuration.'; Evidence = @()
           Desc = 'Complete reference for keyboard shortcuts, input modes, and interactive features in Claude Code sessions.' }
        @{ Path = 'checkpointing'; Title = 'Checkpointing'; Section = 'Reference'; SectionPath = 'cli-reference'; Group = 'Reference'; GroupPath = 'cli-reference'
           Status = 'Open'; Impact = 2; Note = 'No repo configuration relies on checkpointing or rewind; work is protected through git branches.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'Git branches, PRs and the check-fanout skill already protect work; checkpoints do not track Bash changes and add nothing to the repo''s workflow.'
           Desc = 'Track, rewind, and summarize Claude''s edits and conversation to manage session state.' }
        @{ Path = 'hooks'; Title = 'Hooks reference'; Section = 'Reference'; SectionPath = 'cli-reference'; Group = 'Reference'; GroupPath = 'cli-reference'
           Status = 'Covered'; Impact = 8; Note = 'hooks.json defines SessionStart and Stop hook entries that run PowerShell session checks and gates.'; Evidence = @('plugins/dkj-policy/hooks/hooks.json')
           Desc = 'Reference for Claude Code hook events, configuration schema, JSON input/output formats, exit codes, async hooks, HTTP hooks, prompt hooks, and MCP tool hooks.' }
        @{ Path = 'channels-reference'; Title = 'Channels reference'; Section = 'Reference'; SectionPath = 'cli-reference'; Group = 'Reference'; GroupPath = 'cli-reference'
           Status = 'Open'; Impact = 1; Note = 'No channel MCP server built or used here.'; Evidence = @(); Advice = 'Skip'; AdviceWhy = 'No MCP server is built or used here; pushing webhooks into sessions has no use case, and the CI review and issue tracker already cover alerts.'
           Desc = 'Build an MCP server that pushes webhooks, alerts, and chat messages into a Claude Code session. Reference for the channel contract: capability declaration, notification events, reply tools, sender gating, and permission relay.' }
        @{ Path = 'glossary'; Title = 'Glossary'; Section = 'Reference'; SectionPath = 'cli-reference'; Group = 'Glossary'; GroupPath = 'glossary'
           Status = 'Not relevant'; Note = 'Terminology reference with no feature to adopt.'; Evidence = @()
           Desc = 'Definitions for Claude Code terminology. Learn what agentic loop, compaction, CLAUDE.md, hooks, subagents, MCP, and other core concepts mean.' }
        @{ Path = 'agent-sdk/overview'; Title = 'Agent SDK overview'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Agent SDK'; GroupPath = 'agent-sdk/overview'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Build production AI agents with Claude Code as a library' }
        @{ Path = 'agent-sdk/quickstart'; Title = 'Quickstart'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Agent SDK'; GroupPath = 'agent-sdk/overview'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Get started with the Python or TypeScript Agent SDK to build AI agents that work autonomously' }
        @{ Path = 'agent-sdk/migration-guide'; Title = 'Migrate to Claude Agent SDK'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Agent SDK'; GroupPath = 'agent-sdk/overview'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Guide for migrating the Claude Code TypeScript and Python SDKs to the Claude Agent SDK' }
        @{ Path = 'agent-sdk/troubleshooting'; Title = 'Troubleshoot the Agent SDK'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Agent SDK'; GroupPath = 'agent-sdk/overview'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Fix Agent SDK errors when the Claude Code CLI fails to start, the CLI process exits, or a successful result arrives without structured output.' }
        @{ Path = 'agent-sdk/configuration'; Title = 'Configure your agent'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Build agents'; GroupPath = 'agent-sdk/configuration'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Configure Agent SDK sessions: compose the options object, set the model, environment, and limits, and find each feature option''s page.' }
        @{ Path = 'agent-sdk/examples'; Title = 'Examples'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Build agents'; GroupPath = 'agent-sdk/configuration'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Find a complete, runnable Agent SDK project or a guided recipe in the Claude Cookbook that matches what you want to build.' }
        @{ Path = 'agent-sdk/agent-loop'; Title = 'How the agent loop works'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Core concepts'; GroupPath = 'agent-sdk/agent-loop'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Understand the message lifecycle, tool execution, context window, and architecture that power your SDK agents.' }
        @{ Path = 'agent-sdk/claude-code-features'; Title = 'Use Claude Code features in the SDK'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Core concepts'; GroupPath = 'agent-sdk/agent-loop'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Load project instructions, skills, hooks, and other Claude Code features into your SDK agents.' }
        @{ Path = 'agent-sdk/sessions'; Title = 'Work with sessions'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Core concepts'; GroupPath = 'agent-sdk/agent-loop'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'How sessions persist agent conversation history, and when to use continue, resume, and fork to return to a prior run.' }
        @{ Path = 'agent-sdk/session-storage'; Title = 'Persist sessions to external storage'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Core concepts'; GroupPath = 'agent-sdk/agent-loop'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Mirror Agent SDK session transcripts to your own object store, key-value store, or database so other hosts can resume your sessions.' }
        @{ Path = 'agent-sdk/streaming-vs-single-mode'; Title = 'Streaming Input'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Input and output'; GroupPath = 'agent-sdk/streaming-vs-single-mode'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Understanding the two input modes for Claude Agent SDK and when to use each' }
        @{ Path = 'agent-sdk/user-input'; Title = 'Handle approvals and user input'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Input and output'; GroupPath = 'agent-sdk/streaming-vs-single-mode'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Surface Claude''s approval requests and clarifying questions to users, then return their decisions to the SDK.' }
        @{ Path = 'agent-sdk/streaming-output'; Title = 'Stream responses in real-time'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Input and output'; GroupPath = 'agent-sdk/streaming-vs-single-mode'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Get real-time responses from the Agent SDK as text and tool calls stream in' }
        @{ Path = 'agent-sdk/structured-outputs'; Title = 'Get structured output from agents'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Input and output'; GroupPath = 'agent-sdk/streaming-vs-single-mode'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Return validated JSON from agent workflows using JSON Schema, Zod, or Pydantic. Get type-safe, structured data after multi-turn tool use.' }
        @{ Path = 'agent-sdk/custom-tools'; Title = 'Give Claude custom tools'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Extend with tools'; GroupPath = 'agent-sdk/custom-tools'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Define custom tools with the Claude Agent SDK''s in-process MCP server so Claude can call your functions, hit your APIs, and perform domain-specific operations.' }
        @{ Path = 'agent-sdk/mcp'; Title = 'Connect to external tools with MCP'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Extend with tools'; GroupPath = 'agent-sdk/custom-tools'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Configure MCP servers to extend your agent with external tools. Covers transport types, tool search for large tool sets, authentication, and error handling.' }
        @{ Path = 'agent-sdk/tool-search'; Title = 'Scale to many tools with tool search'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Extend with tools'; GroupPath = 'agent-sdk/custom-tools'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Scale your agent to thousands of tools by discovering and loading only what''s needed, on demand.' }
        @{ Path = 'agent-sdk/subagents'; Title = 'Subagents in the SDK'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Extend with tools'; GroupPath = 'agent-sdk/custom-tools'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Define and invoke subagents to isolate context, run tasks in parallel, and apply specialized instructions in your Claude Agent SDK applications.' }
        @{ Path = 'agent-sdk/modifying-system-prompts'; Title = 'Modifying system prompts'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Customize behavior'; GroupPath = 'agent-sdk/modifying-system-prompts'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Choose between the `claude_code` preset and a custom system prompt, and customize behavior with CLAUDE.md, output styles, append, or a fully custom prompt.' }
        @{ Path = 'agent-sdk/skills'; Title = 'Extend agents with skills'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Customize behavior'; GroupPath = 'agent-sdk/modifying-system-prompts'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Control which skills Claude can invoke in Claude Agent SDK sessions, dispatch commands by name, and author skills your sessions discover' }
        @{ Path = 'agent-sdk/plugins'; Title = 'Plugins in the SDK'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Customize behavior'; GroupPath = 'agent-sdk/modifying-system-prompts'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Load custom plugins to extend Claude Code with skills, agents, hooks, and MCP servers through the Agent SDK' }
        @{ Path = 'agent-sdk/permissions'; Title = 'Configure permissions'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Control and observability'; GroupPath = 'agent-sdk/permissions'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Control how your agent uses tools with permission modes, hooks, and declarative allow/deny rules.' }
        @{ Path = 'agent-sdk/hooks'; Title = 'Intercept and control agent behavior with hooks'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Control and observability'; GroupPath = 'agent-sdk/permissions'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Intercept and customize agent behavior at key execution points with hooks' }
        @{ Path = 'agent-sdk/file-checkpointing'; Title = 'Rewind file changes with checkpointing'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Control and observability'; GroupPath = 'agent-sdk/permissions'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Track file changes during agent sessions and restore files to any previous state' }
        @{ Path = 'agent-sdk/cost-tracking'; Title = 'Track cost and usage'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Control and observability'; GroupPath = 'agent-sdk/permissions'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Learn how to track token usage, estimate costs, and configure prompt caching with the Claude Agent SDK.' }
        @{ Path = 'agent-sdk/observability'; Title = 'Observability with OpenTelemetry'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Control and observability'; GroupPath = 'agent-sdk/permissions'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Export traces, metrics, and events from the Agent SDK to your observability backend using OpenTelemetry.' }
        @{ Path = 'agent-sdk/todo-tracking'; Title = 'Track todos'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Control and observability'; GroupPath = 'agent-sdk/permissions'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Track todos in Agent SDK sessions and render Claude''s progress in your application from structured tool calls' }
        @{ Path = 'agent-sdk/hosting'; Title = 'Hosting the Agent SDK'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Deployment'; GroupPath = 'agent-sdk/hosting'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Deploy the Agent SDK in production: subprocess architecture, session persistence, scaling, observability, and multi-tenant isolation for Docker, Kubernetes, and sandbox providers.' }
        @{ Path = 'agent-sdk/secure-deployment'; Title = 'Securely deploying AI agents'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'Deployment'; GroupPath = 'agent-sdk/hosting'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'A guide to securing Claude Code and Agent SDK deployments with isolation, credential management, and network controls' }
        @{ Path = 'agent-sdk/typescript'; Title = 'Agent SDK reference - TypeScript'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'SDK references'; GroupPath = 'agent-sdk/typescript'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Complete API reference for the TypeScript Agent SDK, including all functions, types, and interfaces.' }
        @{ Path = 'agent-sdk/typescript-v2-preview'; Title = 'TypeScript SDK V2 session API (removed)'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'SDK references'; GroupPath = 'agent-sdk/typescript'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Reference for the removed V2 TypeScript Agent SDK session API, with session-based send/stream patterns for multi-turn conversations.' }
        @{ Path = 'agent-sdk/python'; Title = 'Agent SDK reference - Python'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = 'SDK references'; GroupPath = 'agent-sdk/typescript'
           Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @()
           Desc = 'Complete API reference for the Python Agent SDK, including all functions, types, and classes.' }
        @{ Path = 'whats-new/index'; Title = 'What''s new'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'A weekly digest of notable Claude Code features, with code snippets, demos, and context on why they matter.' }
        @{ Path = 'whats-new/2026-w37'; Title = 'Week 37  September 7-11, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Test your plugins with claude plugin eval and pop Claude Code Desktop panes out into their own windows.' }
        @{ Path = 'whats-new/2026-w36'; Title = 'Week 36  August 31 - September 4, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Switch to Claude Fable 5.1, let computer use run in the background on Desktop, and watch Claude''s edits in a live /diff panel.' }
        @{ Path = 'whats-new/2026-w35'; Title = 'Week 35  August 24-28, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Resume terminal sessions in the Claude Code Desktop app, review feedback reports that Claude drafts for you, and start a session in restricted mode.' }
        @{ Path = 'whats-new/2026-w34'; Title = 'Week 34  August 17-21, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Draft editable UI artboards with the /design skill, set the Concise output style, and start a Claude Code session on your machine from your phone.' }
        @{ Path = 'whats-new/2026-w33'; Title = 'Week 33  August 10-14, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Claude Code Desktop auto-continues after a usage limit resets, fork mode turns on by default, and GitLab merge requests and marketplaces join GitHub.' }
        @{ Path = 'whats-new/2026-w32'; Title = 'Week 32  August 3-7, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Claude Code sessions message each other, self-hosted environments run cloud sessions on your infrastructure, and auto mode becomes the default permission mode.' }
        @{ Path = 'whats-new/2026-w30'; Title = 'Week 30  July 20-24, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Opus 5 becomes the default Opus model, Claude Code Desktop adds an iOS Simulator pane, and the Claude Security plugin scans your code for vulnerabilities.' }
        @{ Path = 'whats-new/2026-w29'; Title = 'Week 29  July 13-17, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Pull live data into published artifacts through MCP connectors, and use Claude Code with a screen reader in the new screen reader mode.' }
        @{ Path = 'whats-new/2026-w28'; Title = 'Week 28  July 6-10, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Browse external sites from the Desktop app''s built-in browser, run a full setup checkup with /doctor, and pick up auto mode transcript protections and agent view upgrades.' }
        @{ Path = 'whats-new/2026-w27'; Title = 'Week 27  June 29 - July 3, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Claude Sonnet 5 becomes the default model, Claude in Chrome reaches general availability, subagents run in the background by default, Claude Desktop arrives on Linux in beta, and /radio tunes into Claude FM.' }
        @{ Path = 'whats-new/2026-w26'; Title = 'Week 26  June 22-26, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Authenticate MCP servers from your shell with claude mcp login, get a response to shell mode command output with the ! prefix, and resume a conversation from before /clear with /rewind.' }
        @{ Path = 'whats-new/2026-w25'; Title = 'Week 25  June 15-19, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Publish a live, shareable page from your session with Artifacts, match tool parameters in deny and ask rules, and set any setting from the prompt with /config.' }
        @{ Path = 'whats-new/2026-w24'; Title = 'Week 24  June 8-12, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Move a session to a new directory with /cd, let subagents spawn their own subagents, and troubleshoot a broken configuration with safe mode.' }
        @{ Path = 'whats-new/2026-w23'; Title = 'Week 23  June 1-5, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Run auto mode on Amazon Bedrock, Google Cloud''s Agent Platform, and Microsoft Foundry, prompt before writing files that can run code in acceptEdits mode, list installed plugins with /plugin list, and require an approved version range for managed deployments.' }
        @{ Path = 'whats-new/2026-w22'; Title = 'Week 22  May 25-29, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Run Claude Code on Claude Opus 4.8, orchestrate large tasks with dynamic workflows, catch security issues with the security-guidance plugin, and use fast mode on Opus 4.8 at a lower price.' }
        @{ Path = 'whats-new/2026-w21'; Title = 'Week 21  May 18-22, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Use auto mode on the Pro plan and with Sonnet 4.6, see which skills, subagents, and MCP servers drive your plan limits in /usage, and review diffs with the new /code-review command.' }
        @{ Path = 'whats-new/2026-w20'; Title = 'Week 20  May 11-15, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Manage every Claude Code session from one screen with agent view, keep Claude working toward a goal until a condition holds, and run fast mode on Opus 4.7 by default.' }
        @{ Path = 'whats-new/2026-w19'; Title = 'Week 19  May 4-8, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Load plugins from .zip archives and URLs, search command history across every project with Ctrl+R, branch new worktrees from local HEAD or the remote default, and block actions unconditionally with auto mode hard deny rules.' }
        @{ Path = 'whats-new/2026-w18'; Title = 'Week 18  April 27 - May 1, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Claude Code on Windows runs without Git Bash, claude auth login accepts a pasted OAuth code when the browser callback can''t reach localhost, claude project purge cleans up local state per project, and pasting a PR URL into /resume finds the session that created it.' }
        @{ Path = 'whats-new/2026-w17'; Title = 'Week 17  April 20-24, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = '/ultrareview opens as a research preview, automatic session recaps when you return to a terminal, custom color themes you can build and ship in plugins, and a redesigned Claude Code on the web.' }
        @{ Path = 'whats-new/2026-w16'; Title = 'Week 16  April 13-17, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Claude Opus 4.7 with the new xhigh effort level, Routines on Claude Code on the web, mobile push notifications that ping your phone when Claude needs you, a /usage breakdown that shows what''s driving your limits, and native binaries replacing the bundled JavaScript.' }
        @{ Path = 'whats-new/2026-w15'; Title = 'Week 15  April 6-10, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Ultraplan cloud planning, the Monitor tool with self-pacing /loop, /team-onboarding for packaging your setup, and /autofix-pr from your terminal.' }
        @{ Path = 'whats-new/2026-w14'; Title = 'Week 14  March 30 - April 3, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Computer use in the CLI, interactive in-product lessons, flicker-free rendering, per-tool MCP result-size overrides, and plugin executables on PATH.' }
        @{ Path = 'whats-new/2026-w13'; Title = 'Week 13  March 23-27, 2026'; Section = 'What''s New'; SectionPath = 'whats-new/index'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Weekly news digest, not a feature.'; Evidence = @()
           Desc = 'Auto mode for hands-off permissions, computer use built in, PR auto-fix in the cloud, transcript search, and a PowerShell tool for Windows.' }
        @{ Path = 'legal-and-compliance'; Title = 'Legal and compliance'; Section = 'Resources'; SectionPath = 'legal-and-compliance'; Group = ''; GroupPath = ''
           Status = 'Not relevant'; Note = 'Legal agreements and certifications.'; Evidence = @()
           Desc = 'Legal agreements, compliance certifications, and security information for Claude Code.' }
    )
}
