---
name: commit-refinement
description: "Polish and organize commits using interactive rebase. Covers narrative structure, atomic commits, and commit message quality. Based on GitHub's best practices. Use when refining history before PR or after code review."
context: fork
---

# Commit Refinement

## Overview

Commits are more than save points—they are snapshots that tell the story of how and why code came to be. A repository's commit history is the best tool developers have to explain and understand code.

This skill teaches how to craft high-quality commits by:
- Organizing commits into a coherent narrative
- Ensuring commits are small and atomic
- Writing commit messages that explain what and why

These practices make code reviews easier, enable effective debugging with `git bisect`, and help future developers (including your future self) understand the codebase.

**Key principle**: Commits should be tweaked and polished to deliberately convey a message to reviewers, contributors, and future maintainers.

## Three Core Principles

### 📚 Principle 1: Structure the Narrative

Like a novel, a series of commits has a narrative structure that contextualizes the "plot" of your change. Before polishing, branches often reflect a stream of consciousness with WIP commits, topic jumping, and mixed concerns.

**Guideline**: Outline your narrative, and reorganize your commits to match it.

#### DO ✅
- Write an outline and include it in the pull request description
- Use the outline to guide your work (plan ahead!)
- Stick to one high-level concept per branch
- Add your "implement feature" commit immediately after the refactoring that sets it up
- Treat commits as "building blocks" of different types: bugfix, refactor, stylistic change, feature, etc.

#### DON'T ❌
- Wait until the end to form the outline
- Go down tangentially-related "rabbit holes"
- Jump back and forth between topics throughout your branch
- Mix multiple building block types in a single commit

### ⚛️ Principle 2: Make Commits Small and Atomic

Commits should minimize the effort needed to build a mental model of changes.

**Small** = Minimal scope; does one "thing"
- Often correlates with fewer lines of code
- But not always: renaming a widely-used function may touch hundreds of lines but has constrained scope

**Atomic** = Stable, independent unit of change
- Repository should still build and pass tests if rolled back to that exact commit
- No incomplete implementations
- Reader has everything needed to evaluate the change

#### Why This Matters
- **Too large**: Reviewers conflate unrelated topics, miss bugs
- **Too small/incomplete**: Reviewers can't evaluate partial changes, can't roll back to this commit
- **Just right**: Reviewers build accurate mental model, `git bisect` works effectively

### ❓ Principle 3: Explain the Context

Commit messages provide context that code alone cannot convey. They explain the intent, background, and reasoning behind changes.

**Guideline**: Describe **what** you're doing and **why** you're doing it.

#### The Four Questions Framework

|           | WHAT (doing)        | WHY (reason)           |
|-----------|---------------------|------------------------|
| High-level| **Intent**          | **Context**            |
| Low-level | **Implementation**  | **Justification**      |

1. **Intent** (high-level what): What does this accomplish?
2. **Context** (high-level why): Why does the code do what it does now?
3. **Implementation** (low-level what): What did you do to accomplish your goal?
4. **Justification** (low-level why): Why is this change being made?

Not every commit needs all four explicitly stated—tailor detail to complexity. But the message should address what and why.

## Interactive Rebase Workflow

Interactive rebase is the primary tool for refining commit history. It allows you to reorder, split, combine, and reword commits.

### When to Refine

**DO refine**:
- ✅ Before opening a PR (always)
- ✅ After addressing code review feedback (if no PR open yet)
- ✅ When commits don't tell a clear story
- ✅ When commits are too large or too small

**DON'T refine**:
- ❌ After PR is open (conflicts with code review workflow)
- ❌ After pushing to shared/public branches (without coordination)
- ❌ On commits others have based work on

### Basic Rebase Pattern

```bash
# Start interactive rebase from base branch
git rebase -i main

# Or rebase last N commits
git rebase -i HEAD~5
```

This opens your editor with the rebase-todo file listing commits from oldest (top) to newest (bottom).

### Common Operations

#### Reorder Commits
Cut and paste lines in the rebase-todo file to change commit order.

**Use when**: Commits are out of narrative sequence

#### Split Commits
1. Mark commit with `edit` (or `e`)
2. When rebase pauses: `git reset HEAD~`
3. Stage partial changes: `git add -p`
4. Create first new commit: `git commit -m "..."`
5. Stage remaining changes: `git add -p`
6. Create second new commit: `git commit -m "..."`
7. Continue: `git rebase --continue`

**Use when**: Commit contains multiple distinct "things"

#### Combine Commits
Use `squash` (or `s`) to combine with previous commit and edit message.
Use `fixup` (or `f`) to combine with previous commit and discard this message.

