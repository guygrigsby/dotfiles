# Skill Anatomy & Template

Complete reference for building SKILL.md files. Covers frontmatter fields, body structure, and a fill-in-the-blank template.

---

## YAML Frontmatter Reference

### Required Fields

| Field | Rules | Example |
|-------|-------|---------|
| `name` | Kebab-case, no spaces, no capitals. Must match directory name. Must NOT contain "claude" or "anthropic". | `sprint-planner` |
| `description` | WHAT + WHEN + triggers. Under 1024 chars. No XML brackets (`<` `>`). | See examples below. |
| `context` | Always `fork` (local convention). Enables context forking for memory efficiency. | `fork` |

### Optional Fields

| Field | Purpose | Example |
|-------|---------|---------|
| `license` | License type for open-source skills | `MIT` |
| `compatibility` | Environment requirements (1-500 chars) | `opencode` |
| `allowed-tools` | Restrict tool access (Anthropic spec) | `"Bash(python:*) WebFetch"` |
| `metadata` | Custom key-value pairs | See below |

### Metadata Sub-fields (Optional)

```yaml
metadata:
  author: Your Name
  version: 1.0.0
  category: workflow    # workflow, knowledge, tooling, reasoning
  tools: git, bd        # tools the skill uses, or "none"
  mcp-server: server-name  # if MCP-dependent
```

### Security Restrictions

- No XML angle brackets (`<` `>`) anywhere in frontmatter
- Names must not start with "claude" or "anthropic" (reserved)
- YAML is parsed in safe mode -- no code execution

---

## Description Field: Good vs. Bad

The description is the most important field. It determines whether and when the skill loads.

**Structure:** `[WHAT it does] + [WHEN to use / trigger phrases] + [key capabilities]`

### Good Examples

```yaml
description: "Create high-quality git commits: review/stage intended changes,
  split into logical commits, and write clear commit messages. Use when the
  user asks to commit, craft a commit message, stage changes, or split work
  into multiple commits."

description: "Design PostgreSQL OLTP schemas optimized for transactional
  workloads. Covers 5NF normalization, ACID guarantees, foreign key constraints,
  B-tree indexes. Use when asked to design a database schema, normalize tables,
  or create a transactional data model."

description: "Analyzes Figma design files and generates developer handoff
  documentation. Use when user uploads .fig files, asks for design specs,
  component documentation, or design-to-code handoff."
```

### Bad Examples

```yaml
# Too vague -- no triggers, no specifics
description: "Helps with projects."

# Missing triggers -- when would this activate?
description: "Creates sophisticated multi-page documentation systems."

# Too technical, no user-facing triggers
description: "Implements the Project entity model with hierarchical relationships."
```

---

## Body Structure: Canonical Section Ordering

Adapt this ordering to your skill's category. Not every skill needs every section.

### For Workflow Skills

1. `# Skill Name` -- H1 title
2. One-line summary of purpose
3. `## Triggers` -- Table of trigger phrases
4. `## Quick Start` -- Decision tree or quick overview
5. `## Workflow` -- Numbered steps with validation gates
6. `## Examples` -- Concrete usage scenarios
7. `## Troubleshooting` -- Common errors and fixes
8. `## Related Skills` -- Cross-references
9. `## References` -- Links to reference files

### For Knowledge/Reference Skills

1. `# Skill Name` -- H1 title
2. One-line summary
3. `## Triggers` -- Table
4. `## Quick Start` -- When to use / when NOT to use
5. `## Key Terms` -- Glossary table
6. `## Core Concepts` -- Main content with subsections
7. `## Skill Composition` -- How this skill chains with others
8. `## Examples` -- Concrete scenarios
9. `## References` -- Deep dive links

### For Document/Asset Creation Skills

1. `# Skill Name` -- H1 title
2. One-line summary
3. `## Triggers` -- Table
4. `## Style Guide` -- Templates, brand standards
5. `## Creation Workflow` -- Steps to produce output
6. `## Quality Checklist` -- Validation before finalizing
7. `## Examples` -- Sample outputs
8. `## References` -- Templates, assets

---

## Fill-in-the-Blank Template

Copy and customize:

```markdown
---
name: SKILL-NAME
description: "WHAT-IT-DOES. Use when TRIGGER-PHRASES."
context: fork
---

# SKILL TITLE

ONE-LINE-SUMMARY.

## Triggers

| Trigger | Example |
|---------|---------|
| `trigger-phrase-1` | "example usage 1" |
| `trigger-phrase-2` | "example usage 2" |
| `trigger-phrase-3` | "example usage 3" |

## Quick Start

DECISION-TREE-OR-QUICK-OVERVIEW.

## CORE-SECTION (Workflow / Concepts / Style Guide)

### Step 1: FIRST-STEP
DESCRIPTION.

### Step 2: SECOND-STEP
DESCRIPTION.

## Examples

### Example 1: COMMON-SCENARIO
DESCRIPTION-OF-SCENARIO-AND-EXPECTED-OUTCOME.

## Related Skills

- **related-skill-1** -- HOW-IT-RELATES
- **related-skill-2** -- HOW-IT-RELATES

## References

- [Reference Name](references/reference-name.md) -- BRIEF-DESCRIPTION
```

---

## Reference File Conventions

### When to Create References

- SKILL.md exceeds 200 lines
- Content is detailed but not essential for basic usage
- Extended examples, case studies, or troubleshooting
- Comprehensive command or API references

### When NOT to Create References

- Core workflow steps belong in SKILL.md
- Critical information needed for basic usage stays in SKILL.md
- If the skill is simple enough to fit in 200 lines, don't split

### Naming

- Kebab-case: `concept-name.md`, `workflow-guide.md`
- Descriptive: name reflects the concept covered
- Stored in `references/` subdirectory

### Linking from SKILL.md

```markdown
See `references/concept-name.md` for detailed guidance.

# OR as a list at the end:

## References
- [Concept Guide](references/concept-name.md) -- detailed explanation
- [Examples](references/examples.md) -- extended examples
```

### Size Target

Under 800 lines per reference file. If a reference exceeds this, split it.
