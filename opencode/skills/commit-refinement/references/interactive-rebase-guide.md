# Interactive Rebase Guide

## Overview

Interactive rebase (`git rebase -i`) is the primary tool for refining commit history. It allows you to:

- **Reorder** commits to tell a better story
- **Split** commits that do too many things
- **Combine** commits that should be one unit
- **Reword** commit messages to add context
- **Drop** commits that shouldn't exist
- **Edit** commits to modify their content

Interactive rebase is a powerful tool for commit refinement, but it should be used carefully. This guide provides step-by-step workflows for common scenarios.

## When to Use Interactive Rebase

**Good use cases**:
- ✅ Cleaning up commits before opening a PR
- ✅ Organizing work-in-progress commits into logical units
- ✅ Fixing commit messages that lack context
- ✅ Removing debug/WIP commits
- ✅ Splitting commits that mix concerns
- ✅ Combining related commits

**When NOT to use**:
- ❌ After opening a pull request (breaks review context)
- ❌ On commits that others have based work on
- ❌ On public branches without team coordination
- ❌ When you're unsure what you're doing (practice on a backup branch first!)

## Starting an Interactive Rebase

### Syntax

```bash
# Rebase from a base branch
git rebase -i <base>

# Common bases
git rebase -i main
git rebase -i develop
git rebase -i origin/main

# Rebase last N commits
git rebase -i HEAD~3   # Last 3 commits
git rebase -i HEAD~5   # Last 5 commits

# Rebase from a specific commit (exclusive)
git rebase -i abc123   # Everything after commit abc123
```

### What Happens

When you start an interactive rebase, Git:
1. Opens your default editor with the **rebase-todo** file
2. Lists commits from **oldest (top)** to **newest (bottom)**
3. Waits for you to modify the todo list
4. Executes the instructions when you save and close

## The Rebase Todo File

### Format

```
pick abc1234 First commit message
pick def5678 Second commit message
pick ghi9012 Third commit message

# Rebase abc0000..ghi9012 onto abc0000 (3 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# d, drop <commit> = remove commit
```

### Important Notes

- **Commits are listed oldest to newest** (opposite of `git log`)
- **Lines are executed top to bottom**
- **Comment lines** (starting with `#`) are ignored
- **Deleting a line** drops that commit
- **Reordering lines** reorders commits
- **Changing the command** changes what happens to that commit

## Rebase Commands Reference

### pick - Use Commit As-Is

**Command**: `pick` or `p`

**What it does**: Applies the commit without changes.

**When to use**: Default for commits that are already good.

**Example**:
```
pick abc1234 Add user authentication
pick def5678 Add login form
```

### reword - Change Commit Message

**Command**: `reword` or `r`

**What it does**: Applies the commit, then pauses to let you edit the message.

**When to use**: Commit is good but message needs improvement (add context, fix typo, etc.)

**Example**:
```
pick abc1234 Add user authentication
reword def5678 Add login form   # Will pause to edit this message
pick ghi9012 Add logout button
```

**Workflow**:
1. Mark commit as `reword`
2. Save and close rebase-todo
3. Git pauses and opens editor with commit message
4. Edit the message
5. Save and close
6. Rebase continues automatically

### edit - Stop to Modify Commit

**Command**: `edit` or `e`

**What it does**: Applies the commit, then pauses so you can amend it.

**When to use**: Need to change the commit's code, split it, or make other modifications.

**Example**:
```
pick abc1234 Add user authentication
edit def5678 Add login and logout forms  # Will pause here
pick ghi9012 Add styling
```

**Workflow**:
1. Mark commit as `edit`
2. Save and close rebase-todo
3. Git pauses after applying the commit
4. Make changes:
   - Amend: `git commit --amend`
   - Split: See "Splitting Commits" section below
   - Other modifications
5. Continue: `git rebase --continue`

### squash - Combine with Previous, Edit Message

**Command**: `squash` or `s`

**What it does**: Combines this commit with the previous commit and prompts for a new message combining both.

**When to use**: Multiple commits represent one logical change and you want a new combined message.

**Example**:
```
pick abc1234 Add user authentication
squash def5678 Fix auth validation bug  # Combine into abc1234
pick ghi9012 Add logout button
```

**Workflow**:
1. Mark commit as `squash`
2. Save and close rebase-todo
3. Git pauses and shows combined message in editor
4. Edit to create final message
5. Save and close
6. Rebase continues

**Combined message example**:
```
# This is a combination of 2 commits.
# This is the 1st commit message:

Add user authentication

# This is the commit message #2:

Fix auth validation bug

# Please enter the commit message for your changes...
```

### fixup - Combine with Previous, Keep Original Message