**Use when**: 
- Multiple commits represent one logical change
- WIP commits need consolidation
- Typo fixes should merge into original commits

#### Reword Commits
Mark commit with `reword` (or `r`) to change its message without modifying code.

**Use when**: Commit message lacks context, intent, or justification

### Safety Tips

```bash
# Abort rebase if things go wrong
git rebase --abort

# View all recent HEAD movements (safety net)
git reflog

# Recover from mistakes
git reset --hard HEAD@{n}

# Always verify after rebase
git log --oneline --graph
```

## Commit Message Template

When rewording commits or creating new ones during splits, use this structure:

```
<type>(<scope>): <Intent - what this accomplishes>

<Context - why the code does what it does now>

<Justification - why THIS approach was chosen>

<Implementation - how it was done, if not obvious>

<Footer - breaking changes, issue refs>
```

**Example**:

```
fix(auth): prevent token reuse after logout

Currently, JWT tokens remain valid until expiration even after user
logout, allowing potential security issues if tokens are compromised.

To invalidate tokens immediately on logout, maintain a token blocklist
in Redis with TTL matching token expiration. Check blocklist in auth
middleware before validating token claims.

BREAKING CHANGE: Requires Redis instance for auth service
```

See `references/commit-message-framework.md` for detailed guidance.

## Workflow Summary

When asked to refine commits, follow this process:

1. **Review current state**
   ```bash
   git log --oneline --graph
   git status
   ```

2. **Outline the narrative**
   - What story should these commits tell?
   - What's the logical order?
   - Which commits should be combined?
   - Which should be split?

3. **Start interactive rebase**
   ```bash
   git rebase -i main
   ```

4. **Execute refinements**
   - Reorder: cut/paste lines
   - Combine: use `squash` or `fixup`
   - Split: use `edit`, then `reset` and `add -p`
   - Improve messages: use `reword`

5. **Verify results**
   ```bash
   git log --oneline --graph
   # Ensure builds and tests pass
   ```

6. **Document narrative**
   - Include commit outline in PR description
   - Explain the story being told

## Integration with Other Skills

- **commit-work skill**: Use for creating new commits with proper workflow
- **commit-refinement skill** (this): Use for polishing and organizing existing commits
- **session-close skill**: Use for final verification before ending session

Load this skill when the user asks to:
- "Clean up commits"
- "Rewrite history"
- "Prepare commits for PR"
- "Organize my commits"
- "Split this commit"
- "Improve commit messages"

## Common Patterns and Anti-Patterns

### Good Patterns
- **Linear feature build**: Foundation → Core → Polish → Tests
- **Refactor-then-implement**: Extract → Simplify → Add feature
- **Bug fix narrative**: Reproduce → Fix → Verify

### Anti-Patterns to Fix
- **Stream of consciousness**: WIP, More WIP, Fix typo, Actually fix it
- **Topic jumping**: Feature A → Feature B → Back to A → Back to B
- **Mixed concerns**: One commit touching frontend + backend + tests + docs
- **Fix-up hell**: Feature commit followed by many small fixes

See `references/commit-narrative-patterns.md` for detailed examples.

## References

Comprehensive guides are available in the `references/` directory:

- **interactive-rebase-guide.md**: Step-by-step rebase workflows, conflict resolution, troubleshooting
- **commit-narrative-patterns.md**: Examples of organizing commits into coherent stories
- **commit-message-framework.md**: Deep dive on the What/Why matrix, examples at different complexity levels
- **git-investigation-tools.md**: Using git blame, log, and bisect (shows why quality commits matter)

## Verification Checklist

Before finishing refinement, verify:

- [ ] Commits follow a clear narrative (can explain the story)
- [ ] Each commit is atomic (builds and tests pass)
- [ ] Each commit is small (does one thing)
- [ ] Commit messages answer what and why
- [ ] Commits are ordered logically (foundation before feature)
- [ ] Building block types aren't mixed in commits
- [ ] No WIP or "fix typo" commits remain
- [ ] PR description includes commit outline

## External Resources

This skill is based on GitHub's article:
- ["Write Better Commits, Build Better Projects"](https://github.blog/developer-skills/github/write-better-commits-build-better-projects/) by Victoria Dye

Additional resources:
- [Git Organized: A Better Git Flow](https://render.com/blog/git-organized-a-better-git-flow)
- [My Favourite Git Commit](https://dhwthompson.com/2019/my-favourite-git-commit)
- [A Note About Git Commit Messages](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
