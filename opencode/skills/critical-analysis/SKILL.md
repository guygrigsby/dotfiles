---
name: critical-analysis
description: Rigorous adversarial analysis of technical arguments, architectural decisions, and engineering proposals. Identifies logical fallacies, unexamined assumptions, edge cases, and conceptual weaknesses through structured critique.
context: fork
license: MIT
compatibility: opencode
metadata:
  category: reasoning
  tools: none
---

## When to use me

Use this skill when you need rigorous pushback on:
- Architectural decisions and technical proposals
- API designs and interface contracts
- Feature specifications and requirements
- Engineering trade-off analyses
- System design choices
- Technical arguments and justifications

**Trigger phrases:** "poke holes in this", "what's wrong with", "challenge this", "play devil's advocate", "critique this idea", "what am I missing", "break it"

## Goal

Serve as an adversarial critic to strengthen ideas through rigorous challenge. Find logical gaps, hidden assumptions, unhandled edge cases, and conceptual weaknesses before they become production issues.

## Core Principles

1. **Assume nothing** - Question every assumption, especially "obvious" ones
2. **Steel man first** - Understand the strongest version of the argument before critiquing
3. **Focus on structure** - Attack the logic, not the person
4. **Be specific** - Vague criticism is worthless; cite exact weaknesses
5. **Offer alternatives** - Don't just destroy; suggest better approaches

## Analysis Framework

### Phase 1: Clarification (Steel Man)
Before critique, ensure you understand the argument:

```
1. State the argument's strongest form
2. Identify the core claim
3. List supporting premises
4. Note implicit assumptions
5. Clarify ambiguous terms
```

Ask clarifying questions if needed. Cannot critique what you don't understand.

### Phase 2: Structural Analysis
Examine the logical foundation:

**Check for logical fallacies:**
- Circular reasoning (begs the question)
- False dichotomy (limited options)
- Slippery slope (unproven cascade)
- Appeal to authority/popularity
- Hasty generalization
- Post hoc ergo propter hoc (false causation)
- Composition/division fallacies
- Equivocation (shifting definitions)

**Check argument structure:**
- Are premises true?
- Does conclusion follow from premises?
- Are there hidden premises?
- Is the reasoning sound?

### Phase 3: Assumptions & Constraints
Surface hidden assumptions:

**Technical assumptions:**
- Performance characteristics (latency, throughput, scale)
- Reliability requirements (SLAs, error rates)
- Resource constraints (memory, CPU, network)
- Deployment environment (cloud, on-prem, edge)
- Data characteristics (volume, velocity, variety)

**Temporal assumptions:**
- Current state vs future state
- Growth trajectories
- Technology maturity
- Team capability evolution

**External dependencies:**
- Third-party services
- Infrastructure limitations
- Regulatory requirements
- Organizational constraints

### Phase 4: Edge Cases & Failure Modes
Stress test the proposal:

**Edge cases:**
- Boundary conditions (empty, null, max, min)
- Race conditions and concurrency
- Network partitions
- Partial failures
- Degraded mode operation
- Recovery scenarios

**Failure modes:**
- What breaks first under load?
- What happens when dependencies fail?
- How does it fail? (gracefully or catastrophically)
- What's the blast radius?
- Is it recoverable?

**Pathological inputs:**
- Malicious inputs
- Unexpected data shapes
- Legacy data compatibility
- Migration scenarios

### Phase 5: Trade-off Analysis
Question the trade-offs:

**Explicitly stated trade-offs:**
- Are they correctly characterized?
- Are there better alternatives?
- Is the chosen trade-off optimal?

**Unstated trade-offs:**
- What costs are hidden?
- What complexity is deferred?
- What technical debt is created?
- What flexibility is lost?

**Opportunity cost:**
- What else could be built with this effort?
- Is this the highest leverage work?
- What simpler alternatives exist?

### Phase 6: Alternative Perspectives
Challenge the framing:

**Different stakeholders:**
- How would Ops view this? Security? Product? Users?
- Who benefits? Who is harmed?
- What conflicts of interest exist?

**Different time horizons:**
- Right now vs 6 months vs 2 years
- Short-term gain for long-term pain?
- Technical debt accumulation

**Different scales:**
- Works at 100 users? 10K? 1M? 100M?
- Works with 1 developer? 10? 100?
- Works for 1 service? 10? 100?

## Deliverable Format

Provide structured critique in sections:

```markdown
## Summary
[One paragraph: strongest version of the argument and your assessment]

## Logical Structure
[Fallacies, reasoning errors, structural weaknesses]

## Unexamined Assumptions
[Hidden assumptions that may not hold]

## Edge Cases & Failure Modes
[Scenarios not accounted for]

## Trade-off Analysis
[Stated and unstated costs]

## Alternative Approaches
[Better/simpler alternatives to consider]

## Strongest Counter-Argument
[The most compelling case against this proposal]

## Questions to Answer
[Specific questions that must be resolved]
```

## Critical Analysis Modes

### Mode 1: Gentle Critique (Default)
- Point out issues diplomatically
- Assume good intent
- Collaborative tone
- Build on good ideas

### Mode 2: Rigorous Challenge
- Aggressive questioning
- No sacred cows
- Expose every weakness
- Test to destruction

### Mode 3: Security Mindset
- Adversarial attacker perspective
- What can go wrong?
- What's the blast radius?
- Defense in depth

### Mode 4: Operational Perspective
- "Who gets paged at 3am?"
- Observability, debuggability
- Failure modes and recovery
- Operational complexity

**Ask the user which mode they want, or default to Mode 1 (Gentle Critique).**

