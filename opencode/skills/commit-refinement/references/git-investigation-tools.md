# Git Investigation Tools

## Introduction

Git provides powerful tools for investigating code history, finding bugs, and understanding why code exists. These tools are most effective when commits are well-crafted—atomic, focused, and clearly explained.

This guide covers four essential Git investigation tools:
- **git blame**: Find who changed each line
- **git log**: Search commit history
- **git bisect**: Find bug-introducing commits
- **git show**: View specific commits in detail

**Key insight**: Quality commits make these tools 10x more useful. Clear messages make searches effective, atomic commits make blame precise, and small commits make bisect efficient.

## Tool 1: git blame

### What It Does

`git blame` annotates each line of a file with the commit that last modified it, showing:
- Commit hash
- Author
- Date
- Line content

This answers the question: "Who wrote this code and when?"

### Basic Usage

```bash
# Blame entire file
git blame <file>

# Blame specific line range
git blame -L 10,20 <file>

# Example
git blame src/auth.js
```

### Output Format

```
abd52642 (John Doe   2024-01-15 14:23:42 +0000  1) import express from 'express';
603ab927 (Jane Smith 2024-01-20 09:15:33 +0000  2) import jwt from 'jsonwebtoken';
603ab927 (Jane Smith 2024-01-20 09:15:33 +0000  3)
abd52642 (John Doe   2024-01-15 14:23:42 +0000  4) export function authenticate(req, res, next) {
9c5e8a3f (Jane Smith 2024-02-01 11:42:18 +0000  5)   const token = req.headers.authorization;
9c5e8a3f (Jane Smith 2024-02-01 11:42:18 +0000  6)   if (!token) {
9c5e8a3f (Jane Smith 2024-02-01 11:42:18 +0000  7)     return res.status(401).json({ error: 'No token' });
```

Each line shows: `<hash> (<author> <date> <line-num>) <content>`

### Useful Options

#### Show Short Hashes

```bash
git blame -s <file>
```

Output:
```
abd52642  1) import express from 'express';
603ab927  2) import jwt from 'jsonwebtoken';
```

#### Show Email Addresses

```bash
git blame -e <file>
```

Output:
```
abd52642 (<john@example.com> 2024-01-15  1) import express from 'express';
```

#### Ignore Whitespace Changes

```bash
git blame -w <file>
```

Skips commits that only changed whitespace (useful after reformatting).

#### Ignore Specific Commits

```bash
# Ignore a formatting commit
git blame --ignore-rev abc1234 <file>

# Ignore multiple commits
git blame --ignore-rev abc1234 --ignore-rev def5678 <file>

# Use ignore file
git config blame.ignoreRevsFile .git-blame-ignore-revs
```

**`.git-blame-ignore-revs` file**:
```
# Formatting commits to ignore
abc1234567890  # Applied Prettier formatting
def1234567890  # Fixed indentation project-wide
```

#### Follow File Renames

```bash
git blame -M <file>
```

Tracks changes across file renames.

#### Copy Detection

```bash
git blame -C <file>
```

Detects when code was copied from other files.

### Common Use Cases

#### Use Case 1: "Why does this code exist?"

```bash
# Find the commit that added a line
git blame src/auth.js | grep "blocklist"

# Output shows commit hash
9c5e8a3f ... if (isInBlocklist(token)) {

# View full commit message
git show 9c5e8a3f
```

Now you can read the commit message to understand why blocklisting was added.

#### Use Case 2: "Who can I ask about this?"

```bash
# See who's modified this file recently
git blame src/auth.js

# Or use log for more context
git shortlog -sn src/auth.js
```

Output:
```
    15  Jane Smith
     8  John Doe
     3  Alice Johnson
```

Jane Smith is likely the expert on this code.

#### Use Case 3: "When did this change?"

```bash
# Find when a specific line was modified
git blame -L 42,42 src/auth.js

# Output
9c5e8a3f (Jane Smith 2024-02-01 11:42:18 +0000 42)   return res.status(401).json({ error: 'Invalid token' });
```

Changed February 1, 2024 in commit 9c5e8a3f.

### How Commit Quality Helps

**Good commits make blame effective**:
- ✅ Clear messages explain WHY code exists
- ✅ Atomic commits show exact context of change
- ✅ Small commits make blame more precise

