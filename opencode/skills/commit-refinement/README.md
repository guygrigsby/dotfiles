# Commit Refinement

> Polish and organize your commits to tell a clear story

## What This Skill Teaches

This skill helps you craft high-quality Git commits that serve as effective communication tools for reviewers, collaborators, and future maintainers. You'll learn to:

- **Structure commits into a coherent narrative** that tells the story of your changes
- **Size commits appropriately** so they're both small (focused) and atomic (complete)
- **Write meaningful commit messages** that explain what changed and why
- **Use interactive rebase** to refine commit history before sharing

## Why Commit Quality Matters

Have you ever asked yourself:
- "What's the point of this code?"
- "Why was it written this way?"
- "Where did this bug come from?"
- "This PR is massive, where do I start?"

Quality commits answer these questions. They transform your repository's history from a chaotic log of changes into a clear, navigable record that helps everyone understand the codebase.

**Benefits**:
- **Easier code review**: Reviewers can understand changes commit-by-commit
- **Better debugging**: `git bisect` can pinpoint when bugs were introduced
- **Faster onboarding**: New developers can trace the evolution of code
- **Clearer context**: Future you (and others) will understand why decisions were made

## Quick Reference

### Interactive Rebase

```bash
# Start rebase from base branch
git rebase -i main

# Rebase last N commits
git rebase -i HEAD~5

# Abort if things go wrong
git rebase --abort
```

### Reorder Commits

In the rebase-todo file, cut and paste lines to change order.

### Split a Commit

```bash
git rebase -i main  # Mark commit as 'edit'
# When rebase pauses:
git reset HEAD~
git add -p          # Stage first part
git commit -m "First logical unit"
git add -p          # Stage second part
git commit -m "Second logical unit"
git rebase --continue
```

### Combine Commits

```bash
git rebase -i main
# Use 'squash' to combine with previous and edit message
# Use 'fixup' to combine with previous and discard message
```

### Rewrite Message

```bash
git rebase -i main
# Use 'reword' to edit commit message
```

### Safety Net

```bash
# View all recent actions
git reflog

# Recover from mistakes
git reset --hard HEAD@{n}
```

## The Three Principles

### 1. Structure the Narrative

Organize commits to tell a coherent story, not a stream of consciousness.

**Good narrative structures**:
- **Linear feature build**: Foundation → Core implementation → Polish → Tests
- **Refactor-then-implement**: Extract helpers → Simplify → Add feature
- **Bug fix**: Add failing test → Fix bug → Verify

**Poor narrative structures**:
- WIP commits scattered throughout
- Jumping between unrelated topics
- "Fix typo" commits that should be squashed
- Mixed bag of review feedback as single commit

**Example transformation**:

Before (stream of consciousness):
```
- WIP
- Finish script
- Add --invert and --grey
- Add --output option
- Add CI config
- Fix CI build issues
- Let users use --gray spelling
```

After (organized narrative):
```
- Create initial image modifier script
- Add --output option
- Add --invert option
- Add --grey option
- Add --gray as alias for --grey
- Add GitHub Actions CI
```

### 2. Make Commits Small and Atomic

Each commit should be focused yet complete.

**Small** means minimal scope:
- Does one "thing"
- May touch many files if that one thing requires it (e.g., renaming a function)
- Easy to explain in 1-2 sentences

**Atomic** means stable and independent:
- Code builds successfully
- Tests pass
- Can roll back to this commit and have a working system
- No "Part 1 of 2" commits

**Signs a commit is too large**:
- Mixes refactoring with feature work
- Touches multiple unrelated components
- Difficult to summarize in commit message
- Reviewers lose track of what's changing

**Signs a commit is too small/incomplete**:
- Code doesn't compile
- Tests fail
- Later commit "completes" this one
- Doesn't make sense without next commit

### 3. Explain the Context

Commit messages should answer **what** and **why**, not just list files changed.

**The What/Why Framework**:

| Level      | What (doing)           | Why (reason)              |
|------------|------------------------|---------------------------|
| High-level | **Intent**             | **Context**               |
|            | What does this achieve?| Why is code like this now?|
| Low-level  | **Implementation**     | **Justification**         |
|            | How did you do it?     | Why this approach?        |

**Simple change example**:
```
fix(ui): correct button alignment in header

Buttons were misaligned after recent CSS grid migration.
Center them using flexbox to match design spec.
```

**Complex change example**:
```
fix(auth): prevent token reuse after logout

Currently, JWT tokens remain valid until expiration even after user
logout, allowing potential security issues if tokens are compromised.

To invalidate tokens immediately on logout, maintain a token blocklist
in Redis with TTL matching token expiration. Check blocklist in auth
middleware before validating token claims.

This adds ~2ms latency to auth checks but closes the security gap.

BREAKING CHANGE: Requires Redis instance for auth service
```

## Practical Example: Refining a Feature Branch

Let's say you've been working on adding image manipulation to a script. Your current history looks messy:

