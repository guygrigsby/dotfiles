# Anthropic Official Guide: Key Recommendations

Distilled from "The Complete Guide to Building Skills for Claude" (Anthropic, January 2026).

Source: https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf

---

## Progressive Disclosure: The 3-Level System

Skills use a three-level system to minimize token usage:

1. **Level 1 -- YAML frontmatter**: Always loaded in Claude's system prompt. Provides enough info to decide when to load the skill. Keep this tight.
2. **Level 2 -- SKILL.md body**: Loaded when Claude determines the skill is relevant. Contains full instructions.
3. **Level 3 -- Linked files**: `references/`, `scripts/`, `assets/` loaded on-demand as needed.

**Implication**: The description field does the heavy lifting. If it's vague, the skill won't trigger. If it's too broad, the skill triggers when it shouldn't.

---

## The Three Skill Categories

### Category 1: Document & Asset Creation
- Creates consistent output (docs, code, diagrams, presentations)
- Key techniques: embedded style guides, template structures, quality checklists
- No external tools required -- uses built-in capabilities

### Category 2: Workflow Automation
- Multi-step processes with consistent methodology
- Key techniques: step-by-step workflow with validation gates, templates, iterative refinement loops
- May coordinate across multiple tools or MCP servers

### Category 3: MCP Enhancement
- Workflow guidance layered on top of MCP tool access
- Key techniques: coordinates multiple MCP calls, embeds domain expertise, handles errors
- MCP provides the tools; the skill provides the recipes

---

## Five Common Patterns

### Pattern 1: Sequential Workflow Orchestration
Multi-step processes in specific order. Explicit step ordering, dependencies between steps, validation at each stage, rollback on failure.

### Pattern 2: Multi-MCP Coordination
Workflows spanning multiple services. Clear phase separation, data passing between phases, validation before advancing.

### Pattern 3: Iterative Refinement
Output quality improves with iteration. Initial draft, quality check against criteria, refinement loop, finalization when threshold met.

### Pattern 4: Context-Aware Tool Selection
Same outcome, different tools depending on context. Decision tree for tool selection, fallback options, transparency about choices.

### Pattern 5: Domain-Specific Intelligence
Specialized knowledge beyond tool access. Domain rules applied before action, comprehensive audit trails, governance embedded in workflow.

---

## Success Criteria Benchmarks

### Quantitative (aspirational targets)
- **Trigger accuracy**: Skill triggers on 90% of relevant queries
- **Efficiency**: Completes workflow in fewer tool calls than without the skill
- **Reliability**: 0 failed API calls per workflow

### Qualitative
- Users don't need to prompt Claude about next steps
- Workflows complete without user correction
- Consistent results across sessions
- New users can accomplish the task on first try

---

## Description Field Best Practices

**Structure**: `[WHAT] + [WHEN/triggers] + [key capabilities]`

**Rules**:
- Under 1024 characters
- No XML angle brackets
- Include specific phrases users would say
- Mention file types if relevant
- Include negative triggers if needed: "Do NOT use for [X]"

---

## Troubleshooting Quick Reference

### Under-triggering
- Description is too vague
- Missing trigger phrases
- Missing domain-specific keywords

**Fix**: Add more detail, trigger phrases, and technical terms to description.

### Over-triggering
- Description is too broad
- Missing negative triggers
- Scope unclear

**Fix**: Narrow the scope, add "Do NOT use for...", clarify domain.

### Instructions Not Followed
- Instructions too verbose (use bullets and numbered lists)
- Critical instructions buried (put them at the top)
- Ambiguous language ("validate properly" vs. specific checks)

**Fix**: Be specific, use `## Critical` headers, repeat key points. For critical validations, consider bundling a script rather than relying on language instructions.

### Large Context Issues
- SKILL.md content too large
- Too many skills loaded simultaneously
- All content inline instead of in references

**Fix**: Move detail to `references/`, keep SKILL.md focused, evaluate number of enabled skills (watch for 20-50+ simultaneously).

---

## Iteration Approach

Anthropic recommends: **Iterate on a single challenging task until Claude succeeds, then extract the winning approach into a skill.** This leverages in-context learning and provides faster signal than broad testing.

After extracting into a skill:
1. Test triggering (positive, paraphrased, negative)
2. Test execution (functional correctness)
3. Compare performance (with vs. without skill)
4. Iterate based on feedback

---

## Official Resources

- [Best Practices Guide](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Skills Documentation](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Engineering Blog](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Agent Skills Open Standard](https://agentskills.io/home)
- [Example Skills Repository](https://github.com/anthropics/skills)
