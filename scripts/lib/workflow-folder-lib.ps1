<#
.SYNOPSIS
    Get-WorkflowFolderNames / Get-WorkflowFolderName: where the workflow's own folder sits in a repo --
    '.dkj/dkj-repo-workflow' since #4209. Find-LegacyWorkflowFolder: the older folder a repo that has not
    moved yet still has, for the adopt step that moves it and for nothing else.

.DESCRIPTION
    ONE LIST, TWO LIBS (#3870, November 7, 2026). The folder's name used to be known in two places that
    could not reach each other: seam-lib.ps1 resolved it against a tree for the changelog and the release
    roots, and entry-scaffold-lib.ps1 hardcoded it for the branch documents. Both now read it here, so
    the answer for "where is the changelog" and "where is the branch document" cannot disagree in a repo
    mid-move. A leaf with no dependencies, so either lib can load it first.

    WHY A DOT-FOLDER, AND WHY NOT .claude/ (#3870). A repo running this workflow has two kinds of
    folder: what it BUILDS (in the source repo, plugins/<plugin>/) and what an installed plugin USES in
    it. The dot is the convention .github/ and .vscode/ already follow -- a dot-folder is a tool's, a plain
    folder is the product -- and '.dkj/' is the one home for every plugin of this marketplace that leaves
    data in a repo, each in a subfolder named after it (#1437's rule, kept). '.claude/' was the first
    candidate and was declined: it is a Claude Code PROTECTED PATH, so every write there prompts under
    'default' and 'acceptEdits' and no allow rule pre-approves it, and the branch document is written
    almost every turn.

    A HARD CUT SINCE #4209 (owner's decision, November 17, 2026). Until then the readers walked every
    older name, newest first, so an unmoved repo kept working under its old folder. Since the rename of
    the plugin to dkj-repo-workflow, the readers resolve the current name ONLY: a repo still holding an
    older folder is moved by adopt-dkj-repo-workflow's Part 1 before its gates see a branch document
    again. The older names -- '.dkj/dkj-policy' (#3870 to #4209), 'dkj-policy' (#1437 to #3870),
    'contributing-davekjohn' (#886 to #1437), 'workflow-davekjohn' -- are read by that move alone,
    through Find-LegacyWorkflowFolder, and never written.

    FORWARD SLASHES OUT. These names go to git as often as to Join-Path, and Join-Path on Windows accepts
    '/' -- the same rule Get-BranchFilePaths states for the paths it hands out.

    Dot-source this file:

        . (Join-Path $PSScriptRoot 'workflow-folder-lib.ps1')

    Pure ASCII (repo convention for .ps1).
#>

function Get-WorkflowFolderNames {
    <#
        The names the readers accept for the workflow folder: the current one only since #4209's hard cut.
        Still a list, so a caller that asks "is this root one of ours" keeps one shape.
    #>
    return @('.dkj/dkj-repo-workflow')
}

function Get-LegacyWorkflowFolderNames {
    <#
        Every earlier name the workflow folder has had, newest first. Read by the adopt step's move only
        (#4209), never by a reader and never written.
    #>
    return @('.dkj/dkj-policy', 'dkj-policy', 'contributing-davekjohn', 'workflow-davekjohn')
}

function Find-LegacyWorkflowFolder {
    <#
        The newest earlier workflow folder that exists in $RepoRoot as a directory, or '' when there is
        none. The adopt step moves what this finds to the current name (#4209).
    #>
    param([Parameter(Mandatory)][string]$RepoRoot)
    foreach ($name in @(Get-LegacyWorkflowFolderNames)) {
        if (Test-Path -LiteralPath (Join-Path $RepoRoot ($name -replace '/', '\')) -PathType Container) { return $name }
    }
    return ''
}

function Get-WorkflowFolderName {
    <#
        The workflow folder's repo-relative name in $RepoRoot: the current name, whatever the tree holds,
        since #4209's hard cut. $RepoRoot is kept so callers keep one signature; it no longer changes the
        answer.

        WHY THIS EXISTS (#886, August 26, 2026). The folder has renamed, and the seam defaults and the branch
        document paths all compose a path out of it. Hardcoding the new name would point an unmoved repo's
        changelog and release roots at a directory it does not have, and the fold would then create a
        second changelog beside the one holding its history rather than failing loudly. Hardcoding an old
        name would send every new repo to a folder the scaffolder no longer writes.

        $RepoRoot EMPTY answers the current name without looking, for a caller asking only for the shape.

        Deliberately NOT a seam. A repo that wants to differ already has Get-ChangelogPath and the release
        root seams to say so; another answer for "what is the folder called" would let them disagree.
    #>
    param([AllowEmptyString()][string]$RepoRoot = '')
    return @(Get-WorkflowFolderNames)[0]
}