**Poor commits hurt blame**:
- ❌ "Fix stuff" messages provide no insight
- ❌ Mega commits blend unrelated changes
- ❌ Formatting commits obscure real changes

## Tool 2: git log

### What It Does

`git log` searches and displays commit history, allowing you to:
- Filter by file, author, date, or message
- Search for specific code changes
- Trace function evolution
- Find commits by content

### Basic Usage

```bash
# View all commits
git log

# One line per commit
git log --oneline

# With graph visualization
git log --oneline --graph

# Example output
* 9c5e8a3 (HEAD -> main) fix(auth): prevent token reuse after logout
* 603ab92 feat(auth): add JWT authentication
* abd5264 refactor(api): extract error handling middleware
```

### Filtering by File

```bash
# Commits affecting a file
git log <file>

# Example
git log src/auth.js

# Follow file across renames
git log --follow src/auth.js

# Show actual changes (patch format)
git log -p src/auth.js
```

### Filtering by Function

```bash
# See changes to a specific function
git log -L :<function-name>:<file>

# Example
git log -L :authenticate:src/auth.js
```

This shows all commits that modified the `authenticate` function.

### Filtering by Line Range

```bash
# Changes to specific lines
git log -L <start>,<end>:<file>

# Example: lines 10-20
git log -L 10,20:src/auth.js

# Can also use function name as start
git log -L :authenticate,+10:src/auth.js
```

### Searching Commit Messages

```bash
# Find commits mentioning "auth"
git log --grep="auth"

# Case-insensitive
git log --grep="auth" -i

# Multiple patterns (OR)
git log --grep="auth" --grep="login"

# Multiple patterns (AND)
git log --grep="auth" --grep="login" --all-match

# Invert match (exclude)
git log --grep="auth" --invert-grep
```

### Filtering by Author

```bash
# Commits by specific author
git log --author="Jane Smith"

# Partial match works
git log --author="Jane"

# Multiple authors
git log --author="Jane\|John"
```

### Filtering by Date

```bash
# Since a date
git log --since="2024-01-01"

# Between dates
git log --after="2024-01-01" --before="2024-02-01"

# Relative dates
git log --since="2 weeks ago"
git log --since="3 days ago"
git log --until="yesterday"
```

### Filtering by Changes (Pickaxe)

```bash
# Find commits that added or removed a string
git log -S "function_name"

# Example: when was "authenticate" added/removed?
git log -S "authenticate"

# With patch to see actual changes
git log -S "authenticate" -p
```

**Difference from grep**: `-S` finds when the count of occurrences changed, not just mentions in messages.

### Filtering by Changes (Regex)

```bash
# Like -S but with regex
git log -G "regex pattern"

# Example: find when function signature changed
git log -G "function authenticate\(.*\)"
```

### Useful Options

#### Show Statistics

```bash
# Lines added/removed per commit
git log --stat

# Compact stats
git log --shortstat

# Name and status of changed files only
git log --name-status
```

#### Show Graph

```bash
# ASCII graph of branch structure
git log --graph --oneline

# Prettier version
git log --graph --oneline --decorate --all
```

#### Limit Output

```bash
# Last N commits
git log -n 5

# Or
git log -5
```

### Combining Filters

Filters can be combined for powerful searches:

```bash
# Find authentication-related commits by Jane in January
git log --author="Jane" \
        --grep="auth" \
        --since="2024-01-01" \
        --until="2024-02-01"

# Find when blocklist functionality was added
git log -S "blocklist" --all --source --pretty=oneline
```

### Common Use Cases

#### Use Case 1: "What changed in this file?"

```bash
# Overview of changes
git log --oneline src/auth.js

# Detailed with diffs
git log -p src/auth.js
```

#### Use Case 2: "How has this function evolved?"

```bash
# Track function changes over time
git log -L :authenticate:src/auth.js --oneline

# With full diffs
git log -L :authenticate:src/auth.js -p
```

#### Use Case 3: "When was this feature added?"

```bash
# Search commit messages
git log --grep="password reset" --oneline

# Search code changes
git log -S "sendPasswordResetEmail" --oneline
```

#### Use Case 4: "What did Jane work on last week?"

```bash
git log --author="Jane" --since="1 week ago" --oneline
```

#### Use Case 5: "Has this been tried before?"

```bash
# Search for old feature, even if deleted
git log --all -S "old_feature_name"

# View the commit
git show <commit-hash>
```

