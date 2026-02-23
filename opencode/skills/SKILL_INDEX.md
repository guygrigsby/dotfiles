# Agent Skills Catalog

**Total Skills:** 39  
**Last Updated:** 2026-02-23  
**Focus:** Go backend, DDD, microservices (gRPC), PostgreSQL, architecture documentation

---

## 🏗️ Architecture & Diagramming (3 skills)

### c4-architecture
Generate architecture documentation using C4 model Mermaid diagrams. Use when asked to create architecture diagrams, document system architecture, visualize software structure, create C4 diagrams, or generate context/container/component/deployment diagrams.

**Best for:** Documenting microservices architecture, system boundaries, service relationships

### mermaid-diagrams
Comprehensive guide for creating software diagrams using Mermaid syntax. Use when users need to create, visualize, or document software through diagrams including class diagrams, sequence diagrams, flowcharts, entity relationship diagrams, state diagrams, git graphs, and more.

**Best for:** Code-based, version-controllable diagrams for any purpose

### draw-io
draw.io diagram creation, editing, and review. Use for .drawio XML editing, PNG conversion, layout adjustment, and AWS icon usage.

**Best for:** Visual diagrams that colleagues create/maintain in draw.io format

---

## 💾 Database & API Documentation (6 skills)

### domain-driven-design
Comprehensive Domain-Driven Design patterns covering strategic (bounded contexts, context mapping, ubiquitous language) and tactical (aggregates, entities, value objects, repositories, domain events) DDD. Includes Go-specific implementation patterns and DDD-to-Schema mapping guidance for OLTP and OLAP systems.

**Best for:** Complex domain modeling, microservices boundaries, event-driven architecture

### oltp-schema-design
Design PostgreSQL OLTP schemas optimized for transactional workloads. Covers 5NF normalization, ACID guarantees, foreign key constraints, B-tree indexes, row-level locking, and DDD aggregate mapping. Ensures data integrity and write performance for high-concurrency systems.

**Best for:** Transactional systems, write-heavy workloads, data integrity

### olap-schema-design
Design dimensional models for analytical workloads using Star Schema and Kimball methodology. Covers fact tables, dimension tables, slowly changing dimensions, conformed dimensions, and query optimization for OLAP/CQRS read models. Optimizes for query performance over write complexity.

**Best for:** Analytics, reporting, BI tools, data warehouses, CQRS query side

### backend-to-frontend-handoff-docs
Create API handoff documentation for frontend developers. Use when backend work is complete and needs to be documented for frontend integration.

**Best for:** Documenting gRPC/REST APIs for consumers

### frontend-to-backend-requirements
Document frontend data needs for backend developers. Use when frontend needs to communicate API requirements to backend.

**Best for:** Specifying what you need from backend services

---

## 🔧 Version Control & Code Quality (5 skills)

### commit-work
Create high-quality git commits: review/stage intended changes, split into logical commits, and write clear commit messages (including Conventional Commits).

**Best for:** Creating well-structured git commits with clear messages

### commit-refinement
Polish and organize commits using interactive rebase. Structure narrative, ensure atomic commits, write quality messages. Based on GitHub's "Write Better Commits, Build Better Projects" guidance.

**Best for:** Refining commit history before opening PRs, organizing messy commits

### naming-analyzer
Suggest better variable, function, and class names based on context and conventions.

**Best for:** Improving code readability through better naming

### lesson-learned
Analyze recent code changes via git history and extract software engineering lessons. Use when the user asks 'what is the lesson here?', 'what can I learn from this?', or wants to extract principles from recent work.

**Best for:** Reflecting on code changes and extracting engineering principles

### reducing-entropy
Manual-only skill for minimizing total codebase size. Only activate when explicitly requested by user. Measures success by final code amount, not effort. Bias toward deletion.

**Best for:** Aggressive code cleanup and simplification

---

## 📋 Planning & Requirements (5 skills)

### critical-analysis
Rigorous adversarial analysis of technical arguments, architectural decisions, and engineering proposals. Identifies logical fallacies, unexamined assumptions, edge cases, and conceptual weaknesses through structured critique. Use when you need pushback on ideas or want to strengthen proposals through challenge.