**Command**: `fixup` or `f`

**What it does**: Combines this commit with the previous commit and discards this commit's message.

**When to use**: Silently fixing issues in previous commits (typos, small bugs, forgotten files).

**Example**:
```
pick abc1234 Add user authentication
fixup def5678 Fix typo in auth.js       # Silently merge into abc1234
fixup ghi9012 Add missing import        # Also merge into abc1234
pick jkl3456 Add logout button
```

Result: The auth commit will contain all three commits' changes but only the first message.

### drop - Remove Commit

**Command**: `drop` or `d` (or just delete the line)

**What it does**: Removes the commit from history.

**When to use**: Debug commits, accidental commits, work you decided not to include.

**Example**:
```
pick abc1234 Add user authentication
drop def5678 Add debug logging         # Remove this commit
pick ghi9012 Add logout button
```

**Alternative**: Just delete the line instead of using `drop`.

## Common Workflows

### Workflow 1: Reordering Commits

**Goal**: Change the order of commits to tell a better story.

**Steps**:
1. Start rebase: `git rebase -i main`
2. In the editor, cut and paste lines to reorder
3. Save and close
4. Resolve any conflicts that arise (see Conflict Resolution)

**Example**:

**Before** (narrative jumps around):
```
pick abc1234 Add authentication
pick def5678 Add styling
pick ghi9012 Add logout feature
pick jkl3456 Add login form
```

**After** (logical order):
```
pick abc1234 Add authentication
pick jkl3456 Add login form      # Moved up - login before logout
pick ghi9012 Add logout feature
pick def5678 Add styling         # Moved down - feature before styling
```

**Why reorder?**
- Group related commits together
- Put foundation before features
- Put features before polish/styling
- Create a narrative that builds logically

### Workflow 2: Splitting a Commit

**Goal**: Break one commit into multiple logical commits.

**When**: Commit does multiple distinct things that should be separate.

**Steps**:

1. Start rebase and mark commit as `edit`:
   ```
   git rebase -i main
   ```
   
   ```
   pick abc1234 Add authentication
   edit def5678 Add login form and validation  # Mark as edit
   pick ghi9012 Add styling
   ```

2. When rebase pauses, undo the commit:
   ```bash
   git reset HEAD~
   ```
   
   This leaves changes in your working directory but removes the commit.

3. Stage and commit first logical unit:
   ```bash
   git add -p  # Interactively select changes for login form
   git commit -m "Add login form UI"
   ```

4. Stage and commit second logical unit:
   ```bash
   git add -p  # Interactively select changes for validation
   git commit -m "Add login form validation"
   ```

5. Continue the rebase:
   ```bash
   git rebase --continue
   ```

**Detailed Example**:

Original commit mixed UI and validation:
```
def5678 Add login form and validation
  - login.html (form markup)
  - login.css (form styling)
  - validate.js (validation logic)
  - api.js (API integration)
```

After splitting:
```
def5678 Add login form UI
  - login.html
  - login.css

abc9999 Add login form validation
  - validate.js
  - api.js
```

**Tips for splitting**:
- Use `git add -p` for fine-grained control
- Use `git diff --cached` to verify what you're committing
- Ensure each new commit is atomic (builds and tests pass)
- If you make a mistake, `git rebase --abort` and try again

### Workflow 3: Combining Commits

**Goal**: Merge multiple commits into one logical unit.

**When**: 
- Multiple commits represent one feature
- WIP commits should be consolidated
- "Fix typo" commits should merge into original
- Related refactoring commits

**Using fixup** (silent merge):

```
pick abc1234 Add user authentication
fixup def5678 Fix auth bug              # Silent merge
fixup ghi9012 Add missing test          # Silent merge
pick jkl3456 Add logout button
```

Result: One commit with message "Add user authentication"

**Using squash** (edit combined message):

```
pick abc1234 Add user authentication
squash def5678 Add password hashing     # Combine with message edit
pick ghi9012 Add logout button
```

When Git pauses, you can create a new message like:
```
Add user authentication with password hashing

Implements JWT-based authentication with bcrypt password hashing.
Includes login, signup, and token validation middleware.
```

**Combining multiple commits**:

```
pick abc1234 WIP: start auth
squash def5678 WIP: finish auth
squash ghi9012 Add auth tests
```

Creates one commit with a new message combining all three.

### Workflow 4: Rewording Messages

**Goal**: Improve commit messages without changing code.

**When**:
- Message is vague ("Fix bug", "WIP")
- Message lacks context (no "why")
- Typo in message
- Need to add more detail

**Steps**:

