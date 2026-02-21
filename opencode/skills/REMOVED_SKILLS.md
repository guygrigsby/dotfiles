# Removed Skills Archive

This document contains information about skills that were removed from this directory on 2026-02-14.

**Removal Rationale:** Focus on Go backend, Domain-Driven Design, microservices (gRPC), and PostgreSQL work. These skills were not aligned with the current tech stack.

---

## Category 1: React/Frontend Skills (3 removed)

### mui
- **Description:** Material-UI v7 component library patterns including sx prop styling, theme integration, responsive design, and MUI-specific hooks. Use when working with MUI components, styling with sx prop, theme customization, or MUI utilities.
- **Removal Reason:** Not relevant to Go backend development

### react-dev
- **Description:** This skill should be used when building React components with TypeScript, typing hooks, handling events, or when React TypeScript, React 19, Server Components are mentioned. Covers type-safe patterns for React 18-19 including generic components, proper event typing, and routing integration (TanStack Router, React Router).
- **Removal Reason:** Not relevant to Go backend development

### react-useeffect
- **Description:** React useEffect best practices from official docs. Use when writing/reviewing useEffect, useState for derived values, data fetching, or state synchronization. Teaches when NOT to use Effect and better alternatives.
- **Removal Reason:** Not relevant to Go backend development

---

## Category 2: External LLM APIs (3 removed)

### codex
- **Description:** Use when the user asks to run Codex CLI (codex exec, codex resume) or references OpenAI Codex for code analysis, refactoring, or automated editing. Uses GPT-5.2 by default for state-of-the-art software engineering.
- **Removal Reason:** External LLM API not in use

### gemini
- **Description:** Use when the user asks to run Gemini CLI for code review, plan review, or big context (>200k) processing. Ideal for comprehensive analysis requiring large context windows. Uses Gemini 3 Pro by default for state-of-the-art reasoning and coding.
- **Removal Reason:** External LLM API not in use

### gremlin
- **Description:** Write Gremlin graph traversal queries for Neptune using the gremlin-go driver patterns in this codebase
- **Removal Reason:** Graph database (AWS Neptune) not used; project uses PostgreSQL

---

## Category 3: Non-Core Tools (2 removed)

### meme-factory
- **Description:** Generate memes using the memegen.link API. Use when users request memes, want to add humor to content, or need visual aids for social media. Supports 100+ popular templates with custom text and styling.
- **Removal Reason:** Not a professional development tool

### ship-learn-next
- **Description:** Transform learning content (like YouTube transcripts, articles, tutorials) into actionable implementation plans using the Ship-Learn-Next framework. Use when user wants to turn advice, lessons, or educational content into concrete action steps, reps, or a learning quest.
- **Removal Reason:** Niche learning framework with limited applicability

---

## Category 4: External Dependencies (2 removed)

### web-to-markdown
- **Description:** Use ONLY when the user explicitly says: 'use the skill web-to-markdown ...' (or 'use a skill web-to-markdown ...'). Converts webpage URLs to clean Markdown by calling the local web2md CLI (Puppeteer + Readability), suitable for JS-rendered pages.
- **Removal Reason:** Requires external CLI tool (web2md); rarely used; explicit trigger only

### datadog-cli
- **Description:** Datadog CLI for searching logs, querying metrics, tracing requests, and managing dashboards. Use this when debugging production issues or working with Datadog observability.
- **Removal Reason:** Datadog not in current observability stack

---

## Category 5: Redundant/TypeScript-Specific (2 removed)

### feedback-mastery
- **Description:** Navigate difficult conversations and deliver constructive feedback using structured frameworks. Covers the Preparation-Delivery-Follow-up model and Situation-Behavior-Impact (SBI) feedback technique. Use when preparing for difficult conversations, giving feedback, or managing conflicts.
- **Removal Reason:** Exact duplicate of `difficult-workplace-conversations` skill

### openapi-to-typescript
- **Description:** Converts OpenAPI 3.0 JSON/YAML to TypeScript interfaces and type guards. This skill should be used when the user asks to generate types from OpenAPI, convert schema to TS, create API interfaces, or generate TypeScript types from an API specification.
- **Removal Reason:** TypeScript-specific; not useful for Go backend work

---

## Category 6: Visual Diagram Format (1 removed)

### excalidraw
- **Description:** Use when working with *.excalidraw or *.excalidraw.json files, user mentions diagrams/flowcharts, or requests architecture visualization - delegates all Excalidraw operations to subagents to prevent context exhaustion from verbose JSON (single files: 4k-22k tokens, can exceed read limits)
- **Removal Reason:** Excalidraw format not personally used; kept `draw-io` for colleagues; `mermaid-diagrams` and `c4-architecture` provide code-based diagramming

---

## Summary

**Total Removed:** 13 skills (28% reduction from 46 to 33 skills)

**Retained Skills:** 33 skills focused on:
- Go backend development
- Domain-Driven Design (DDD)
- Microservices architecture (gRPC)
- PostgreSQL database design
- Architecture documentation (C4, Mermaid)
- Git workflow (Jujutsu)
- Code quality and planning
- Technical communication

**Removal Date:** 2026-02-14  
**Beads Epic:** SKILL-crl

---

## Category 4: Version Control Migration (1 removed - 2026-02-14)

### jujutsu

**Reason:** Replaced with git-based workflows for better token efficiency in agentic sessions.

**Migration:** The jujutsu squash pattern has been replaced with git fixup commits:

- **Old (jj):** `jj new -m "msg" && jj new && ... && jj squash`
- **New (git):** `git commit -m "msg" && ... && git commit --fixup HEAD && git rebase -i --autosquash main`

**Key differences:**
- No empty/planning commits - commit when code is ready
- Fixup commits for iterative refinement
- Rebase before opening PR, then use additive/fixup commits
- GitHub squash merge for final cleanup

**Workflow phases:**
1. **Local development (pre-PR):** Use fixup commits, squash before opening PR
2. **PR open (in review):** Push additive or fixup commits directly (no rebase!)
3. **After merge:** GitHub squash merge combines all commits cleanly

**Documentation:**
- See `commit-work/SKILL.md` for fixup workflow
- See `commit-work/references/fixup-workflow.md` for comprehensive guide
- See `session-close/SKILL.md` for PR-aware rebase logic

**Configuration:**
```bash
git config --global rebase.autosquash true
git config --global pull.rebase true
git config --global log.abbrevCommit true
git config --global diff.algorithm histogram
```

**Token savings:** ~2,000-2,500 tokens per session with VCS operations

**Removal Date:** 2026-02-14  
**Beads Epic:** skill-i95

---

## Restoration Instructions

If you need to restore any of these skills, they are available in git history before this removal. Use:

```bash
# View this file's history to find the removal commit
git log --oneline REMOVED_SKILLS.md

# Restore a specific skill directory from before the removal
git checkout <commit-before-removal> -- <skill-directory-name>
```
