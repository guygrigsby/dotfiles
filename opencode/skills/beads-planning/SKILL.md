---
name: beads-planning
description: Persistent issue tracking for complex, multi-session work using bd (beads). Automatically suggested when agent detects complexity (3+ steps, dependencies, multi-session scope). Integrates with session-close, session-handoff, and gepetto skills.
context: fork
license: MIT
compatibility: opencode
metadata:
  category: workflow
  tools: bd
---

# Beads Planning & Tracking

Use beads for **complex, multi-session work** that needs persistent tracking across sessions. For simple tasks, use TodoWrite instead.

---

## When to Use Me

### Automatic (Proactive)

Agent automatically suggests beads when detecting:

- **3+ distinct steps** in described work
- **Multi-file or multi-component** changes
- **Dependencies or blockers** mentioned
- **Multi-session keywords:** "feature", "refactor", "epic", "project"
- **TodoWrite grows >5 items** during work

**Agent suggestion:**
> "This looks like multi-step work. Should I create a beads epic to track this? It would help us break down work, preserve context across sessions, and track dependencies."

### Manual Invocation

Explicitly use beads-planning when:

- Planning a new feature or large refactor
- Need to track work spanning multiple days
- Want structured breakdown of complex work
- Coordinating work with dependencies

### Override Behavior

**User can suppress:** "use TodoWrite only" or "don't use beads"  
**User can request:** "create a beads epic for this" or "let's use beads"

---

## Decision: Beads vs TodoWrite

| Factor | Use TodoWrite | Use Beads |
|--------|---------------|-----------|
| **Complexity** | <3 steps, straightforward | 3+ steps, multi-phase |
| **Duration** | Single session | Multiple sessions |
| **Dependencies** | None | Has blockers/dependencies |
| **Scope changes** | Stable scope | Likely to evolve |
| **Context preservation** | Ephemeral OK | Must survive across sessions |
| **Coordination** | Solo work | Cross-team or has handoffs |

**When in doubt:** Start with TodoWrite, migrate to beads if complexity emerges.

---

## Quick Start

### Finding Work

```bash
# See all available work (no blockers)
bd ready

# View issue details
bd show skill-r32.4

# Claim the work
bd update skill-r32.4 --status in_progress
```

### Creating Issues

```bash
# Create an epic for large work
bd create epic "Implement two-factor authentication"

# Create tasks under the epic
bd create task "Backend TOTP implementation" --parent 2fa-epic
bd create task "Frontend 2FA setup UI" --parent 2fa-epic
bd create task "Testing and documentation" --parent 2fa-epic
```

### During Work

```bash
# Add progress notes
bd update <id> --description "...
## Progress
- Completed TOTP secret generation
- Created database migration
- Next: Build verification endpoint"

# Track blockers
bd update frontend-task --blocked-by backend-task

# Create subtasks if complexity emerges
bd create task "Extract TOTP logic to separate service" --parent backend-task
```

### Ending Session

```bash
# Update task status
bd update <id> --status closed  # If complete
bd update <id> --status ready   # If pausing (add notes)

# Create issues for remaining work
bd create task "Follow-up: optimize TOTP verification performance"

# Sync before git push (CRITICAL)
bd sync

# Then git push (see session-close skill)
git push origin HEAD:branch-name
```

---

## Complexity Detection Triggers

Agent watches for these patterns and suggests beads automatically:

### Pattern: User Describes Multi-Step Work

```
User: "I need to add dark mode with theme persistence and mobile support"

Agent: "This involves UI components, state management, storage, and mobile 
implementation. Should I create a beads epic to track this multi-phase work?"
```

### Pattern: TodoWrite Grows During Work

```
TodoWrite started with:
1. Add dark mode toggle
2. Update styles

During work, grew to:
1. Add dark mode toggle
2. Update 7 components for themes
3. Add theme state management
4. Implement localStorage persistence
5. Update backend theme endpoints
6. Add mobile dark mode
7. Update email templates
8. Update documentation

Agent: "This TodoWrite list has grown to 8 items with dependencies. Should 
I migrate this to a beads epic for better tracking?"
```

### Pattern: Dependencies Discovered

```
User: "Let's refactor the authentication service"

Agent working, discovers:
- Touches 5 different services
- Need to standardize error formats first
- Mobile SDK also needs updates

Agent: "This refactor impacts 5 services and has dependencies. Should I 
create a beads epic to track the full scope?"
```

### Pattern: Multi-Session Work Identified