### How Commit Quality Helps

**Good commits make log searches powerful**:
- ✅ Descriptive messages make --grep effective
- ✅ Focused commits make -L line/function search precise
- ✅ Narrative structure makes history comprehensible
- ✅ Conventional Commits enable type-based searches

**Poor commits hurt log searches**:
- ❌ Vague messages don't surface in --grep
- ❌ Mega commits obscure specific changes
- ❌ Mixed concerns make -L searches noisy

## Tool 3: git bisect

### What It Does

`git bisect` performs binary search through commit history to find which commit introduced a bug. Given a "good" commit (working) and a "bad" commit (broken), Git checks out commits in between for testing.

**How it works**:
1. Start bisect with known good and bad commits
2. Git checks out middle commit
3. You test and mark as good or bad
4. Git narrows range and repeats
5. Git identifies first bad commit

**Efficiency**: For 100 commits, bisect finds the culprit in ~7 tests (log₂(100) ≈ 7).

### Basic Workflow

```bash
# 1. Start bisect
git bisect start

# 2. Mark current commit as bad
git bisect bad

# 3. Mark a known good commit
git bisect good v1.2.0

# Git says: "Bisecting: 15 revisions left to test after this"
# Git checks out middle commit

# 4. Test the code
npm test  # Or however you verify

# 5. Mark result
git bisect good  # If tests pass
# or
git bisect bad   # If tests fail

# 6. Repeat steps 4-5 until Git finds the commit
# Git will say: "abc1234 is the first bad commit"

# 7. View the bad commit
git show abc1234

# 8. End bisect
git bisect reset
```

### Automated Bisect

Instead of manually testing each commit, provide a test script:

```bash
git bisect start HEAD v1.2.0
git bisect run ./test-script.sh
```

**`test-script.sh` requirements**:
- Exit 0 if test passes (good commit)
- Exit 1-127 (except 125) if test fails (bad commit)
- Exit 125 if commit can't be tested (Git skips it)

**Example test script**:
```bash
#!/bin/bash
npm install --quiet
npm test --silent
```

Git will automatically bisect and find the bad commit.

### Detailed Example

**Scenario**: Deployment is broken, last known good version was v1.5.0.

```bash
# Start bisect
$ git bisect start

# Current version is broken
$ git bisect bad

# v1.5.0 was working
$ git bisect good v1.5.0
Bisecting: 12 revisions left to test after this (roughly 4 steps)
[abc1234] Add caching layer

# Test this commit
$ npm test
# Tests pass!

$ git bisect good
Bisecting: 6 revisions left to test after this (roughly 3 steps)
[def5678] Update authentication logic

# Test this commit
$ npm test
# Tests fail!

$ git bisect bad
Bisecting: 3 revisions left to test after this (roughly 2 steps)
[ghi9012] Refactor database queries

# Test this commit
$ npm test
# Tests pass!

$ git bisect good
Bisecting: 1 revision left to test after this (roughly 1 step)
[jkl3456] Add Redis blocklist

# Test this commit
$ npm test
# Tests fail!

$ git bisect bad
Bisecting: 0 revisions left to test after this
[jkl3456] is the first bad commit

# View the problematic commit
$ git show jkl3456

# End bisect
$ git bisect reset
```

Now you know commit `jkl3456` introduced the bug!

### Advanced Usage

#### Skip Untestable Commits

```bash
# If a commit won't build
git bisect skip

# Git moves to another commit
```

#### Visualize Progress

```bash
# Show visual representation
git bisect visualize

# Or in oneline format
git bisect visualize --oneline
```

#### View Bisect Log

```bash
# See what's been tested
git bisect log

# Output:
# git bisect start
# git bisect bad abc1234
# git bisect good def5678
# git bisect good ghi9012
```

#### Replay Bisect

```bash
# Save bisect log
git bisect log > bisect-log.txt

# Later, replay it
git bisect replay bisect-log.txt
```

### Why Atomic Commits Matter

**Bisect REQUIRES atomic commits**:
- ✅ Each commit must build successfully
- ✅ Each commit must pass tests (until the bug is introduced)
- ✅ Can't bisect through broken commits

**If commits aren't atomic**:
- ❌ Bisect encounters build failures
- ❌ Can't determine if commit is good or bad
- ❌ Must use `git bisect skip` frequently
- ❌ Loses efficiency (binary search degrades)

