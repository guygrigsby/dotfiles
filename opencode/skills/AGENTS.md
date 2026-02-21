# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Planning & Tracking

**For simple tasks (<3 steps, single session):** Use TodoWrite (ephemeral)  
**For complex work (multi-session, dependencies):** Use beads-planning skill (persistent)

**Automatic detection:** Agent will proactively suggest beads when detecting:
- Work with 3+ distinct steps
- Multi-file/component changes
- Dependencies or blockers
- Multi-session work

**Override:** Say "use TodoWrite only" to suppress beads suggestions

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Git Push Behavior

**Configuration**: `bd config get workflow.git_push`

- **"ask"** (default): Agent prepares push, then asks permission before executing
- **"auto"**: Agent pushes automatically during session close
- **"never"**: Agent never pushes, only reminds you to push manually

**Set behavior**: `bd config set workflow.git_push "ask|auto|never"`

**Scope**:
- Applies to: `git push` and `jj git push` operations performed by the agent
- Does NOT apply to: `bd sync` (manages its own git operations)
- Default when unset: "ask" (safer)

**Override**: Say "auto-push this time" to bypass the setting temporarily

**Multi-push**: When pushing multiple branches/bookmarks, agent asks once for all

**Push failure**: On failure, agent shows error and auto-retries after you review it

**Session close without push**: If you skip the push, agent creates a beads issue to track unpushed changes

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - Check push configuration:
   ```bash
   # Check config: bd config get workflow.git_push
   # If "ask" (default): prepare push, then ASK for permission
   # If "auto": push automatically
   # If "never": skip push, create tracking issue
   
   git pull --rebase    # or: jj git fetch && jj rebase -d main
   bd sync              # sync beads changes
   git push             # or: jj git push -b <bookmark>
   git status           # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Check `workflow.git_push` config to determine push behavior
- If "ask": Prepare push, show summary, wait for confirmation
- If "auto": Push automatically after preparation
- If "never" OR user declines push: Create beads issue for unpushed changes
- If push fails: Show error, auto-retry after user reviews
- Work is properly closed when EITHER pushed successfully OR tracked in beads