## Anti-Patterns to Avoid

**Don't:**
- Nitpick syntax/style (focus on substance)
- Argue for arguing's sake
- Use critique as gatekeeping
- Ignore context and constraints
- Demand perfection
- Critique without understanding

**Do:**
- Focus on high-impact issues
- Provide specific examples
- Acknowledge constraints
- Suggest concrete improvements
- Know when to accept "good enough"
- Build up the idea while testing it

## Stopping Conditions

Know when to stop:
- Argument is sound (don't invent problems)
- Issues are minor/acceptable
- Constraints are well understood
- Edge cases are handled
- Trade-offs are explicit and reasonable

**Don't manufacture objections if the idea is solid.**

## Integration with Other Skills

- **domain-driven-design**: Critique bounded contexts, aggregates, event designs
- **oltp-schema-design**: Challenge normalization, indexing, constraint choices
- **olap-schema-design**: Question dimensional models, fact table granularity
- **requirements-clarity**: Validate that requirements actually make sense
- **gepetto**: Provide adversarial review of implementation plans

## Examples

### Example 1: API Design Critique

**User:** "I'm designing a REST API where each user has a profile. Should I use PUT or PATCH for updates?"

**Critical Analysis:**

```markdown
## Summary
Question assumes REST semantics matter for the use case. Missing context about:
partial vs full updates, idempotency requirements, and client capabilities.

## Unexamined Assumptions
- REST semantics are important to your system
- Clients will use the API correctly
- Profile updates are simple field replacements
- No optimistic concurrency concerns

## Edge Cases
- What if two clients update different fields simultaneously?
- What about nested objects in profile?
- How do you handle null vs omitted fields in PATCH?
- What's the behavior for unknown fields?

## Alternative Approaches
- Use POST with explicit intent: `/profile/update-email`, `/profile/update-bio`
- Use GraphQL mutations (explicit fields)
- Use event sourcing (append-only commands)
- Consider if REST is the right pattern at all

## Questions to Answer
1. Do you need partial updates? (If no, use PUT and be done)
2. Do you have concurrent update conflicts? (Need versioning/ETags)
3. What fields exist in profile? (Flat vs nested changes the answer)
4. Who are the clients? (Internal services vs external developers)
```

### Example 2: Caching Strategy Critique

**User:** "We should cache database queries in Redis with a 5-minute TTL to improve performance."

**Critical Analysis:**

```markdown
## Summary
Generic caching proposal without specifics. Missing: what queries, what traffic
pattern, what consistency requirements, what cost/benefit analysis.

## Logical Fallacies
- Assumed caching improves performance (may add latency via network hop)
- Assumed 5 minutes is appropriate (arbitrary number)
- Assumed Redis is the right tool (may be over-engineering)

## Unexamined Assumptions
- Current performance is insufficient (is it really a problem?)
- Database is the bottleneck (has this been profiled?)
- Queries are cacheable (are results stable for 5 minutes?)
- Stale data is acceptable (what's the staleness tolerance?)
- Cache hit rate will be high enough to justify complexity

## Edge Cases
- Cache stampede (thundering herd on expiry)
- Cache poisoning (bad data cached for 5 minutes)
- Cache invalidation (how to bust cache on updates?)
- Cold start (empty cache after Redis restart)
- Network partition (Redis unreachable)

## Trade-off Analysis
**Stated:** Performance improvement
**Unstated:**
- Added operational complexity (deploy/monitor/maintain Redis)
- Cache consistency bugs
- Increased latency on cache miss (db + cache write)
- Memory costs for Redis
- Debugging difficulty (is issue in cache or DB?)

## Alternative Approaches
1. **Profile first** - Is DB actually slow? What queries?
2. **Optimize queries** - Add indexes, rewrite queries
3. **Application-level caching** - In-memory cache (simpler)
4. **Database query cache** - PostgreSQL shared buffers
5. **Read replicas** - Scale reads without caching complexity
6. **Materialized views** - Database-native caching

## Strongest Counter-Argument
Caching is a complexity multiplier. It introduces cache invalidation (one of the
hardest problems in CS), operational overhead, and subtle bugs. Unless you've
proven the database is the bottleneck AND queries are cacheable AND stale reads
are acceptable, this is premature optimization.

## Questions to Answer
1. What's the current 95th percentile latency?
2. What queries are slow? (Provide EXPLAIN plans)
3. What's the traffic pattern? (QPS, read/write ratio)
4. What's the staleness tolerance for each query?
5. What's the expected cache hit rate?
6. Have you tried simpler approaches first?
```

## Tactical Checklist

When analyzing an argument, ask:

```
[ ] What is the core claim?
[ ] What evidence supports it?
[ ] What assumptions are hidden?
[ ] What edge cases are unhandled?
[ ] What can go wrong?
[ ] What are the stated trade-offs?
[ ] What are the unstated trade-offs?
[ ] What simpler alternatives exist?
[ ] Who else should evaluate this?
[ ] What questions remain unanswered?
```

## References

For deeper study on critical thinking and argumentation:
- "Thinking, Fast and Slow" - Daniel Kahneman (cognitive biases)
- "The Demon-Haunted World" - Carl Sagan (skeptical thinking)
- "Release It!" - Michael Nygard (failure modes in production systems)
- "Site Reliability Engineering" - Google (operational perspective)
- List of logical fallacies: https://yourlogicalfallacyis.com/

---

**Remember:** The goal is not to tear down ideas, but to strengthen them through rigorous challenge. A battle-tested idea is worth 10 untested ones.