**Best for:** Poking holes in technical arguments, stress-testing architectural decisions, finding edge cases

### requirements-clarity
Clarify ambiguous requirements through focused dialogue before implementation. Use when requirements are unclear, features are complex (>2 days), or involve cross-team coordination. Ask two core questions - Why? (YAGNI check) and Simpler? (KISS check).

**Best for:** Pre-implementation requirement clarification

### gepetto
Creates detailed, sectionized implementation plans through research, stakeholder interviews, and multi-LLM review. Use when planning features that need thorough pre-implementation analysis.

**Best for:** Complex feature planning with stakeholder input

### beads-planning
Persistent issue tracking for complex, multi-session work using bd (beads). Automatically suggested when agent detects complexity (3+ steps, dependencies, multi-session scope). Integrates with session-close, session-handoff, and gepetto skills.

**Best for:** Features, refactors, and projects spanning multiple sessions

### game-changing-features
Find 10x product opportunities and high-leverage improvements. Use when user wants strategic product thinking or wants to find high-impact features.

**Best for:** Strategic product thinking, finding leverage points

---

## 📝 Documentation & Writing (3 skills)

### crafting-effective-readmes
Use when writing or improving README files. Not all READMEs are the same — provides templates and guidance matched to your audience and project type.

**Best for:** Creating effective README files for different audiences

### writing-clearly-and-concisely
Use when writing prose humans will read—documentation, commit messages, error messages, explanations, reports, or UI text. Applies Strunk's timeless rules for clearer, stronger, more professional writing.

**Best for:** Improving clarity and conciseness in all technical writing

### agent-md-refactor
Refactor bloated AGENTS.md, CLAUDE.md, or similar agent instruction files to follow progressive disclosure principles. Splits monolithic files into organized, linked documentation.

**Best for:** Organizing large agent instruction documents

---

## ⚙️ Development Tools (5 skills)

### dependency-updater
Smart dependency management for any language. Auto-detects project type, applies safe updates automatically, prompts for major versions, diagnoses and fixes dependency issues.

**Best for:** Updating Go modules, npm packages, etc.

### command-creator
Create Claude Code slash commands. Use when users ask to "create a command", "make a slash command", or want to document a workflow as a reusable command.

**Best for:** Creating custom Claude Code slash commands

### plugin-forge
Create and manage Claude Code plugins with proper structure, manifests, and marketplace integration.

**Best for:** Building Claude Code plugins

### skill-judge
Evaluate Agent Skill design quality against official specifications and best practices. Provides multi-dimensional scoring and actionable improvement suggestions.

**Best for:** Reviewing and improving SKILL.md files

### domain-name-brainstormer
Generates creative domain name ideas for your project and checks availability across multiple TLDs (.com, .io, .dev, .ai, etc.).

**Best for:** Naming services, APIs, projects; checking domain availability

---

## 🔄 Session & Workflow Management (3 skills)

### session-handoff
Creates comprehensive handoff documents for seamless AI agent session transfers. Proactively suggests handoffs after substantial work. Solves long-running agent context exhaustion.

**Best for:** Saving context when pausing work or hitting context limits

### session-close
Protocol for properly ending a coding session - ensures all work is committed, pushed, and handed off correctly.

**Best for:** Properly closing out a coding session

### daily-meeting-update
Interactive daily standup/meeting update generator. Pulls activity from GitHub, Jira, and Claude Code session history. Conducts 4-question interview and generates formatted Markdown update.

**Best for:** Generating standup updates, status reports

---

## 💬 Communication & Soft Skills (2 skills)

### difficult-workplace-conversations
Structured approach to workplace conflicts, performance discussions, and challenging feedback using preparation-delivery-followup framework.

**Best for:** Preparing for difficult conversations, delivering feedback

### professional-communication
Guide technical communication for software developers. Covers email structure, team messaging etiquette, meeting agendas, and adapting messages for technical vs non-technical audiences.