```
User: "Implement microservices architecture for user management"

Agent: "Migrating to microservices will likely span multiple sessions and 
require phased implementation. Should I create a beads epic to preserve 
context across sessions?"
```

---

## Creating Issues

### Epic → Task → Subtask Hierarchy

**Use 2 levels (Epic → Task) when:**
- Epic is <8 hours total
- Tasks are straightforward (<2 hours each)
- No complex phases within tasks

**Use 3 levels (Epic → Task → Subtask) when:**
- Epic is >8 hours with distinct phases
- Individual tasks are >2 hours
- Want granular progress tracking

### Epic Structure

```bash
bd create epic "Enable progressive disclosure across all skills" \
  --description "$(cat <<'EOF'
## Goals
- Add context: fork frontmatter to all skills
- Split large skills into main + references
- Create progressive disclosure guidelines
- Update documentation

## Success Criteria
- All skills have context: fork in frontmatter
- Large skills under 200 lines each
- References organized by concept
- Guidelines document created

## Effort
~8-9 hours across 8 tasks
EOF
)"
```

### Task Structure

```bash
bd create task "Refactor domain-driven-design skill (714→150 lines)" \
  --parent epic-id \
  --description "Extract DDD patterns to references/ for progressive disclosure"
```

### Real Example: skill-r32

```
Epic: Enable progressive disclosure across all skills (~8 hrs)
├── Task: Add context: fork frontmatter (30 min) ✅
├── Task: Refactor domain-driven-design skill (2.5 hrs) ✅
├── Task: Refactor oltp-schema-design skill (2.5 hrs) ✅
├── Task: Review commit-refinement references (1 hr) ⏸
├── Task: Review commit-work references (1 hr) ⏸
├── Task: Verify session-close doesn't need references (30 min) ⏸
├── Task: Create progressive disclosure guidelines (1.5 hrs) ⏸
└── Task: Update SKILL_INDEX.md (30 min) ⏸
```

**See `references/issue-templates.md` for comprehensive templates.**

---

## Status Lifecycle

```
ready → in_progress → closed
          ↓
       blocked
```

### Status Meanings

| Status | Meaning | When to Use |
|--------|---------|-------------|
| `ready` | Available to work on | Default for new tasks, no blockers |
| `in_progress` | Currently working | Mark when you start work |
| `blocked` | Waiting on dependency | Has blocker preventing progress |
| `closed` | Work completed | Task finished and verified |

### Status Rules

**Only ONE task `in_progress` at a time:**
- Forces focus on completion
- Clear signal of current work
- Makes session-close easier

**Mark closed immediately:**
- Don't batch completions
- Update as soon as task is done
- Provides accurate progress tracking

**Use blocked for dependencies:**
```bash
bd update frontend-task --blocked-by backend-api-task
bd update frontend-task --status blocked
```

---

## Integration Points

### session-close Integration

**Critical:** Run `bd sync` before `git push`

Enhanced session-close workflow:
```bash
# Step 3: Update beads issues
bd update <completed-id> --status closed
bd update <in-progress-id> --status ready  # Add notes
bd create task "Follow-up work discovered"

# Step 4: SQUASH FIXUP COMMITS (if no PR)
git rebase -i --autosquash origin/main

# Step 5: PUSH TO REMOTE
bd sync              # MUST run before push
git push origin HEAD:branch-name
```

**See `references/integration-guide.md` for detailed integration workflows.**

### session-handoff Integration (Future)

Include active beads context in handoff documents:
```markdown
## Active Beads Work
**Epic:** skill-r32 (5/8 complete)
**Current:** skill-r32.6 (in progress)
**Blockers:** None
**Next:** skill-r32.7, skill-r32.8
```

### gepetto Integration

Convert implementation plans to beads epics:
```
1. Gepetto creates detailed plan
2. Agent suggests: "Convert plan to beads epic?"
3. Plan phases → epic tasks
4. Link plan document in epic description
```

### TodoWrite Migration

Migrate when TodoWrite reveals complexity:
```
1. Agent detects: >5 items, dependencies, multi-session
2. Agent suggests migration to beads
3. Create epic, convert todos to tasks
4. Clear TodoWrite, continue with beads
```

---

## Proactive Behavior Examples

### Example 1: Feature Request

```
User: "Add two-factor authentication with Google Authenticator support"

Agent: "Two-factor authentication involves multiple components:
- Backend: TOTP secret generation and verification
- Frontend: 2FA setup flow and QR codes
- Testing: Security validation and edge cases
- Documentation: User and developer docs

This looks like multi-session work (~8-12 hours). Should I create a beads 
epic to track these phases?"

[Creates epic with tasks if user agrees]
```