1. Start rebase and mark commits as `reword`:
   ```
   git rebase -i main
   ```
   
   ```
   pick abc1234 Add authentication
   reword def5678 Fix bug              # Improve this message
   pick ghi9012 Add styling
   ```

2. When Git pauses, editor opens with current message:
   ```
   Fix bug
   
   # Please enter the commit message...
   ```

3. Rewrite with context:
   ```
   fix(auth): prevent null pointer when email is missing
   
   Login form didn't validate email field presence before
   calling toLowerCase(), causing crashes on submit.
   
   Add null check before string operations.
   ```

4. Save and close, rebase continues

**Tips**:
- Follow the What/Why framework
- Use Conventional Commits format: `type(scope): subject`
- Explain context and justification
- Keep subject line under 72 characters

### Workflow 5: Cleaning Up WIP Commits

**Goal**: Transform stream-of-consciousness commits into organized logical units.

**Before**:
```
abc1234 WIP
def5678 More WIP
ghi9012 Fix typo
jkl3456 Actually finish feature
mno7890 Fix another typo
pqr1234 Add tests
```

**After**:
```
abc1234 Add user authentication feature
pqr1234 Add authentication tests
```

**Steps**:

1. Combine all WIP commits:
   ```
   pick abc1234 WIP
   fixup def5678 More WIP
   fixup ghi9012 Fix typo
   fixup jkl3456 Actually finish feature
   fixup mno7890 Fix another typo
   pick pqr1234 Add tests
   ```

2. Reword the first commit:
   ```
   reword abc1234 WIP
   fixup def5678 More WIP
   ...
   ```

3. Write proper message when prompted:
   ```
   feat(auth): add user authentication feature
   
   Implements JWT-based authentication with login and signup endpoints.
   Tokens expire after 24 hours and are validated via middleware.
   ```

## Conflict Resolution

Conflicts can occur during rebase when changes in commits overlap.

### When Conflicts Happen

Most commonly when:
- Reordering commits that modify the same files
- Combining commits with overlapping changes
- Commits depend on each other in ways you didn't realize

### Resolving Conflicts

1. Git pauses and shows conflict:
   ```
   CONFLICT (content): Merge conflict in auth.js
   error: could not apply def5678... Add login form
   ```

2. View conflicted files:
   ```bash
   git status
   ```

3. Open conflicted files and resolve:
   ```javascript
   <<<<<<< HEAD
   function authenticate(user) {
       // Current version
   =======
   function authenticate(user, password) {
       // Incoming version
   >>>>>>> def5678 (Add login form)
   ```

4. Edit to keep correct version or combine:
   ```javascript
   function authenticate(user, password) {
       // Combined correct version
   }
   ```

5. Mark as resolved:
   ```bash
   git add auth.js
   ```

6. Continue rebase:
   ```bash
   git rebase --continue
   ```

### Conflict Resolution Commands

```bash
# Continue after resolving conflicts
git rebase --continue

# Skip this commit (use carefully!)
git rebase --skip

# Abort entire rebase and return to original state
git rebase --abort

# View what's conflicting
git status
git diff

# Use merge tool
git mergetool
```

### Tips for Avoiding Conflicts

- Rebase small batches of commits, not giant histories
- Understand dependencies between commits before reordering
- Keep a backup branch before major surgery
- Test frequently during complex rebases

## Safety and Best Practices

### The Safety Net: git reflog

`git reflog` is your safety net. It records all HEAD movements, including rebases.

```bash
# View all recent actions
git reflog

# Output shows:
abc1234 HEAD@{0}: rebase -i (finish): returning to refs/heads/feature
def5678 HEAD@{1}: rebase -i (squash): Add authentication
ghi9012 HEAD@{2}: rebase -i (start): checkout main
```

**Recovering from mistakes**:

```bash
# Find the reflog entry before rebase
git reflog

# Reset to that point
git reset --hard HEAD@{3}  # Or specific commit hash
```

This completely undoes the rebase as if it never happened.

### Before You Start

```bash
# View current state
git log --oneline --graph

# Create backup branch (optional but recommended for complex rebases)
git branch backup-branch

# Ensure working directory is clean
git status
```

### After You Finish

```bash
# Verify history looks correct
git log --oneline --graph

# Ensure code still works
git build  # Or your build command
git test   # Or your test command

# Compare with backup if you created one
git diff backup-branch

# Delete backup if everything is good
git branch -d backup-branch
```

### When NOT to Rebase

**Never rebase**:
- ❌ After pushing to a PR
- ❌ Commits on main/master/develop
- ❌ Commits others have pulled and based work on
- ❌ Public history without team agreement