```bash
$ git log --oneline
9cd6412 Let users use --gray option spelling
6af4476 Add requirements.txt + other build fixes
1689371 Add GitHub Actions CI .yml
9512893 Add --output option
b3348a0 Add --invert and --grey
692f477 Finish script
6a885eb WIP
```

### Step 1: Outline the Narrative

What story should this tell?
1. Create basic script
2. Add --output option
3. Add image manipulation options (--invert, --grey, --gray)
4. Add CI configuration

### Step 2: Start Interactive Rebase

```bash
git rebase -i main
```

### Step 3: Reorganize in Editor

**Before**:
```
pick 6a885eb WIP
pick 692f477 Finish script
pick b3348a0 Add --invert and --grey
pick 9512893 Add --output option
pick 1689371 Add GitHub Actions CI .yml
pick 6af4476 Add requirements.txt + other build fixes
pick 9cd6412 Let users use --gray option spelling
```

**After** (with refinements):
```
pick 6a885eb WIP
squash 692f477 Finish script
fixup 6af4476 Add requirements.txt + other build fixes  # moved up
pick 9512893 Add --output option
edit b3348a0 Add --invert and --grey  # will split this
pick 9cd6412 Let users use --gray option spelling  # moved up
pick 1689371 Add GitHub Actions CI .yml
```

### Step 4: Split the Combined Commit

When rebase pauses at the `edit` commit:
```bash
git reset HEAD~
git add -p  # Select only --invert changes
git commit -m "Add --invert option"
git add -p  # Select only --grey changes  
git commit -m "Add --grey option"
git rebase --continue
```

### Step 5: Review Final History

```bash
$ git log --oneline
3bf4ec4 Add GitHub Actions CI .yml
851f2a0 Let users use --gray option spelling
2d164e2 Add --grey option
3e5e5f6 Add --invert option
381d3af Add --output option
096ee13 Create initial image modifier script
```

Much better! Clear narrative, atomic commits, logical order.

## Tools at Your Disposal

### Interactive Rebase
Reorganize, split, combine, and reword commits.

### git blame
Find which commit last modified each line of a file.
```bash
git blame <file>
git blame -L 10,20 <file>  # Specific lines
```

### git log
Search commit history.
```bash
git log --oneline --graph
git log <file>  # Commits affecting a file
git log -L :function:<file>  # Changes to a function
git log --grep="pattern"  # Search commit messages
```

### git bisect
Binary search to find bug-introducing commit (requires atomic commits!).
```bash
git bisect start
git bisect bad  # Current commit is broken
git bisect good v1.2.0  # This version was working
# Git checks out middle commit, you test it
git bisect bad  # or git bisect good
# Repeat until found
```

### git show
View details of a specific commit.
```bash
git show <commit-hash>
```

## When to Refine Commits

**Always refine before**:
- Opening a pull request
- Sharing your branch with others
- Merging to main/develop

**Consider refining after**:
- Significant code changes
- Adding multiple features
- Long-running feature branches

**Never refine after**:
- Pull request is already open (breaks review context)
- Others have based work on your commits
- Commits are already pushed to shared/public branches (without team coordination)

## Common Pitfalls

### Pitfall 1: "I'll clean it up later"
Commit refinement is easier when changes are fresh in your mind. Plan your narrative early, refine often.

### Pitfall 2: Mixing commit creation and refinement
Use `commit-work` skill to create commits properly. Use `commit-refinement` skill (this one) to polish them.

### Pitfall 3: Fear of interactive rebase
Start with small refinements (reordering 2-3 commits). Build confidence. Use `git rebase --abort` as your safety net.

### Pitfall 4: Over-polishing
Aim for "good enough to review," not perfection. Commits should communicate clearly, not win literary awards.

## Integration with Other Skills

- **commit-work**: Use for creating individual commits with proper staging and messages
- **commit-refinement** (this skill): Use for organizing and polishing commits
- **session-close**: Use for final checks before ending your session

## Advanced Topics

See the `references/` directory for comprehensive guides:

- **interactive-rebase-guide.md**: Deep dive on rebase workflows, conflict resolution, troubleshooting
- **commit-narrative-patterns.md**: Detailed examples of good narrative structures and anti-patterns
- **commit-message-framework.md**: Complete guide to writing effective commit messages
- **git-investigation-tools.md**: Master git blame, log, and bisect for code archaeology

## Further Reading

This skill is based on GitHub's excellent article:
- ["Write Better Commits, Build Better Projects"](https://github.blog/developer-skills/github/write-better-commits-build-better-projects/) by Victoria Dye (2022)

Additional resources:
- [Git Organized: A Better Git Flow](https://render.com/blog/git-organized-a-better-git-flow) - Alternative methodology
- [My Favourite Git Commit](https://dhwthompson.com/2019/my-favourite-git-commit) - Example of an exceptional commit message
- [A Note About Git Commit Messages](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) - Formatting and phrasing advice
- [Conventional Commits](https://www.conventionalcommits.org/) - Structured commit message format

---

**Remember**: Your commits tell a story. Make it a good one!
