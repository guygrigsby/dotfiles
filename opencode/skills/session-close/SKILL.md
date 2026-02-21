---
name: session-close
description: Protocol for properly ending a coding session - ensures all work is committed, pushed, and handed off correctly.
context: fork
license: MIT
compatibility: opencode
metadata:
  category: workflow
  tools: git, bd
---

## When to use me

Use this skill when ending a work session. This ensures all work is properly saved, pushed, and documented for the next session.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

For detailed rebase instructions (interactive rebase, splitting, combining commits), see the **commit-refinement** skill.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update beads issues** - Sync tracking state:
   ```bash
   # Close completed work
   bd update <id> --status closed
   
   # Update in-progress items
   bd update <id> --status ready  # Or add notes
   
   # Create issues for remaining/discovered work
   bd create task "Follow-up: [description]"
   ```
4. **SQUASH FIXUP COMMITS** (if no open PR) - Clean up development history:
   ```bash
   # Safely check for open PR
   if command -v gh >/dev/null 2>&1; then
     if gh pr view >/dev/null 2>&1; then
       echo "⚠️  Open PR detected - skipping rebase"
       echo "ℹ️  You can push additive or fixup commits"
       echo "✓  Use GitHub 'Squash and merge' when merging PR"
     else
       echo "✓  No PR found - safe to rebase"
       git rebase -i --autosquash origin/main
     fi
   else
     echo "⚠️  gh CLI not found - skipping rebase for safety"
     echo "ℹ️  Install gh: https://cli.github.com"
     echo "ℹ️  Or manually rebase if no PR exists"
   fi
   ```
5. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git fetch origin
   git status  # Verify clean state
   bd sync  # Sync beads changes first
   git push origin HEAD:<branch-name>
   git status  # MUST show "up to date with origin"
   ```
6. **Clean up** - Remove local fixup branches, prune stale remotes
7. **Verify** - All changes committed AND pushed
8. **Hand off** - Provide context for next session

## Critical Rules

- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
- ALWAYS check for PR before rebasing
- After PR open: push additive or fixup commits directly
- Use GitHub squash merge to clean history

## Checklist

Before saying "done" or "complete", run this checklist:

```
[ ] 1. git status                       (check working tree is clean)
[ ] 2. git log --oneline -10            (review recent commits)
[ ] 3. bd update <id> --status closed   (update beads issue status)
[ ] 4. (Run PR-aware rebase from step 4 above)
[ ] 5. bd sync                          (sync beads changes)
[ ] 6. git push origin HEAD:<branch>    (push to remote)
[ ] 6. git status                       (verify "up to date")
```

**NEVER skip this.** Work is not done until pushed.

## PR Workflow Details

### If No Pull Request Exists
Squash fixup commits before pushing:

```bash
# Check for fixup commits
git log --oneline --all --grep="^fixup!"

# Squash them
git rebase -i --autosquash origin/main

# Verify clean history
git log --oneline origin/main..HEAD

# Push
git push origin HEAD:<branch-name>
```

### If Pull Request is Open
Push additive or fixup commits directly:

```bash
# Make changes based on review feedback
git add .
git commit -m "fix: address review comments"
# OR
git commit --fixup <commit-hash>

# Push directly (no rebase!)
git push origin HEAD:<branch-name>

# When merging: Use GitHub's "Squash and merge" button
```

⚠️ **CRITICAL:** Only rebase if NO pull request is open for this branch!

## Common Issues

### "Cannot push - branch diverged"
```bash
git fetch origin
git rebase origin/<branch-name>
git push origin HEAD:<branch-name>
```

### "Rebase conflicts"
```bash
# Resolve conflicts in files
git add <resolved-files>
git rebase --continue
```

### "Forgot to squash fixups"
```bash
# If already pushed, need to rewrite history
git rebase -i --autosquash origin/main
git push --force-with-lease origin HEAD:<branch-name>
```

**AVOID force-push** to shared branches - coordinate with team first.
