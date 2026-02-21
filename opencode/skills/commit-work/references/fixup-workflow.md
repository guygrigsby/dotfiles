# Fixup Commit Workflow

Complete guide to using fixup commits for iterative development.

## Quick Reference

| Task | Command |
|------|---------|
| Fixup last commit | `git commit --fixup HEAD` |
| Fixup specific commit | `git commit --fixup <hash>` |
| Squash all fixups | `git rebase -i --autosquash <base>` |
| Enable autosquash | `git config --global rebase.autosquash true` |
| Check for open PR | `gh pr view` |

## Detailed Workflows

### Scenario 1: Feature Development

**Initial implementation:**
```bash
git add src/auth.js
git commit -m "feat: implement JWT authentication"
```

**Add tests (separate concern):**
```bash
git add tests/auth.test.js
git commit -m "test: add authentication tests"
```

**Fix bug in original implementation:**
```bash
# Edit src/auth.js
git add src/auth.js
git commit --fixup HEAD~1  # or use commit hash
```

**Before pushing:**
```bash
git rebase -i --autosquash main
# Fixup commits automatically squash into targets
git push origin feature-branch
```

---

### Scenario 2: Code Review Iteration

**After PR feedback on multiple commits:**

```bash
# Show commits in PR
git log --oneline main..HEAD

# Fix issues in commit abc123
git add .
git commit --fixup abc123

# Fix issues in commit def456
git add .
git commit --fixup def456

# Squash all fixups
git rebase -i --autosquash main

# Force push (PR update)
git push --force-with-lease origin feature-branch
```

---

### Scenario 3: Multi-Commit Feature

**Building a feature across multiple logical commits:**

```bash
# Database schema
git add migrations/
git commit -m "feat(db): add users table schema"

# API layer
git add src/api/users.js
git commit -m "feat(api): add user endpoints"

# UI layer
git add src/components/UserProfile.jsx
git commit -m "feat(ui): add user profile component"

# Later: improve API validation (commit #2)
git add src/api/users.js
git commit --fixup <commit-hash-of-api-layer>

# Later: fix UI styling (commit #3)
git add src/components/UserProfile.jsx
git commit --fixup <commit-hash-of-ui-layer>

# Squash all fixups
git rebase -i --autosquash main
```

---

## Fixup Commits with Pull Requests

### Critical Rule: No Rebase After PR

Once a PR is open, NEVER rebase or force-push (unless coordinating with reviewers).

### Workflow Phases

**Phase 1: Local Development (pre-PR)**
```bash
# Work iteratively with fixup commits
git commit -m "feat: implement feature"
git commit --fixup HEAD  # refinements
git commit --fixup HEAD  # more refinements

# ✅ SQUASH BEFORE OPENING PR
git rebase -i --autosquash main

# Push clean history
git push origin feature-branch

# Open PR on GitHub
gh pr create --title "Add feature" --body "Description"
```

**Phase 2: PR Open (in review)**  
```bash
# ❌ DO NOT REBASE after PR is open

# Address review feedback with additive commits
git add .
git commit -m "fix: address review feedback on validation"

# OR use fixup commits (will be squashed on merge)
git add .
git commit --fixup <commit-hash>

# Push directly (no rebase!)
git push origin feature-branch

# CI runs, reviewers see changes
# Continue making additive or fixup commits as needed
```

**Phase 3: After Merge**
```bash
# Merge PR using GitHub's "Squash and merge" button
# This combines all commits (including fixups) into one clean commit

# Pull the squashed commit
git checkout main
git pull

# Clean up local branch
git branch -d feature-branch
```

### GitHub Squash Merge

When merging a PR, use the **"Squash and merge"** button:

1. Click "Squash and merge" on PR page
2. Edit the commit message (GitHub pre-fills from all commits)
3. Confirm merge
4. All commits (including fixups) become one clean commit on main

**Benefits:**
- ✅ Clean history on main branch
- ✅ No force-push needed during review
- ✅ Preserves PR discussion and iteration
- ✅ CI runs on actual review commits
- ✅ Reviewers can track changes over time

### Why No Rebase After PR?

**Problems with rebasing after PR:**
- Rewrites history → breaks PR context
- Force-push confuses reviewers
- CI results no longer match commits
- Discussion comments become orphaned
- Dangerous if others have pulled your branch

**Solution:**
- Rebase before opening PR (clean initial state)
- Additive/fixup commits during review (transparent iteration)
- Squash merge when done (clean final state)