**Example of problem**:

```
Commit A: ✅ Works
Commit B: ❌ Doesn't build (incomplete change)
Commit C: ✅ Completes commit B
Commit D: ❌ Has the bug
```

Bisect will get stuck at commit B, can't test it. Even if you skip it, you can't be sure if the bug is in B or C.

**With atomic commits**:

```
Commit A: ✅ Works
Commit B: ✅ Works
Commit C: ✅ Works
Commit D: ❌ Has the bug
```

Bisect efficiently identifies commit D as the culprit.

### Common Use Cases

#### Use Case 1: "When did this break?"

```bash
git bisect start HEAD v1.4.0
git bisect run npm test
```

Find the commit that broke tests.

#### Use Case 2: "When did performance degrade?"

```bash
# test-performance.sh checks if API responds in < 100ms
git bisect start HEAD v1.3.0
git bisect run ./test-performance.sh
```

#### Use Case 3: "When did this feature disappear?"

```bash
# test-feature.sh checks if feature exists
git bisect start HEAD v2.0.0
git bisect run ./test-feature.sh
```

### Tips for Effective Bisecting

1. **Start with wide range**: Use tags or old commits to maximize search space
2. **Automate when possible**: Write test scripts for consistency
3. **Keep commits atomic**: Make bisect actually work
4. **Test the same way each time**: Consistent test = reliable results
5. **Read commit messages**: Once you find the bad commit, understand why it was made

## Tool 4: git show

### What It Does

`git show` displays detailed information about a specific Git object (usually a commit), including:
- Commit metadata (author, date, message)
- Full diff of changes

### Basic Usage

```bash
# Show a specific commit
git show <commit-hash>

# Show HEAD
git show

# Show previous commit
git show HEAD~1

# Show specific file in a commit
git show <commit>:<file>
```

### Examples

#### View Commit Details

```bash
$ git show abc1234

commit abc1234567890abcdef1234567890abcdef1234
Author: Jane Smith <jane@example.com>
Date:   Thu Feb 1 11:42:18 2024 +0000

    fix(auth): prevent token reuse after logout
    
    Currently, JWT tokens remain valid until expiration even
    after user logout, allowing security issues if intercepted.
    
    Add token blocklist in Redis to invalidate on logout.
    
    BREAKING CHANGE: Requires Redis instance

diff --git a/src/auth.js b/src/auth.js
index abc1234..def5678 100644
--- a/src/auth.js
+++ b/src/auth.js
@@ -42,6 +42,9 @@ export function authenticate(req, res, next) {
   const token = req.headers.authorization;
+  if (isInBlocklist(token)) {
+    return res.status(401).json({ error: 'Token invalidated' });
+  }
```

#### View File at Specific Commit

```bash
# See what auth.js looked like in commit abc1234
git show abc1234:src/auth.js
```

#### Show Only Stats

```bash
# Summary without full diff
git show --stat abc1234

# Output:
#  src/auth.js     | 12 +++++++++---
#  src/blocklist.js | 45 +++++++++++++++++++++++++++++++++++++++++++++
#  2 files changed, 54 insertions(+), 3 deletions(-)
```

### Common Use Cases

#### Use Case 1: "What exactly changed in this commit?"

After finding a commit with `git blame` or `git log`:

```bash
git show abc1234
```

Read the message and review the diff.

#### Use Case 2: "What did this file look like before?"

```bash
# Current version
cat src/auth.js

# Version from 3 commits ago
git show HEAD~3:src/auth.js

# Version from specific commit
git show abc1234:src/auth.js
```

#### Use Case 3: "Compare commit message to implementation"

```bash
git show abc1234
```

Verify that the code changes match what the commit message claims.

## Combining Tools for Investigation

The real power comes from using these tools together.

### Scenario 1: "Why does this code exist?"

**Workflow**:

1. **Find the commit** with `git blame`:
   ```bash
   git blame src/auth.js | grep "blocklist"
   # Output: abc1234 ... if (isInBlocklist(token)) {
   ```

2. **View commit details** with `git show`:
   ```bash
   git show abc1234
   ```

3. **See function evolution** with `git log`:
   ```bash
   git log -L :authenticate:src/auth.js --oneline
   ```

**Result**: Complete understanding of why blocklist was added and how authentication evolved.

### Scenario 2: "When did this break?"

