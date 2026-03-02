# Skill Quality Checklist

Use this checklist to validate a skill before and after creation.

---

## Phase 1: Before You Start

- [ ] Identified 2-3 concrete use cases (user says X, skill does Y, result is Z)
- [ ] Classified the skill category (Document/Asset, Workflow, MCP Enhancement, Knowledge)
- [ ] Listed 5-8 trigger phrases users would say
- [ ] Planned directory structure (references needed?)
- [ ] Checked for name conflicts with existing skills

## Phase 2: Frontmatter Validation

- [ ] File is named exactly `SKILL.md` (case-sensitive)
- [ ] Frontmatter delimited by `---` on both sides
- [ ] `name` is kebab-case, matches directory name
- [ ] `name` does NOT contain "claude" or "anthropic"
- [ ] `description` includes WHAT the skill does
- [ ] `description` includes WHEN to use it (trigger phrases)
- [ ] `description` is under 1024 characters
- [ ] `description` contains NO XML brackets (`<` `>`)
- [ ] `context: fork` is present (local convention)

## Phase 3: Body Structure

- [ ] H1 title matches skill name/purpose
- [ ] One-line summary after the title
- [ ] Triggers table present with 5+ trigger phrases
- [ ] Core content section (workflow steps, concepts, or templates)
- [ ] Instructions are specific and actionable, not vague
- [ ] Error handling / troubleshooting included (if workflow skill)
- [ ] Examples section with concrete scenarios
- [ ] Related Skills section with cross-references
- [ ] References section links to all reference files (if any)

## Phase 4: Size & Progressive Disclosure

- [ ] SKILL.md is under 200 lines
- [ ] Each reference file is under 800 lines
- [ ] Core workflow steps are in SKILL.md, NOT in references
- [ ] References contain only deep-dive/supplementary content
- [ ] Every reference file is linked from SKILL.md (no orphans)
- [ ] No README.md inside the skill folder

## Phase 5: Post-Creation

- [ ] Directory name matches the `name` field in frontmatter
- [ ] PROGRESSIVE_DISCLOSURE.md updated (if skill uses references)

## Phase 6: Trigger Testing

- [ ] **Positive test**: Obvious queries trigger the skill (3+ tested)
- [ ] **Paraphrase test**: Rephrased requests still trigger (3+ tested)
- [ ] **Negative test**: Unrelated queries do NOT trigger (3+ tested)

### Debugging Triggers

If the skill does not trigger:
- Is the description too generic? ("Helps with projects" won't work)
- Does it include phrases users would actually say?
- Does it mention relevant file types or domain terms?

If the skill triggers too often:
- Is the description too broad? Narrow the scope.
- Add negative context: "Do NOT use for [unrelated task]"
- Clarify scope: "Use specifically for [X], not for general [Y]"

### Ask Claude to Debug

> "When would you use the [skill-name] skill?"

Claude will quote the description back. Adjust based on what's missing or overly broad.

## Quick Pass/Fail Summary

| Check | Pass Criteria |
|-------|---------------|
| Frontmatter | `name` + `description` + `context: fork`, no XML |
| Description | WHAT + WHEN + triggers, under 1024 chars |
| Size | SKILL.md under 200 lines, refs under 800 |
| Structure | Title, triggers, core content, examples, related skills |
| References | All linked, no orphans, no core content in refs |
| Naming | Kebab-case, matches dir, no reserved words |
| No README.md | Skill folder has no README.md file |
