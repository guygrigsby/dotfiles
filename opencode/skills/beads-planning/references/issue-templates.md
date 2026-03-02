# Beads Issue Templates

Comprehensive templates for creating well-structured beads issues. All templates include real-world examples for clarity.

---

## Epic Template

Use for large features or initiatives spanning multiple tasks (~2+ hours total effort).

### Structure

```markdown
Title: [verb] [outcome]

Description:
## Goals
- [Concrete goal 1]
- [Concrete goal 2]
- [Concrete goal 3]

## Success Criteria
- [Measurable outcome 1]
- [Measurable outcome 2]
- [Measurable outcome 3]

## Effort
~[X hours] across [N] tasks

## Context
[Why this work matters, background information]

## Children
- [ ] Task 1: [description]
- [ ] Task 2: [description]
- [ ] Task 3: [description]
```

### Real Example: skill-r32

```markdown
Title: Enable progressive disclosure across all skills

Description:
## Goals
- Add context: fork frontmatter to all skills
- Split large skills (>300 lines) into main SKILL.md + references/
- Create progressive disclosure guidelines
- Update documentation

## Success Criteria
- All 5 skills have context: fork in frontmatter
- domain-driven-design and oltp-schema-design under 200 lines each
- References organized by concept
- Guidelines document created

## Effort
~8-9 hours total across 8 tasks

## Context
Large skills consume too much context. Progressive disclosure allows agents
to load detailed content only when needed, improving performance.

## Children
- [x] Add context: fork frontmatter to all 5 skills
- [x] Refactor domain-driven-design skill (714→150 lines + references)
- [x] Refactor oltp-schema-design skill (606→150 lines + references)
- [ ] Review and enhance commit-refinement references
- [ ] Review and enhance commit-work references
- [ ] Verify session-close doesn't need references
- [ ] Create progressive disclosure guidelines document
```

---

## Task Template

Use for discrete units of work that can be completed independently (~30min-2hrs).

### Structure

```markdown
Title: [specific, actionable verb + object]

Description:
## What
[1-2 sentences describing the work]

## Why
[Context or motivation - why this matters]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
```

### Real Example: skill-r32.2

```markdown
Title: Refactor domain-driven-design skill (714→150 lines + references)

Description:
## What
Extract detailed DDD patterns from main SKILL.md into organized reference 
files. Reduce main file from 714 lines to ~150 lines while preserving all 
content through progressive disclosure.

## Why
Large skill files consume excessive context. Progressive disclosure allows
agents to load strategic vs tactical patterns only when needed.

## Acceptance Criteria
- [ ] Main SKILL.md under 200 lines
- [ ] References organized: strategic-ddd.md, tactical-ddd.md, go-patterns.md, schema-mapping.md
- [ ] context: fork frontmatter added
- [ ] Quick start and triggers remain in main file
- [ ] All original content preserved in references/
```

---

## Subtask Template

Use for small, specific steps within a task (<30min). Optional - only create when task needs clear sub-steps.

### Structure

```markdown
Title: [Very specific action]

Description:
[Single paragraph describing what needs to be done]
```

### Example

```markdown
Title: Extract strategic DDD patterns to references/strategic-ddd.md

Description:
Move bounded contexts, context mapping, and ubiquitous language sections
from main SKILL.md to references/strategic-ddd.md. Maintain heading structure
and all examples. Add "See references/strategic-ddd.md" link in main file.
```

---

## Bug Investigation Epic

Use when investigating and fixing complex bugs that require research and multiple steps.

### Structure

```markdown
Title: Investigate and fix [symptom]

Description:
## Symptoms
- [Observable issue 1]
- [Observable issue 2]

## Suspected Causes
- [Hypothesis 1]
- [Hypothesis 2]

## Impact
[Who is affected, severity]

## Tasks
- [ ] Reproduce issue reliably
- [ ] Identify root cause
- [ ] Implement fix
- [ ] Verify resolution
- [ ] Add regression test
- [ ] Document findings
```

### Example

```markdown
Title: Investigate and fix authentication timeout in production

Description:
## Symptoms
- Users randomly logged out after 10-15 minutes
- Error logs show "jwt token invalid" sporadically
- Only affects production, not staging

## Suspected Causes
- Token expiration mismatch between services
- Clock drift on production servers
- Race condition in token refresh logic

## Impact
~50 users per day experiencing unexpected logouts. P1 severity.

## Tasks
- [ ] Reproduce in production-like environment
- [ ] Compare token expiration configs across services
- [ ] Check NTP sync on production servers
- [ ] Review token refresh implementation
- [ ] Implement fix
- [ ] Add monitoring for token failures
- [ ] Deploy and verify resolution
```

---

## Refactoring Epic

Use for significant code reorganization or architecture improvements.

### Structure