**If you must rebase public commits** (rare):
- Coordinate with team first
- Use `git push --force-with-lease` (safer than `--force`)
- Notify everyone affected
- Only do during agreed maintenance windows

### Golden Rules

1. **Rebase before sharing**: Polish commits before opening PR
2. **Don't rebase after PR is open**: Add new commits instead
3. **Test after rebasing**: Ensure code still builds and tests pass
4. **Keep reflog in mind**: You can always undo with `git reset --hard`
5. **When in doubt, abort**: `git rebase --abort` is always available

## Troubleshooting

### "I'm in rebase and don't know where I am"

```bash
# See rebase status
git status

# See what's been done and what's left
cat .git/rebase-merge/git-rebase-todo

# Abort and start over
git rebase --abort
```

### "Rebase finished but history looks wrong"

```bash
# View what happened
git reflog

# Undo the rebase
git reset --hard HEAD@{before-rebase}

# Or reset to specific commit
git reset --hard abc1234
```

### "I have conflicts and don't know how to resolve them"

```bash
# See which files are conflicted
git status

# If conflicts are too complex, abort
git rebase --abort

# Try a different rebase strategy (smaller steps, different order)
```

### "I accidentally deleted a commit I wanted"

```bash
# Find commit in reflog
git reflog

# Cherry-pick it back
git cherry-pick abc1234

# Or reset to before the rebase
git reset --hard HEAD@{before-rebase}
```

### "Rebase says 'No rebase in progress'"

You might be trying to continue when nothing is happening. Check:

```bash
git status  # Should show clean if no rebase
git log  # Verify history is as expected
```

## Advanced Tips and Tricks

### Using --autosquash

If you create commits with `--fixup`:

```bash
git commit --fixup abc1234
```

Then rebase with `--autosquash`:

```bash
git rebase -i --autosquash main
```

Git automatically marks fixup commits correctly in the todo list!

**Configuration**:
```bash
# Enable autosquash by default
git config --global rebase.autosquash true
```

### Using --exec

Run a command after each commit during rebase:

```bash
git rebase -i --exec "npm test" main
```

This runs tests after applying each commit. If tests fail, rebase pauses for you to fix.

**Use cases**:
- Ensure every commit passes tests
- Verify code lints after each commit
- Check build succeeds throughout history

### Rebase Onto

Rebase current branch onto a different base:

```bash
# Currently on feature-branch based on old-main
git rebase --onto new-main old-main feature-branch
```

**Use case**: Update feature branch to newer base commit.

### Interactive Rebase Tips

- **Start small**: Practice on 2-3 commits before tackling larger rebases
- **Keep backup branch**: `git branch backup` before complex operations
- **Read the comments**: The rebase-todo file has helpful reminders
- **Verify incrementally**: After each major step, check `git log`
- **Test frequently**: Don't wait until end to discover broken code

## Summary Cheat Sheet

```bash
# Start interactive rebase
git rebase -i main
git rebase -i HEAD~5

# Rebase commands
pick    # Use commit as-is
reword  # Edit commit message
edit    # Stop to modify commit  
squash  # Combine with previous, edit message
fixup   # Combine with previous, discard message
drop    # Remove commit

# During rebase
git rebase --continue    # Continue after resolving conflicts
git rebase --skip        # Skip current commit
git rebase --abort       # Cancel entire rebase

# Safety net
git reflog               # View history of HEAD
git reset --hard HEAD@{n}  # Undo rebase

# Verification
git log --oneline --graph  # View commit history
git status                 # Check current state
```

## Practice Exercises

### Exercise 1: Reorder Three Commits

Create three commits in wrong order, then use interactive rebase to fix:

```bash
git commit -m "Add styling"
git commit -m "Add core feature"
git commit -m "Add foundation"

# Reorder to: foundation, feature, styling
git rebase -i HEAD~3
```

### Exercise 2: Split a Commit

Create a commit mixing two concerns, then split it:

```bash
# Make changes to both frontend and backend
git add .
git commit -m "Add feature"

# Split into frontend and backend commits
git rebase -i HEAD~1  # Mark as edit
git reset HEAD~
git add frontend/
git commit -m "Add frontend for feature"
git add backend/
git commit -m "Add backend for feature"
git rebase --continue
```

### Exercise 3: Clean Up WIP Commits

Create messy WIP commits, then consolidate:

```bash
git commit -m "WIP"
git commit -m "More WIP"
git commit -m "Fix typo"
git commit -m "Done"

# Combine into one commit
git rebase -i HEAD~4
# Use: pick, fixup, fixup, fixup
# Then reword the message
```

---

**Remember**: Interactive rebase is powerful. Practice on disposable branches, keep backups when learning, and use `git rebase --abort` whenever you feel unsure!
