# Beads Workflow Patterns

Detailed workflows for using `bd` (beads) throughout your development lifecycle.

---

## Starting a Work Session

Begin every session by checking available work and understanding context.

### Step-by-Step Workflow

```bash
# 1. Check what's available to work on
bd ready

# Output shows issues with no blockers:
# 1. [● P2] [epic] skill-r32: Enable progressive disclosure
# 2. [● P2] [task] skill-r32.4: Review commit-refinement references
# 3. [● P2] [task] skill-r32.5: Review commit-work references
```

```bash
# 2. Review issue details for context
bd show skill-r32.4

# Understand:
# - What needs to be done
# - Why it matters (context)
# - Acceptance criteria
# - Related issues (parent, blockers)
```

```bash
# 3. Claim the work by marking it in progress
bd update skill-r32.4 --status in_progress

# Now you're committed to this work
# Keep only ONE issue in_progress at a time
```

```bash
# 4. Start working
# - Read relevant code/docs
# - Make changes
# - Test as you go
```

### Quick Resume After Break

If you already know what you're working on:

```bash
# Check current status
bd show skill-r32.4

# Resume work
bd update skill-r32.4 --status in_progress

# Continue where you left off
```

---

## During Work

Maintain beads context as work evolves.

### Creating Subtasks as Scope Clarifies

As you work, you may discover the task is larger than expected:

```bash
# While working on "Refactor DDD skill", you realize it needs:
# 1. Extract strategic patterns
# 2. Extract tactical patterns  
# 3. Extract Go-specific patterns
# 4. Update main file

# Create subtasks for tracking
bd create task "Extract strategic DDD patterns" --parent skill-r32.2
bd create task "Extract tactical DDD patterns" --parent skill-r32.2
bd create task "Extract Go-specific patterns" --parent skill-r32.2
bd create task "Update main SKILL.md with references" --parent skill-r32.2
```

**When to create subtasks:**
- Original task estimate was >2 hours
- Clear phases or steps emerged
- Want to track progress within the task
- Need to take a break mid-task

**When NOT to create subtasks:**
- Task is straightforward and linear
- Would create more overhead than value
- Task is already well-scoped

### Tracking Blockers

When you discover a dependency:

```bash
# You're working on skill-r32.4 but realize you need skill-r32.3 done first
bd update skill-r32.4 --blocked-by skill-r32.3

# Mark current issue as blocked
bd update skill-r32.4 --status blocked

# Switch to the blocking issue
bd update skill-r32.3 --status in_progress
```

### Adding Notes and Discoveries

Update issue descriptions with findings:

```bash
# Add notes about discoveries, gotchas, or decisions
bd update skill-r32.4 --description "$(cat <<'EOF'
[Original description]

## Progress Notes
- Found that commit-refinement already uses references/ pattern
- Discovered missing examples in rebase workflow
- Need to add interactive rebase safety checks

## Decisions
- Keep existing structure, just enhance with more examples
- Add GitHub's official guidance as reference link
EOF
)"
```

### Keeping ONE Task in Progress

**Rule:** Only mark ONE task as `in_progress` at any time.

**Why:**
- Forces focus on completing work
- Clear signal to others what you're working on
- Prevents context-switching overhead
- Makes session-close easier

**If you need to switch:**
```bash
# Pause current work
bd update skill-r32.4 --status ready --description "... 

## Paused: Need to fix test failures first"

# Start new work
bd update skill-r32.5 --status in_progress
```

---

## Discovering Complexity Mid-Session

Sometimes simple work reveals unexpected complexity. Beads helps track this.

### Scenario: TodoWrite Task Grows Complex

**Initial state:** Using TodoWrite for "Add dark mode toggle"

```
TodoWrite:
1. Create toggle component
2. Add state management
3. Update styles
```

**During work, discovers:**
- 7 components need theme support
- Need localStorage persistence
- 3 backend services need theme endpoints
- Mobile app also needs updates

**Agent detects complexity:**
> "This TodoWrite list has grown to 8 items with dependencies across frontend and backend. Should I migrate this to a beads epic for better tracking?"

**If yes, agent:**
1. Creates epic: "Implement dark mode across all platforms"
2. Creates tasks from TodoWrite items
3. Adds discovered scope as additional tasks
4. Clears TodoWrite

```bash
# Migration process
bd create epic "Implement dark mode across all platforms" --description "..."

# Convert todos to tasks
bd create task "Create dark mode toggle component" --parent dark-mode-epic
bd create task "Implement theme state management" --parent dark-mode-epic
bd create task "Update component styles for themes" --parent dark-mode-epic
bd create task "Add theme persistence to localStorage" --parent dark-mode-epic
bd create task "Add theme endpoints to backend services" --parent dark-mode-epic
bd create task "Implement dark mode in mobile app" --parent dark-mode-epic

# Clear TodoWrite and continue with first task
bd update dark-mode-epic.1 --status in_progress
```

