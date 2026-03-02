---
name: skill-creator
description: "Create new OpenCode skills with correct structure, frontmatter, progressive disclosure, and conventions. Use when asked to create a skill, make a new skill, scaffold a skill, build a SKILL.md, or design a skill."
context: fork
---

# Skill Creator

Interactive guide for creating new skills. Walks through use case definition, frontmatter generation, instruction writing, and validation.

## Triggers

| Trigger | Example |
|---------|---------|
| `create a skill` | "create a skill for code review" |
| `new skill` | "I need a new skill for deployment" |
| `scaffold a skill` | "scaffold a skill for database migrations" |
| `build a SKILL.md` | "build a SKILL.md for sprint planning" |
| `design a skill` | "design a skill that helps with PR reviews" |
| `make a skill` | "make a skill for onboarding new devs" |
| `need a new skill` | "we need a new skill to update protobufs" |

## Quick Start: Classify Your Skill

Before building, identify the category. This shapes the body structure.

| Category | Focus | Body Emphasis |
|----------|-------|---------------|
| **Document/Asset Creation** | Consistent output (docs, code, diagrams) | Templates, style guides, quality checklists |
| **Workflow Automation** | Multi-step processes | Step ordering, validation gates, error handling |
| **MCP Enhancement** | Guidance for MCP tool access | Tool coordination, domain expertise, error recovery |
| **Knowledge/Reference** | Domain expertise and patterns | Concepts, decision trees, examples, deep dives |

## Workflow

### Step 1: Gather Requirements

Ask the user for:

- **Skill name**: kebab-case, descriptive, no spaces/capitals
- **Purpose**: What problem does this skill solve?
- **Use cases**: 2-3 concrete scenarios (user says X, skill does Y, result is Z)
- **Category**: Which of the four categories above?
- **Trigger phrases**: 5-8 phrases a user would say to invoke this skill
- **Tools used**: git, MCP servers, scripts, or none
- **References needed?** Will content exceed 200 lines?

### Step 2: Validate the Name

- Must be kebab-case: `my-skill-name`
- Must NOT contain "claude" or "anthropic" (reserved by Anthropic)
- Check for conflicts with existing skills in the directory
- Name should match the directory name exactly

### Step 3: Create Directory Structure

```bash
mkdir -p skill-name/references  # if references needed
# OR
mkdir skill-name                # if no references
```

Do NOT create a README.md inside the skill folder.

### Step 4: Write the Description (Most Critical Field)

The description determines when the skill triggers. Structure it as:

```
[WHAT it does] + [WHEN to use / trigger phrases] + [key capabilities]
```

Rules:
- Under 1024 characters
- No XML angle brackets (`<` `>`)
- Include specific trigger phrases users would say
- Mention relevant file types if applicable

See `references/skill-anatomy.md` for good/bad examples.

### Step 5: Write SKILL.md

Use the template in `references/skill-anatomy.md`. Key sections:

1. **Frontmatter** (required: `name`, `description`, `context: fork`)
2. **Title** (`# Skill Name`)
3. **One-line summary** of purpose
4. **Triggers table** (trigger phrase + example)
5. **Core content** (workflow steps, concepts, or templates -- varies by category)
6. **Examples** (concrete usage scenarios)
7. **Related Skills** (cross-references to complementary skills)
8. **References** (links to `references/` files if they exist)

Target: under 200 lines. If exceeding, extract detail to `references/`.

### Step 6: Write Reference Files (If Needed)

Extract deep-dive content into `references/`:
- Detailed explanations of concepts covered briefly in SKILL.md
- Extended examples and case studies
- Comprehensive command references
- Troubleshooting guides

Rules:
- Kebab-case filenames: `references/concept-name.md`
- Target: under 800 lines each
- Every reference must be linked from SKILL.md
- Do NOT put core workflow steps in references

### Step 7: Validate

Run through the checklist in `references/quality-checklist.md`. Key checks:

- Frontmatter has `name`, `description`, `context: fork`
- Description includes WHAT + WHEN + triggers
- SKILL.md under 200 lines
- No `<` `>` in frontmatter
- All references linked, no orphans
- Name matches directory name

## Post-Creation Steps

1. **Update PROGRESSIVE_DISCLOSURE.md** -- add to skills list if using references
2. **Test triggering**:
   - Obvious queries that should trigger the skill
   - Paraphrased requests (different wording, same intent)
   - Unrelated queries that should NOT trigger it

## Local Conventions vs. Anthropic Spec

This repo adds conventions beyond the Anthropic spec. See `references/skill-anatomy.md` for full details.

| Convention | Anthropic Spec | This Repo |
|------------|---------------|-----------|
| `context: fork` | Not required | **Required** in all skills |
| SKILL.md size | Under 5,000 words | Under **200 lines** (stricter) |
| Reference size | Not specified | Under **800 lines** |
| README.md in skill dir | Forbidden | Forbidden (aligned) |

## Related Skills

- **skill-judge** -- evaluate skill quality after creation
- **writing-clearly-and-concisely** -- improve prose in descriptions and instructions
- **agent-md-refactor** -- split an existing bloated skill into main + references

## References

- [Skill Anatomy & Template](references/skill-anatomy.md) -- frontmatter fields, body template, section guide
- [Quality Checklist](references/quality-checklist.md) -- pre/post validation checklist
- [Anthropic Guide Summary](references/anthropic-guide-summary.md) -- official recommendations distilled
