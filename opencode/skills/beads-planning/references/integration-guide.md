# Beads Integration Guide

How beads-planning integrates with other skills and workflows.

---

## Integration with session-close

The `session-close` skill ensures work is properly committed and pushed. Beads tracking must be synced before git operations.

### Enhanced session-close Workflow

**Original session-close step 3:**
```
3. Update issue status - Close finished work, update in-progress items
```

**Enhanced with beads-planning:**
```bash
# Step 3: Update beads issues

# Close completed work
bd update skill-r3f.5 --status closed

# Update in-progress items with current state
bd update skill-r3f.6 --status ready --description "...
## Progress (2026-02-15)
- Added beads-planning to Planning section
- Still need to verify formatting in Quick Reference section"

# Create issues for remaining/discovered work
bd create task "Test beads proactive detection with real scenarios" \
  --parent skill-r3f --description "Validate agent suggests beads when:
- User describes complex feature (3+ steps)
- TodoWrite grows beyond 5 items
- Dependencies mentioned during planning"

bd create task "Add beads-planning to Development Workflow quick ref" \
  --parent skill-r3f
```

**Step 4: SQUASH FIXUP COMMITS**
```bash
# (session-close existing step - no changes)
if command -v gh >/dev/null 2>&1; then
  if gh pr view >/dev/null 2>&1; then
    echo "⚠️  Open PR detected - skipping rebase"
  else
    echo "✓  No PR found - safe to rebase"
    git rebase -i --autosquash origin/main
  fi
fi
```

**Step 5: PUSH TO REMOTE** (critical integration point)
```bash
# First: sync beads state
bd sync

# This commits .beads/ changes to git
# MUST happen before git push

# Then: standard git push workflow
git fetch origin
git status  # Verify clean state
git push origin HEAD:branch-name
git status  # MUST show "up to date with origin"
```

### Integration Point Summary

**When:** During session-close workflow  
**Where:** After updating code, before git push  
**Why:** Ensures beads tracking state is persisted with code changes

**Critical rule:** `bd sync` MUST run before `git push`

---

## Integration with session-handoff (Future)

The `session-handoff` skill creates comprehensive handoff documents for pausing work or transferring context. Beads provides structured work context.

### Proposed Handoff Document Enhancement

**Current handoff sections:**
- Summary of work completed
- Current state and context
- Next steps
- Known issues or blockers

**Enhanced with beads context:**

```markdown
## Active Beads Work

**Current Epic:** skill-r32 "Enable progressive disclosure across all skills"
- **Status:** In progress (5/8 tasks complete)
- **Owner:** Mike Palmiotto
- **Priority:** P2
- **Estimated remaining:** ~2-3 hours

### Completed Tasks
- ✅ skill-r32.1: Add context: fork frontmatter to all 5 skills
- ✅ skill-r32.2: Refactor domain-driven-design skill (714→150 lines + references)
- ✅ skill-r32.3: Refactor oltp-schema-design skill (606→150 lines + references)
- ✅ skill-r32.4: Review and enhance commit-refinement references
- ✅ skill-r32.5: Review and enhance commit-work references

### Current Task
**skill-r32.6:** Verify session-close doesn't need references
- **Status:** In progress (50% complete)
- **Started:** 2026-02-15 10:30
- **Notes:** Reviewed SKILL.md, it's only 140 lines and well-organized. Confirmed no refactoring needed.

### Remaining Tasks
- ⏸ skill-r32.7: Create progressive disclosure guidelines document (~1.5 hrs)

### Blockers
None

### Quick Resume Commands
```bash
# View full epic context
bd show skill-r32

# View current task
bd show skill-r32.6

# Resume work
bd update skill-r32.6 --status in_progress

# When complete
bd update skill-r32.6 --status closed
bd update skill-r32.7 --status in_progress
```

---

## Context for Next Session

**What was done:**
- Refactored two large skills (DDD, OLTP) using progressive disclosure
- Reduced context usage while preserving all content
- Enhanced commit-refinement and commit-work with better references

**What's in progress:**
- Verifying session-close skill doesn't need refactoring

**What's next:**
- Create guidelines document capturing patterns from this refactor

**Important notes:**
- Progressive disclosure pattern working well - skills fork context on demand
- Reference files organized by concept, not alphabetically
- Keep main SKILL.md under 200 lines for optimal context usage
```

