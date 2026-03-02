# Progressive Disclosure Guidelines

This document outlines the progressive disclosure pattern used across all skills in this repository.

## Overview

Progressive disclosure is a design pattern where complexity is revealed incrementally. Users get essential information first, with detailed reference material available on demand. This keeps skills concise and approachable while providing depth when needed.

## Pattern

Each skill follows this structure:

1. **Main SKILL.md** - The essential workflow, kept under 200 lines
2. **context: fork** in frontmatter - Enables context forking for memory efficiency
3. **references/** directory - Detailed reference documents for deeper exploration

## When to Use References

Reference files should contain:
- Detailed explanations of concepts covered briefly in the main skill
- Extended examples and case studies
- Troubleshooting guides
- Comprehensive command references
- Deep dives into edge cases

Reference files should NOT contain:
- Core workflow steps (keep in main SKILL.md)
- Critical information needed for basic usage
- Content that would make the skill harder to understand

## Target Sizes

| Content Type | Target Lines |
|--------------|--------------|
| Main skill   | ≤200 lines   |
| Reference    | ≤800 lines   |

If a skill exceeds 200 lines, refactor into main + references.

## Frontmatter Requirements

All skills must include:

```yaml
---
name: skill-name
description: Brief description of what this skill does
context: fork
---
```

The `context: fork` directive enables context forking, allowing the agent to load skills without bloating the main context.

## Reference File Organization

Name reference files descriptively:
- `references/concept-name.md` - Single concept deep-dive
- `references/pattern-name.md` - Pattern documentation
- `references/workflow-name.md` - Workflow guides

## Linking References

In the main SKILL.md, reference files should be linked naturally:

```markdown
See `references/command-reference.md` for detailed options.
```

## Benefits

1. **Faster loading** - Skills are concise, references load on-demand
2. **Better focus** - Users see essential workflow first
3. **Deeper exploration** - References available when needed
4. **Easier maintenance** - Smaller files are easier to update
5. **Context efficiency** - fork directive prevents context bloat

## Skills Following This Pattern

- commit-work (179 lines + 2 references)
- commit-refinement (288 lines + 4 references)
- session-close (152 lines + references commit-refinement)
- domain-driven-design (refactored to main + 4 references)
- oltp-schema-design (refactored to main + 4 references)
- beads-planning (main + 3 references)
- skill-creator (main + 3 references)