### Example 2: Refactoring Work

```
User: "Refactor the user service to use DDD patterns"

Agent: "Refactoring to DDD patterns is substantial work:
- Design aggregates and entities
- Implement value objects and repositories
- Migrate business logic to domain layer
- Update tests and documentation

This will likely take multiple sessions. Should I create a beads epic?"

[Creates epic with phased approach if user agrees]
```

### Example 3: TodoWrite Migration

```
Agent working with TodoWrite for "Add search feature"

Discovers during implementation:
- Need to add search indexing service
- Update 6 different pages
- Add search analytics
- Mobile app needs search too
- Backend API changes required

TodoWrite now has 9 items

Agent: "This TodoWrite has grown to 9 items spanning frontend, backend, 
and mobile. Should I migrate this to a beads epic for better tracking?"

[Migrates todos to epic + tasks if user agrees]
```

---

## Common Workflows

### Daily Development

```bash
# Morning: Find work
bd ready
bd show <id>
bd update <id> --status in_progress

# During day: Track progress
[Code, test, commit]
bd update <id> --description "Progress: ..."

# Evening: Close out
bd update <id> --status closed
bd create task "Follow-up: ..."
bd sync
git push
```

### Discovering Subtasks

```bash
# Working on task, realize it's more complex
bd create task "Subtask 1: Extract TOTP logic" --parent original-task
bd create task "Subtask 2: Create database schema" --parent original-task
bd create task "Subtask 3: Build verification API" --parent original-task

# Work through subtasks
bd update subtask-1 --status in_progress
```

### Handling Blockers

```bash
# Discover dependency while working
bd update current-task --blocked-by dependency-task
bd update current-task --status blocked

# Work on dependency first
bd update dependency-task --status in_progress

# Complete dependency
bd update dependency-task --status closed

# Resume original task
bd update current-task --status in_progress
```

---

## Important Rules

### ✅ Do This

- Keep only ONE task `in_progress` at a time
- Mark tasks `closed` immediately when done
- Run `bd sync` before every `git push`
- Create issues for discovered work
- Add progress notes for context preservation
- Use blockers to track dependencies
- Let agent suggest beads for complex work

### ❌ Don't Do This

- Don't put beads issue IDs in commit messages (reserved for future Jira integration)
- Don't batch status updates (update immediately)
- Don't skip `bd sync` before git push
- Don't suppress beads suggestions without reason
- Don't create epics for simple (<2 hour) work

---

## See Also

### Reference Files (Progressive Disclosure)

- **`references/workflow-patterns.md`** - Detailed workflows for starting sessions, during work, ending sessions, epic decomposition, and real-world examples
- **`references/issue-templates.md`** - Comprehensive templates for epics, tasks, subtasks, bug investigations, refactorings, and features
- **`references/integration-guide.md`** - Integration with session-close, session-handoff, gepetto, TodoWrite migration, and general workflow

### Related Skills

- **`session-close`** - Proper session completion workflow (includes `bd sync`)
- **`session-handoff`** - Context preservation across sessions (future integration)
- **`gepetto`** - Implementation planning (converts to beads epics)
- **`commit-work`** - Git commit best practices (no beads IDs in commits)

---

## Quick Reference

```bash
# Finding work
bd ready                           # Show available work
bd show <id>                       # View issue details

# Working on tasks
bd update <id> --status in_progress   # Start work
bd update <id> --status closed        # Complete work
bd update <id> --status blocked       # Mark blocked

# Creating issues
bd create epic "Title"             # Create epic
bd create task "Title" --parent <id>  # Create task under epic

# Dependencies
bd update <id> --blocked-by <other-id>

# Session close
bd sync                            # MUST run before git push
```

---

## Tips for Success

1. **Start simple:** Use TodoWrite first, migrate to beads if complexity emerges
2. **Trust the agent:** When agent suggests beads, there's usually good reason
3. **One at a time:** Keep only one task `in_progress` for better focus
4. **Document as you go:** Add notes to issues for context preservation
5. **Sync before push:** Always `bd sync` before `git push`
6. **Break down large tasks:** >4 hour tasks should become subtasks
7. **Use blockers:** Make dependencies explicit with `--blocked-by`

---

**Ready to use beads?** Agent will suggest when appropriate, or invoke manually for planning complex work.