---

## Advanced Techniques

### Interactive Fixup Selection

```bash
# Select specific hunks to fixup
git add -p  # Interactively select changes
git commit --fixup <target-commit>
```

### Fixup with Message Amendment

```bash
# Create fixup that also updates commit message
git commit --fixup=amend:<commit-hash>

# Create fixup that lets you reword the message
git commit --fixup=reword:<commit-hash>
```

### Squashing Multiple Commits

```bash
# Use interactive rebase for more control
git rebase -i main

# In editor, manually mark additional commits as 'fixup'
# This gives you full control over what gets squashed
```

---

## Best Practices

### DO:
- ✅ Use fixup for iterative refinement of existing commits
- ✅ Squash before pushing to shared branches (or opening PR)
- ✅ Keep fixup commits focused on a single original commit
- ✅ Use conventional commit format even for fixup commits
- ✅ Push additive or fixup commits after PR is open
- ✅ Use GitHub squash merge for PRs

### DON'T:
- ❌ Push fixup commits to main/master
- ❌ Create fixup chains (fixup of a fixup)
- ❌ Use fixup for unrelated changes
- ❌ Forget to squash before opening PR
- ❌ Rebase after PR is open (use additive commits instead)
- ❌ Force-push to PR branches without coordination

---

## Troubleshooting

### "Cannot rebase: You have unstaged changes"
```bash
git stash
git rebase -i --autosquash main
git stash pop
```

### "Fixup commit didn't squash"
```bash
# Ensure autosquash is enabled or use flag explicitly
git rebase -i --autosquash main

# Verify autosquash config
git config --global rebase.autosquash
```

### "Wrong commit targeted"
```bash
# Before squashing, fix the target
git rebase -i main

# In editor, change 'fixup' to 'pick' for the commit
# Move it to correct location or change its fixup target
```

### "Conflicts during rebase"
```bash
# Resolve conflicts in files
git add <resolved-files>
git rebase --continue

# If things go wrong, abort and try again
git rebase --abort
```

### "Accidentally rebased with open PR"
```bash
# If you haven't pushed yet
git reflog  # Find commit before rebase
git reset --hard <commit-hash>

# If you already force-pushed
# Communicate with reviewers
# Consider opening a new PR from a fresh branch
```

---

## Comparison with Other Approaches

| Approach | Use Case | Pros | Cons |
|----------|----------|------|------|
| `git commit --amend` | Fix last commit only | Simple, fast | Only works for HEAD |
| Fixup commits | Fix any commit, pre-PR | Flexible, safe, undoable | Requires rebase (can't use after PR) |
| Additive commits | Fix after PR is open | Safe during review | Creates messy history (needs squash merge) |
| Squash merge | Flatten entire PR | Clean main history | Loses granular commit history |
| Direct commits | Final commits only | No rebase needed | Messy history, hard to review |

---

## Integration with Tools

### With GitHub/GitLab

**Before opening PR:**
```bash
git rebase -i --autosquash main
git push origin feature-branch
gh pr create
```

**During PR review:**
```bash
# Make changes based on feedback
git commit -m "fix: address review comments"
git push origin feature-branch  # No force-push!
```

**Merging PR:**
- Use "Squash and merge" button
- Edit final commit message
- Confirm

### With Pre-commit Hooks

```bash
# Hooks run on fixup commits normally
git commit --fixup HEAD  # Pre-commit hooks execute

# If hooks modify files, add and amend
git add .
git commit --amend --no-edit
```

### With CI/CD

**Pre-PR:**
- CI runs after rebase (clean commits)

**During PR:**
- CI runs on every additive/fixup commit push
- Each push triggers new CI run
- Reviewers see CI status for current state

**After merge:**
- CI runs on the single squashed commit on main
- Clean history means clean CI logs

---

## Platform Notes

This workflow is optimized for **GitHub**. 

**GitLab** and **Bitbucket** have similar squash merge features:
- GitLab: "Squash commits when merge request is accepted"
- Bitbucket: "Squash" merge strategy

The core principles apply across platforms:
1. Rebase before opening MR/PR
2. Additive commits during review
3. Squash merge when done

Consult your platform's documentation for specific merge options.

---

## Configuration

**Recommended global settings:**

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

**Verify settings:**
```bash
git config --global --get-regexp 'rebase|pull|log|diff'
```

These settings make fixup workflows seamless and efficient for both agents and humans.