### Benefits of Beads + Handoff Integration

1. **Structured context:** Clear epic → tasks → subtasks hierarchy
2. **Progress visibility:** Exact completion percentage and time estimates
3. **Quick resume:** Commands to immediately continue work
4. **Blocker tracking:** Dependencies and blockers explicitly documented
5. **Historical context:** Why decisions were made, what was tried

### Implementation Status

**Status:** Not yet implemented (session-handoff skill doesn't exist yet)  
**Priority:** Low (can add when session-handoff skill is created)  
**Effort:** ~30 minutes to enhance handoff template

---

## Integration with gepetto

The `gepetto` skill creates detailed implementation plans through research and stakeholder interviews. These plans map naturally to beads epics.

### Gepetto → Beads Conversion

**Gepetto output structure:**
```markdown
# Implementation Plan: Two-Factor Authentication

## Overview
[Executive summary]

## Requirements Analysis
[Detailed requirements]

## Technical Approach
[Architecture and design decisions]

## Implementation Phases

### Phase 1: Backend Foundation (8 hours)
- Implement TOTP secret generation
- Create database schema for 2FA data
- Build verification endpoints

### Phase 2: User Interface (6 hours)
- Design 2FA setup flow
- Implement QR code generation
- Create verification UI

### Phase 3: Integration & Testing (4 hours)
- Integrate with existing auth flow
- Write comprehensive tests
- Update API documentation
```

**Converted to beads epic:**
```bash
# Agent suggests after gepetto completes:
"Should I convert this implementation plan to a beads epic?"

# If yes:
bd create epic "Implement two-factor authentication" --description "$(cat <<'EOF'
## Goals
- Add TOTP-based 2FA to user authentication
- Support Google Authenticator, Authy
- Provide backup codes for recovery
- Maintain backward compatibility

## Success Criteria
- Users can enable/disable 2FA from settings
- TOTP verification working with major authenticator apps
- 10 backup codes generated on 2FA enable
- Existing auth flow unchanged for non-2FA users
- API documentation updated

## Effort
~18 hours across 3 phases

## Context
See gepetto plan: docs/plans/2fa-implementation.md
EOF
)"

# Create tasks from phases
bd create task "Backend Foundation - TOTP and database" --parent 2fa-epic \
  --description "Implement TOTP secret generation, create database schema for 2FA data, build verification endpoints. ~8 hours."

bd create task "User Interface - Setup and verification flows" --parent 2fa-epic \
  --description "Design 2FA setup flow, implement QR code generation, create verification UI. ~6 hours."

bd create task "Integration & Testing" --parent 2fa-epic \
  --description "Integrate with existing auth, write tests, update docs. ~4 hours."

# Link back to plan
bd update 2fa-epic --description "...

## Reference
Implementation plan: docs/plans/2fa-implementation.md"
```

### Mapping Guidelines

**Gepetto Phases → Beads Tasks:**
- Each major phase becomes a task
- Phase effort estimate → task effort estimate
- Phase deliverables → task acceptance criteria

**Gepetto Sub-sections → Beads Subtasks:**
- If phase is complex (>4 hours), create subtasks
- Each bullet point in phase → potential subtask

**Plan Document:**
- Store full gepetto plan in `docs/plans/`
- Link from epic description
- Reference for detailed context

### Integration Workflow

```bash
# 1. User requests implementation plan
User: "Create an implementation plan for two-factor authentication"

# 2. Agent invokes gepetto skill
Agent: [Uses gepetto skill to create detailed plan]

# 3. Agent suggests beads conversion
Agent: "I've created a comprehensive implementation plan. This is a 
multi-session project (~18 hours). Should I create a beads epic to track 
this work?"

# 4. If yes, convert plan to epic + tasks
[Creates epic and tasks as shown above]

# 5. User can start work immediately
bd ready  # Shows 2fa-epic tasks
bd update 2fa-epic.1 --status in_progress
```

### Benefits

1. **Planning continuity:** Gepetto plan → beads tracking → implementation
2. **Effort visibility:** Plan estimates carry into task tracking
3. **Context preservation:** Full plan linked from epic
4. **Phased execution:** Natural breakdown from phases to tasks
5. **Progress tracking:** Clear milestones and completion criteria

---

## Integration with TodoWrite Migration

TodoWrite is for simple, ephemeral planning. When work reveals complexity, migrate to beads.

### Migration Triggers

Agent detects these patterns and suggests migration:

| Trigger | Example |
|---------|---------|
| **TodoWrite grows >5 items** | Started with 3, now has 8 |
| **Dependencies discovered** | "Need to finish X before Y" |
| **Multi-session scope** | "This will take multiple days" |
| **Blockers identified** | "Waiting on API spec" |
| **Cross-component work** | "Touches 5 services" |

### Migration Process

**Before migration (TodoWrite):**
```
TodoWrite:
1. Add dark mode toggle component
2. Update existing components for themes
3. Add theme persistence
4. Update user preferences API
5. Add theme selection to mobile app
6. Update backend services for theme support
7. Add theme to email templates
8. Update documentation
```

**Agent detects complexity:**
```
Agent: "This TodoWrite list has grown to 8 items spanning frontend, backend, 
and mobile. This looks like multi-session work. Should I migrate this to a 
beads epic for better tracking?"
```

**After migration (Beads):**
```bash
# Create epic
bd create epic "Implement dark mode across all platforms" --description "..."

# Migrate todos to tasks
bd create task "Frontend: Dark mode toggle and component theming" --parent dark-mode
bd create task "Backend: Theme persistence and preferences API" --parent dark-mode
bd create task "Mobile: Dark mode implementation" --parent dark-mode
bd create task "Email: Update templates for theme support" --parent dark-mode
bd create task "Documentation: Update user and developer docs" --parent dark-mode

# Clear TodoWrite
[Agent clears TodoWrite]

# Start first task
bd update dark-mode.1 --status in_progress
```

### Migration Best Practices

**Do consolidate related todos:**
```
Before: 
- Update component A
- Update component B  
- Update component C

After:
- Task: Update all components for theme support
  - Components A, B, C
```

**Do identify dependencies:**
```bash
# Persistence must happen before mobile can work
bd update dark-mode.3 --blocked-by dark-mode.2
```

**Do preserve context:**
```bash
# Include TodoWrite notes in epic description
bd update dark-mode --description "...

## Context
Originally started as simple toggle component, discovered:
- 12 components need theme support
- Backend persistence required
- Mobile app needs coordination
"
```

**Don't migrate prematurely:**
- Wait for clear complexity signals
- Don't migrate 3-item TodoWrite "just in case"
- Let user override: "keep using TodoWrite"

### User Override Behavior

**User can prevent migration:**
```
User: "Add dark mode, but keep using TodoWrite for now"

Agent: [Does NOT suggest beads migration, respects preference]
```

**User can request migration:**
```
User: "This is getting complex, let's use beads"

Agent: [Migrates immediately even if <5 items]
```

---

## Integration with General Workflow

Beads integrates with daily development workflow as persistent task tracking.

### Daily Development Cycle

```bash
# Morning: Start work session
bd ready                    # See available work
bd show <id>               # Understand context
bd update <id> --status in_progress

# During day: Track progress
[Code, test, commit]
bd update <id> --description "Progress notes..."

# Evening: End session
bd update <id> --status closed  # or ready with notes
bd create task "..."           # Track remaining work
bd sync                        # Sync state
git push                       # Push code
```

### Weekly Review

```bash
# See all work this week
bd list --closed --since 7d

# Review open work
bd ready

# Plan next week
bd create epic "Next week's focus"
bd create task "..." --parent next-week
```

### Sprint/Milestone Tracking

```bash
# Create epic for sprint
bd create epic "Sprint 23: Performance improvements"

# Add sprint tasks
bd create task "Optimize database queries" --parent sprint-23
bd create task "Implement Redis caching" --parent sprint-23
bd create task "Add performance monitoring" --parent sprint-23

# Track sprint progress
bd show sprint-23  # See completion percentage
```

### Cross-Team Coordination

```bash
# Track dependency on another team
bd create task "Implement frontend for new API"
bd update frontend-task --blocked-by "Backend API spec (Platform team)"

# When blocker resolved
bd update frontend-task --status ready
bd update frontend-task --status in_progress
```

---

## No Integration with Commit Messages

**Important:** Beads issue IDs should NOT appear in commit messages.

### Why No Commit Integration

1. **Commit history is permanent:** Issue IDs are internal tracking, commits are public
2. **Commits describe changes:** Focus on what changed and why, not the ticket number
3. **Future Jira integration:** When Jira skill is added, Jira IDs will be used instead
4. **Clean history:** Commit messages should be meaningful without context of tracking system

### Good Commit Messages (Without Issue IDs)

```bash
# Good: Describes the change and why
git commit -m "refactor: extract DDD patterns to reference files

Splits domain-driven-design skill from 714 to 150 lines by moving
detailed patterns to references/ with progressive disclosure.

This reduces context usage while preserving all content through
fork-on-demand loading."

# Good: Clear and standalone
git commit -m "feat: add TOTP-based two-factor authentication

Implements TOTP verification using standard authenticator apps.
Includes backup code generation for account recovery."
```

### Bad Commit Messages (Don't Do This)

```bash
# Bad: Issue ID doesn't explain the change
git commit -m "[skill-r32.2] refactor DDD"

# Bad: Just a ticket reference
git commit -m "fixes skill-r3f.4"

# Bad: Meaningless without issue context
git commit -m "skill-r32: updates"
```

### Branch Names Can Reference Issues

While commits shouldn't have issue IDs, branches can:

```bash
# Good branch names
git checkout -b skill-r32-progressive-disclosure
git checkout -b skill-r3f-beads-planning-skill
git checkout -b 2fa-implementation

# Links branch to epic without polluting commit history
```

### Future: Jira Integration

When the Jira skill is added:

```bash
# Jira IDs will be used instead of beads IDs
git commit -m "feat: add 2FA support

Implements TOTP verification.

PLATFORM-123"

# But beads will still track internal work breakdown
bd create epic "Implement 2FA (PLATFORM-123)"
bd create task "Backend TOTP" --parent 2fa-epic
```

**Separation of concerns:**
- **Beads:** Internal work breakdown and progress tracking
- **Jira:** External project management and team coordination  
- **Git commits:** Change history and code documentation

---

## Integration Quick Reference

### session-close Integration

**When:** End of coding session  
**Action:** Run `bd sync` before `git push`  
**Purpose:** Persist beads state with code changes

```bash
bd update <task> --status closed
bd create task "Follow-up work"
bd sync
git push
```

---

### session-handoff Integration (Future)

**When:** Pausing work or transferring context  
**Action:** Include active beads epic/tasks in handoff  
**Purpose:** Provide structured work context

```markdown
## Active Beads Work
**Epic:** skill-r32 (5/8 complete)
**Current:** skill-r32.6 (in progress)
**Next:** skill-r32.7, skill-r32.8
```

---

### gepetto Integration

**When:** After creating implementation plan  
**Action:** Convert gepetto plan to beads epic  
**Purpose:** Bridge planning to execution tracking

```bash
# Gepetto creates plan
# Agent suggests: "Convert to beads epic?"
bd create epic "Plan title"
bd create task "Phase 1" --parent epic
```

---

### TodoWrite Migration

**When:** TodoWrite complexity exceeds thresholds  
**Action:** Migrate todos to beads epic + tasks  
**Purpose:** Handle discovered complexity with better tracking

```
Triggers: >5 items, dependencies, multi-session
Action: Create epic, convert todos to tasks
```

---

### General Workflow

**When:** Daily development work  
**Action:** Use beads for multi-session tracking  
**Purpose:** Persistent progress across sessions

```bash
Morning: bd ready
During: bd update with notes
Evening: bd sync
```

---

## Next Steps

- **For workflow details:** See `workflow-patterns.md`
- **For issue templates:** See `issue-templates.md`
- **For quick start:** See main `SKILL.md`