### Scenario: Discovering Dependencies

**Initial work:** "Update API error handling"

**During work:**
- Realizes error formats are inconsistent across services
- Need to standardize error schema first
- Impacts 5 different services

**Agent suggests:**
> "This touches 5 services and requires standardization work first. Should I create an epic to track the full scope?"

```bash
# Create epic for full scope
bd create epic "Standardize API error handling across services"

# Create tasks in dependency order
bd create task "Design standard error schema" --parent error-handling
bd create task "Update auth service error handling" --parent error-handling
bd create task "Update user service error handling" --parent error-handling
bd create task "Update payment service error handling" --parent error-handling
bd create task "Update notification service error handling" --parent error-handling
bd create task "Update API documentation" --parent error-handling

# Mark dependencies
bd update error-handling.2 --blocked-by error-handling.1
bd update error-handling.3 --blocked-by error-handling.1
# ... etc

# Start with first task
bd update error-handling.1 --status in_progress
```

---

## Ending a Work Session

Properly close out work to preserve context for next session.

### Complete Session Workflow

```bash
# 1. Update status for all in_progress issues
bd update skill-r3f.5 --status closed  # Finished SKILL.md

bd update skill-r3f.6 --status ready --description "...

## Progress
- Updated SKILL_INDEX.md line counts
- Added beads-planning to Planning section
- Still need to verify Quick Reference formatting"
```

```bash
# 2. Create issues for remaining/discovered work
bd create task "Test proactive beads detection with real scenarios" \
  --parent skill-r3f --description "Validate that agent suggests beads when:
- User describes complex feature
- TodoWrite grows to 5+ items
- Dependencies are mentioned"

bd create task "Add beads-planning to Development Workflow section" \
  --parent skill-r3f --description "SKILL_INDEX line 256 has Development 
Workflow list. Add beads-planning after commit-refinement."
```

```bash
# 3. Sync beads changes with git
bd sync

# This ensures .beads/ state is committed and ready for git push
```

```bash
# 4. Continue with session-close workflow
# - Run quality gates (tests, linters, builds)
# - Squash fixup commits if no PR
# - Git push (see session-close skill)
```

### Partial Progress Documentation

If you made progress but didn't complete a task, document it:

```bash
bd update skill-r32.7 --status ready --description "...

## Progress (2026-02-15)
- Drafted outline for progressive disclosure guidelines
- Identified 3 key principles: context forking, reference organization, frontmatter standards
- Started writing Context Forking section

## Next Steps
- Complete Context Forking section with examples
- Write Reference Organization section
- Write Frontmatter Standards section
- Add real examples from DDD and OLTP skills"
```

This gives next session (or another developer) clear context.

---

## Epic Decomposition

How to break down large work into epics, tasks, and subtasks.

### When to Use 3 Levels

**Use Epic → Task only when:**
- Epic is <8 hours
- Tasks are straightforward
- No clear phases within tasks

**Use Epic → Task → Subtask when:**
- Epic is >8 hours with distinct phases
- Individual tasks are >2 hours
- Tasks have clear sub-steps
- Want granular progress tracking

### Example: 2-Level Structure (Epic → Task)

```
Epic: Add two-factor authentication (8 hours)
├── Task: Implement TOTP backend (2 hrs)
├── Task: Create 2FA setup UI (2 hrs)
├── Task: Add 2FA verification flow (2 hrs)
├── Task: Write tests and documentation (2 hrs)
```

**Why 2 levels:** Each task is self-contained, ~2 hours, clear scope.

### Example: 3-Level Structure (Epic → Task → Subtask)

```
Epic: Migrate to microservices architecture (40 hours)
├── Task: Extract user service (8 hrs)
│   ├── Subtask: Design service boundaries
│   ├── Subtask: Implement domain layer
│   ├── Subtask: Create service API
│   ├── Subtask: Migrate data
│   └── Subtask: Deploy and validate
├── Task: Extract payment service (8 hrs)
│   ├── Subtask: Design service boundaries
│   ├── Subtask: Implement domain layer
│   ├── Subtask: Create service API
│   ├── Subtask: Integrate with payment gateway
│   └── Subtask: Deploy and validate
├── Task: Extract notification service (6 hrs)
├── Task: Implement service mesh (10 hrs)
└── Task: Update documentation (8 hrs)
```

**Why 3 levels:** Epic is large (40 hrs), tasks are multi-hour with clear phases.

### Epic Decomposition Process

**1. Start with high-level goals:**
```
Epic: Enable progressive disclosure across all skills

Goals:
- Reduce context usage for large skills
- Maintain all content through references
- Add progressive disclosure to all skills
```