**Best for:** Writing professional emails, meeting communications

---

## 🎯 Specialized Tools (4 skills)

### qa-test-planner
Generate comprehensive test plans, manual test cases, regression test suites, and bug reports for QA engineers. Includes Figma MCP integration for design validation.

**Best for:** Creating test plans and test cases

### design-system-starter
Create and evolve design systems with design tokens, component architecture, accessibility guidelines, and documentation templates.

**Best for:** Building design systems (if working with frontend teams)

### marp-slide
Create professional Marp presentation slides with 7 beautiful themes. Supports custom themes, image layouts, and "make it look good" requests.

**Best for:** Creating technical presentations in Markdown

### perplexity
Web search and research using Perplexity AI. Use when user says "search", "find", "look up", "research", or "what's the latest" for generic queries.

**Best for:** Web research and current information lookup

---

## 🔌 Integrations (2 skills)

### jira
Use when the user mentions Jira issues, asks about tickets, wants to create/view/update issues, check sprint status, or manage Jira workflow.

**Best for:** Jira issue management and workflow

### humanizer
Remove signs of AI-generated writing from text. Use when editing or reviewing text to make it sound more natural and human-written.

**Best for:** Making AI-generated text sound more human

---

## Quick Reference by Use Case

### Working on Go Microservices
- domain-driven-design (bounded contexts, aggregates, events)
- oltp-schema-design (transactional PostgreSQL schemas)
- olap-schema-design (analytics/reporting schemas, CQRS query side)
- backend-to-frontend-handoff-docs (API docs)
- c4-architecture (system diagrams)
- mermaid-diagrams (sequence/component diagrams)
- requirements-clarity (feature planning)

### Database Design
- **Write-heavy transactional systems:** oltp-schema-design (5NF, ACID, foreign keys)
- **Read-heavy analytics/reporting:** olap-schema-design (Star Schema, Kimball, fact/dimension tables)
- **Domain modeling:** domain-driven-design (aggregates, entities, value objects, events)
- **CQRS:** oltp-schema-design (command side) + olap-schema-design (query side)

### Code Quality & Review
- naming-analyzer
- lesson-learned
- commit-work
- commit-refinement
- writing-clearly-and-concisely
- reducing-entropy

### Planning & Documentation
- requirements-clarity
- gepetto
- crafting-effective-readmes
- c4-architecture
- mermaid-diagrams

### Team Communication
- difficult-workplace-conversations
- professional-communication
- daily-meeting-update
- backend-to-frontend-handoff-docs

### Development Workflow
- commit-work (creating git commits)
- commit-refinement (polishing git commits)
- dependency-updater (package management)
- session-handoff (context preservation)
- session-close (end of session)

---

## Progressive Disclosure

All skills follow progressive disclosure principles:
- Main SKILL.md files are kept under 200 lines for quick reference
- Detailed reference material is in `references/` subdirectories
- Skills use `context: fork` in frontmatter for memory efficiency

See **PROGRESSIVE_DISCLOSURE.md** for detailed guidelines.

---

## Related Files

- **REMOVED_SKILLS.md** - Archive of 13 removed skills with restoration instructions
- **Individual skill directories** - Each contains SKILL.md with detailed usage instructions

---

## Maintenance Notes

**Recent Updates:**
- 2026-02-23: Added critical-analysis skill (adversarial critique, logical fallacy detection, edge case analysis)
- 2026-02-16: Added olap-schema-design skill (Star Schema, Kimball methodology, CQRS query side)
- 2026-02-14: Removed 13 skills (28% reduction) - See REMOVED_SKILLS.md
  - Beads Epic: SKILL-crl

**Skill Organization Principles:**
1. Focus on actual tech stack (Go, PostgreSQL, gRPC, DDD)
2. Remove framework-specific skills not in use (React, MUI, etc.)
3. Remove external integrations not configured (Codex, Gemini, Datadog)
4. Eliminate duplicates (kept difficult-workplace-conversations, removed feedback-mastery)
5. Keep versatile tools (Mermaid) over multiple specialized ones