**Workflow**:

1. **Find the breaking commit** with `git bisect`:
   ```bash
   git bisect start HEAD v1.4.0
   git bisect run npm test
   # Result: abc1234 is the first bad commit
   ```

2. **Examine the bad commit** with `git show`:
   ```bash
   git show abc1234
   ```

3. **See surrounding commits** with `git log`:
   ```bash
   git log abc1234~3..abc1234
   ```

**Result**: Identified exact commit that broke tests and context around it.

### Scenario 3: "Who can I ask about this?"

**Workflow**:

1. **Find recent contributors** with `git log`:
   ```bash
   git log --since="3 months ago" src/auth.js --format="%an" | sort | uniq -c | sort -rn
   ```
   
   Output:
   ```
       12 Jane Smith
        5 John Doe
        2 Alice Johnson
   ```

2. **See what they changed** with `git log`:
   ```bash
   git log --author="Jane" --oneline src/auth.js
   ```

3. **View specific commits** with `git show`:
   ```bash
   git show abc1234 def5678 ghi9012
   ```

**Result**: Identified expert (Jane) and understood her contributions.

### Scenario 4: "Has this been tried before?"

**Workflow**:

1. **Search all history** with `git log`:
   ```bash
   git log --all --grep="OAuth" --oneline
   ```

2. **Search code** with pickaxe:
   ```bash
   git log --all -S "OAuthProvider" --oneline
   ```

3. **View old implementation** with `git show`:
   ```bash
   git show abc1234
   ```

**Result**: Discovered OAuth was tried before, read commit to see why it was removed.

## Best Practices

### For All Tools

1. **Read commit messages first**: They often answer your questions immediately
2. **Use --oneline for overview**: Get the big picture before drilling down
3. **Combine tools**: Each tool provides different view of history
4. **Trust good commits**: If commits are high quality, rely on them

### For git blame

- Ignore formatting commits with `--ignore-rev`
- Use `-w` to ignore whitespace
- Follow renames with `-M`
- Remember: blame shows last change, not origin

### For git log

- Start broad, then filter: `git log → git log <file> → git log -L`
- Use `--oneline` for quick scans
- Use `-p` for full context
- Combine filters for powerful searches

### For git bisect

- Ensure commits are atomic before bisecting
- Automate with test scripts when possible
- Use tags as good/bad markers when available
- Read commit message after finding bad commit

### For git show

- Use after finding commits with other tools
- Compare message to implementation
- Check surrounding commits for context

## How This Connects to Commit Quality

These tools demonstrate WHY commit quality matters:

### Clear Messages

- ✅ `git log --grep` finds relevant commits
- ✅ Messages answer "why" instantly
- ✅ No need to read code to understand intent

### Atomic Commits

- ✅ `git bisect` works reliably
- ✅ Can roll back to any commit safely
- ✅ Each commit tells complete story

### Small Commits

- ✅ `git blame` is precise
- ✅ `git log -L` shows focused changes
- ✅ Easy to understand individual changes

### Narrative Structure

- ✅ `git log --oneline` shows progression
- ✅ History makes sense chronologically
- ✅ Can follow feature development

**Bottom line**: Invest time in commit quality, and these tools will make you 10x more productive.

## Quick Reference

```bash
# git blame
git blame <file>                      # Who changed each line
git blame -L 10,20 <file>            # Specific lines
git blame -w <file>                  # Ignore whitespace
git blame --ignore-rev <commit> <file>  # Ignore commit

# git log
git log                               # All commits
git log --oneline                     # One line per commit
git log <file>                        # File history
git log -L :function:<file>           # Function history
git log -L 10,20:<file>              # Line range history
git log --grep="pattern"              # Search messages
git log -S "string"                   # Search code changes
git log --author="name"               # By author
git log --since="date"                # By date

# git bisect
git bisect start                      # Start bisecting
git bisect bad                        # Mark as bad
git bisect good <commit>              # Mark as good
git bisect good/bad                   # Mark current
git bisect skip                       # Skip untestable
git bisect reset                      # End bisect
git bisect run <script>               # Automate

# git show
git show <commit>                     # Show commit
git show <commit>:<file>              # Show file version
git show --stat <commit>              # Summary only
```

---

**Remember**: These tools are only as good as your commits. Write quality commits, and these tools become your superpower for understanding codebases!
