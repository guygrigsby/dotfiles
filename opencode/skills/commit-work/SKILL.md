---
name: commit-work
description: "Create high-quality git commits: review/stage intended changes, split into logical commits, and write clear commit messages (including Conventional Commits). Use when the user asks to commit, craft a commit message, stage changes, or split work into multiple commits."
context: fork
---

# Commit work

## Related Skills

For polishing and organizing commits after creation (reordering, splitting, combining,
improving messages with interactive rebase), see the **commit-refinement** skill.

- **This skill (commit-work)**: Creating new commits with proper staging and messages
- **commit-refinement skill**: Refining existing commits before opening a PR

## Recommended Git Configuration

For optimal workflow with fixup commits, configure:

```bash
# Enable automatic squashing of fixup commits
git config --global rebase.autosquash true

# Use rebase when pulling
git config --global pull.rebase true

# Shorter commit hashes in logs
git config --global log.abbrevCommit true

# Better diff algorithm
git config --global diff.algorithm histogram
```

These settings improve agent and human workflow efficiency.

## Goal
Make commits that are easy to review and safe to ship:
- only intended changes are included
- commits are logically scoped (split when needed)
- commit messages describe what changed and why

## Inputs to ask for (if missing)
- Single commit or multiple commits? (If unsure: default to multiple small commits when there are unrelated changes.)
- Commit style: Conventional Commits are required.
- Any rules: max subject length, required scopes.

## Workflow (checklist)
1) Inspect the working tree before staging
   - `git status`
   - `git diff` (unstaged)
   - If many changes: `git diff --stat`
2) Decide commit boundaries (split if needed)
   - Split by: feature vs refactor, backend vs frontend, formatting vs logic, tests vs prod code, dependency bumps vs behavior changes.
   - If changes are mixed in one file, plan to use patch staging.
3) Stage only what belongs in the next commit
   - Prefer patch staging for mixed changes: `git add -p`
   - To unstage a hunk/file: `git restore --staged -p` or `git restore --staged <path>`
4) Review what will actually be committed
   - `git diff --cached`
   - Sanity checks:
     - no secrets or tokens
     - no accidental debug logging
     - no unrelated formatting churn
5) Describe the staged change in 1-2 sentences (before writing the message)
   - "What changed?" + "Why?"
   - If you cannot describe it cleanly, the commit is probably too big or mixed; go back to step 2.
6) Write the commit message
   - Use Conventional Commits (required):
     - `type(scope): short summary`
     - blank line
     - body (what/why, not implementation diary)
     - footer (BREAKING CHANGE) if needed
   - Prefer an editor for multi-line messages: `git commit -v`
   - Use `references/commit-message-template.md` if helpful.
7) Run the smallest relevant verification
   - Run the repo's fastest meaningful check (unit tests, lint, or build) before moving on.
8) Repeat for the next commit until the working tree is clean

## Deliverable
Provide:
- the final commit message(s)
- a short summary per commit (what/why)
- the commands used to stage/review (at minimum: `git diff --cached`, plus any tests run)

## Iterative Development with Fixup Commits

When refining work through multiple iterations, use fixup commits instead of amending:

### When to use fixup commits
- Making improvements to a commit that isn't pushed yet
- Addressing code review feedback on specific commits
- Iteratively refining a feature across multiple work sessions
- Building complex features with multiple logical commits

### Basic Pattern

```bash
# Make initial commit
git add .
git commit -m "feat: add user authentication"

# Continue working, make improvements
git add .
git commit --fixup HEAD

# Squash before pushing (if no PR open)
git rebase -i --autosquash main
git push
```

### Targeting Specific Commits

```bash
# Show recent commits
git log --oneline -10

# Create fixup for specific commit
git commit --fixup <commit-hash>

# Squash all fixups
git rebase -i --autosquash main
```

### Advantages over amend
- ✅ Preserve work-in-progress history during development
- ✅ Can target multiple different commits
- ✅ Safer (can undo before squashing)
- ✅ Works well with continuous integration (fixup before merge)

### Before Pushing
Always check for open PRs before squashing:

```bash
# If no PR exists, squash fixups
git rebase -i --autosquash main

# If PR is open, push fixup commits directly (see PR workflow below)
git push origin HEAD:<branch>
```

## ⚠️ Important: Fixup Commits and Pull Requests

### Before Opening PR
ALWAYS squash fixup commits before opening a PR:

```bash
git rebase -i --autosquash main
git push origin feature-branch  # Opens PR with clean history
```

### After PR is Open
NEVER rebase after a PR is open. Instead:

**Option 1: Additive commits**
```bash
git add .
git commit -m "fix: address review feedback on validation"
git push origin feature-branch
```

**Option 2: Fixup commits (will be squashed on merge)**
```bash
git add .
git commit --fixup <commit-hash>
git push origin feature-branch
```

Use GitHub's **"Squash and merge"** button when merging the PR.

### Why This Matters
- Rebase rewrites history → breaks PR context
- Force-push is dangerous after PR is open
- GitHub handles squashing automatically on merge
- Reviewers can track iteration history

### Detailed Guide
See `references/fixup-workflow.md` for comprehensive examples, troubleshooting, and advanced techniques.