**2. Identify major phases (tasks):**
```
Phase 1: Add context: fork to all skills
Phase 2: Refactor large skills (DDD, OLTP)
Phase 3: Review medium skills (commit-refinement, commit-work, session-close)
Phase 4: Create guidelines
Phase 5: Update documentation
```

**3. Break phases into concrete tasks:**
```
Phase 2 becomes:
- Task: Refactor domain-driven-design skill (714→150 lines)
- Task: Refactor oltp-schema-design skill (606→150 lines)

Phase 3 becomes:
- Task: Review and enhance commit-refinement references
- Task: Review and enhance commit-work references
- Task: Verify session-close doesn't need references
```

**4. Add subtasks only if needed:**
```
If "Refactor domain-driven-design" is complex:
- Subtask: Extract strategic DDD patterns
- Subtask: Extract tactical DDD patterns
- Subtask: Extract Go-specific patterns
- Subtask: Extract schema mapping patterns
- Subtask: Update main SKILL.md
```

### Effort Estimation Guidelines

| Level | Typical Range | When to Split |
|-------|---------------|---------------|
| **Epic** | 2-40 hours | >40 hrs → multiple epics |
| **Task** | 30min-4 hours | >4 hrs → add subtasks or split |
| **Subtask** | 15min-1 hour | >1 hr → probably should be a task |

**Tips:**
- Estimate based on actual work time, not calendar time
- Include testing, documentation, and review in estimates
- Learn from completed epics to calibrate future estimates
- It's okay to adjust estimates as you learn more

---

## Real-World Example: skill-r32 Walkthrough

Let's walk through the actual skill-r32 epic to see these patterns in action.

### Epic Overview

```bash
bd show skill-r32
```

```
Epic: Enable progressive disclosure across all skills
Status: In progress (3/8 tasks complete)
Effort: ~8-9 hours
```

### Tasks Breakdown

**Completed tasks:**
1. ✅ `skill-r32.1`: Add context: fork frontmatter (~30 min)
2. ✅ `skill-r32.2`: Refactor domain-driven-design skill (~2.5 hrs)
3. ✅ `skill-r32.3`: Refactor oltp-schema-design skill (~2.5 hrs)

**In progress:**
4. ⏳ `skill-r32.4`: Review commit-refinement references (~1 hr)

**Pending:**
5. ⏸ `skill-r32.5`: Review commit-work references (~1 hr)
6. ⏸ `skill-r32.6`: Verify session-close doesn't need references (~30 min)
7. ⏸ `skill-r32.7`: Create progressive disclosure guidelines (~1.5 hrs)
8. ⏸ `skill-r32.8`: Update SKILL_INDEX.md (~30 min)

### Workflow Timeline

**Session 1: Planning (Feb 15, 09:00)**
```bash
# Created epic and all tasks
bd create epic "Enable progressive disclosure across all skills"
bd create task "Add context: fork frontmatter" --parent skill-r32
# ... created all 8 tasks

bd update skill-r32.1 --status in_progress
# Worked on frontmatter
bd update skill-r32.1 --status closed

# Session ended
bd sync
```

**Session 2: DDD Refactor (Feb 15, 09:30)**
```bash
bd ready  # Shows skill-r32.2 available
bd show skill-r32.2  # Understand the task
bd update skill-r32.2 --status in_progress

# During work: discovered 4 distinct pattern categories
# Created references/strategic-ddd.md
# Created references/tactical-ddd.md
# Created references/go-patterns.md
# Created references/schema-mapping.md

bd update skill-r32.2 --status closed
bd sync
```

**Session 3: OLTP Refactor (Feb 15, 09:45)**
```bash
bd ready
bd update skill-r32.3 --status in_progress

# Similar to DDD refactor
# Reduced from 606 to ~150 lines

bd update skill-r32.3 --status closed
bd sync
```

**Session 4: Current (Feb 15, 10:00)**
```bash
bd ready  # Shows 5 remaining tasks
bd show skill-r32.4
bd update skill-r32.4 --status in_progress

# Currently working on this...
```

### Key Patterns Demonstrated

1. **Clear decomposition:** Epic → 8 focused tasks
2. **Sequential progress:** Complete tasks before starting new ones
3. **Status updates:** Mark closed immediately when done
4. **Regular syncing:** `bd sync` at end of each session
5. **Context preservation:** Each task has clear acceptance criteria

---

## Common Patterns and Best Practices

### Pattern: Feature Flags for Large Changes

When implementing large features, use feature flags to allow incremental merging:

```bash
Epic: Implement new search algorithm
├── Task: Implement new algorithm (behind flag)
├── Task: A/B test old vs new
├── Task: Analyze results
├── Task: Enable for 10% of users
├── Task: Enable for 100% of users
└── Task: Remove old algorithm
```

Each task can be merged independently without breaking production.

### Pattern: Spike Tasks for Research

When you don't know the solution yet:

```bash
Epic: Improve query performance
├── Task: Spike - Profile and identify bottlenecks (time-boxed 2hrs)
├── Task: [Created after spike based on findings]
```

Time-box research tasks to prevent open-ended exploration.

### Pattern: Parallel vs Sequential Work

**Sequential (dependencies):**
```bash
Epic: Database migration
├── Task 1: Design new schema (must be first)
├── Task 2: Create migration scripts (depends on 1)
├── Task 3: Test migration (depends on 2)
└── Task 4: Run in production (depends on 3)

bd update migration.2 --blocked-by migration.1
bd update migration.3 --blocked-by migration.2
bd update migration.4 --blocked-by migration.3
```

**Parallel (independent):**
```bash
Epic: Add dark mode
├── Task 1: Create theme toggle component
├── Task 2: Update existing components for themes
├── Task 3: Add theme persistence
└── Task 4: Update documentation

# These can be worked on in any order
# No blocked-by relationships needed
```

### Pattern: Bug Fix Within Feature

If you discover a bug while working on a feature:

**Option 1: Small bug, fix inline**
- Just fix it as part of current work
- Mention in task notes

**Option 2: Separate bug, needs tracking**
```bash
# Pause feature work
bd update feature-task --status ready --description "...
Paused: Found auth bug that needs fixing first"

# Create bug task
bd create task "Fix authentication token refresh race condition"
bd update auth-bug --status in_progress

# Fix bug, complete task
bd update auth-bug --status closed

# Resume feature
bd update feature-task --status in_progress
```

---

## Workflow Checklists

### Starting Work Checklist

```
[ ] Run `bd ready` to see available work
[ ] Review issue with `bd show <id>`
[ ] Check for blockers or dependencies
[ ] Mark as in_progress: `bd update <id> --status in_progress`
[ ] Understand acceptance criteria before coding
```

### During Work Checklist

```
[ ] Keep only ONE issue in_progress
[ ] Create subtasks if complexity emerges
[ ] Track blockers immediately when discovered
[ ] Add progress notes for context preservation
[ ] Update issue description with findings
```

### Ending Session Checklist

```
[ ] Update all in_progress issues (closed or ready)
[ ] Create issues for remaining/discovered work
[ ] Add progress notes for partial work
[ ] Run `bd sync` before git operations
[ ] Continue with session-close workflow
```

---

## Integration with Git Workflow

Beads and git work together, but have distinct purposes:

**Beads:** Tracks work units, progress, dependencies  
**Git:** Tracks code changes, history

### Sync Timing

```bash
# At end of session (before git push)
bd sync              # Sync beads changes
git push             # Push code changes

# bd sync must happen before git push
# This ensures .beads/ state is committed
```

### No Issue IDs in Commits

**Important:** Do NOT put beads issue IDs in commit messages.

**Why:**
- Issue IDs are for internal tracking
- Commits should describe the change, not the ticket
- Future Jira integration will handle issue references

**Good commit message:**
```
refactor: extract DDD patterns to reference files

Splits domain-driven-design skill from 714 to 150 lines by moving
detailed patterns to references/ with progressive disclosure.
```

**Bad commit message (don't do this):**
```
[skill-r32.2] refactor DDD skill
```

### Branch Names Can Reference Issues

While commit messages shouldn't have issue IDs, branch names can:

```bash
git checkout -b skill-r32-progressive-disclosure
# or
git checkout -b feature/progressive-disclosure
```

This helps link branches to beads epics without polluting commit history.

---

## Troubleshooting

### "I have multiple tasks in_progress"

**Fix:**
```bash
# List all in_progress tasks
bd ready --status in_progress

# Pause all but one
bd update task-1 --status ready
bd update task-2 --status ready

# Keep only one active
bd update task-3 --status in_progress
```

### "I forgot to sync before pushing"

**Fix:**
```bash
# Sync now
bd sync

# Check if changes need pushing
git status

# If .beads/ has changes, push them
git add .beads/
git commit -m "sync: update beads tracking state"
git push
```

### "Issue was more complex than expected"

**Fix:**
```bash
# Create subtasks for remaining work
bd create task "Subtask 1" --parent original-task
bd create task "Subtask 2" --parent original-task

# Update original task description
bd update original-task --description "...
## Note
Task was larger than estimated. Created subtasks for tracking."

# Work through subtasks
bd update subtask-1 --status in_progress
```

### "Discovered dependency mid-work"

**Fix:**
```bash
# Mark current task as blocked
bd update current-task --status blocked --blocked-by dependency-task

# Work on dependency first
bd update dependency-task --status in_progress

# Complete dependency
bd update dependency-task --status closed

# Resume original task
bd update current-task --status in_progress
```

---

## Next Steps

- **For issue templates:** See `issue-templates.md`
- **For skill integrations:** See `integration-guide.md`
- **For quick start:** See main `SKILL.md`