```markdown
Title: Refactor [component/system]

Description:
## Current State
[What's problematic about current implementation]

## Desired State
[Target architecture/design]

## Benefits
- [Benefit 1]
- [Benefit 2]

## Constraints
- [Must maintain backward compatibility]
- [No breaking changes to API]
- [Complete within sprint]

## Tasks
- [ ] Analysis and design
- [ ] Implementation phase 1
- [ ] Implementation phase 2
- [ ] Update tests
- [ ] Update documentation
- [ ] Performance validation
```

### Example

```markdown
Title: Refactor user service to use DDD aggregates

Description:
## Current State
User data spread across 3 tables with inconsistent validation. Business
logic mixed in controllers and database layer. Hard to test and maintain.

## Desired State
User aggregate with clear boundaries, entities, and value objects. Business
rules encapsulated in domain layer. Repository pattern for persistence.

## Benefits
- Clearer domain model matching business language
- Testable business logic isolated from infrastructure
- Foundation for event-driven architecture
- Easier onboarding for new developers

## Constraints
- Must maintain existing REST API contracts
- Zero downtime migration required
- Complete within 2 sprints

## Tasks
- [ ] Design User aggregate and entities
- [ ] Implement value objects (Email, UserRole, etc.)
- [ ] Create repository interfaces
- [ ] Migrate business rules to aggregate
- [ ] Update persistence layer
- [ ] Refactor API handlers to use aggregate
- [ ] Add comprehensive domain tests
- [ ] Update API documentation
```

---

## Feature Implementation Epic

Use for net-new features with multiple components.

### Structure

```markdown
Title: Implement [feature name]

Description:
## User Story
As a [user type], I want [capability] so that [benefit]

## Requirements
- [Functional requirement 1]
- [Functional requirement 2]
- [Non-functional requirement 1]

## Technical Approach
[High-level design decisions]

## Tasks
- [ ] Design and planning
- [ ] Backend implementation
- [ ] Frontend implementation
- [ ] Integration
- [ ] Testing
- [ ] Documentation
```

### Example

```markdown
Title: Implement two-factor authentication

Description:
## User Story
As a user with sensitive data, I want optional two-factor authentication
so that my account is protected even if my password is compromised.

## Requirements
- Support TOTP (Google Authenticator, Authy)
- Optional per user (not forced)
- Backup codes for account recovery
- Admin ability to reset 2FA if user locked out
- Must not break existing authentication flow

## Technical Approach
- Use existing JWT tokens, add 2FA claim
- Store TOTP secrets encrypted in user table
- Generate 10 backup codes on 2FA enable
- Add middleware to check 2FA status on protected routes

## Tasks
- [ ] Design 2FA flow and security model
- [ ] Implement TOTP secret generation and validation
- [ ] Create backup code system
- [ ] Add 2FA enable/disable endpoints
- [ ] Update authentication middleware
- [ ] Build 2FA setup UI
- [ ] Build 2FA verification UI
- [ ] Add admin 2FA reset capability
- [ ] Write integration tests
- [ ] Update API documentation
- [ ] Create user guide
```

---

## Quick Reference: When to Use Each Template

| Template | Use When | Effort | Example |
|----------|----------|--------|---------|
| **Epic** | Multiple related tasks, large scope | 2+ hours | "Enable progressive disclosure" |
| **Task** | Discrete unit of work | 30min-2hrs | "Refactor DDD skill" |
| **Subtask** | Small step within task | <30min | "Extract strategic patterns" |
| **Bug Investigation** | Complex bug requiring research | Varies | "Fix auth timeout" |
| **Refactoring** | Code reorganization | 4+ hours | "Refactor to DDD aggregates" |
| **Feature** | Net-new capability | 8+ hours | "Implement 2FA" |

---

## Tips for Writing Good Issues

### Title Guidelines
- **Start with action verb:** "Implement", "Refactor", "Fix", "Investigate"
- **Be specific:** Not "Update docs", but "Update API docs for 2FA endpoints"
- **Keep concise:** Aim for <60 characters
- **Include metrics when relevant:** "Reduce bundle size from 2MB to 500KB"

### Description Guidelines
- **Goals over implementation:** Describe what, not how (unless how is critical)
- **Measurable success criteria:** Avoid "improve performance", use "reduce p95 latency to <100ms"
- **Provide context:** Why does this matter? What's the business value?
- **Link related issues:** Use `blocked-by`, `relates-to` for dependencies

### Effort Estimation
- **Be realistic:** Account for testing, documentation, review
- **Break down large estimates:** >8 hours suggests splitting into subtasks
- **Learn from history:** Review completed epics to calibrate estimates

### Common Pitfalls
- ❌ **Too vague:** "Fix bugs" → ✅ "Fix authentication timeout in production"
- ❌ **Too detailed:** Novel-length descriptions → ✅ Concise with links to docs
- ❌ **Missing context:** Just what, no why → ✅ Include motivation and impact
- ❌ **No success criteria:** Unclear when done → ✅ Clear acceptance criteria
