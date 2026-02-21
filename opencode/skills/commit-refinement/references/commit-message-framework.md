# Commit Message Framework

## Introduction

Commit messages are your opportunity to speak directly to reviewers and future developers. They explain not just what changed, but why it changed and how it was accomplished.

This guide presents a systematic framework for writing commit messages that provide context, justify decisions, and make code maintainable.

**Key insight from GitHub**: "What" and "why" break down into high-level and low-level details, which can be framed as four questions to answer in each commit message.

## The What/Why Matrix

Every commit message should address both **what** you're doing and **why** you're doing it, at both strategic and tactical levels:

|           | WHAT (doing)             | WHY (reason)                |
|-----------|--------------------------|---------------------------- |
| **High-level** (strategic) | **Intent**<br/>*What does this accomplish?* | **Context**<br/>*Why does code do what it does now?* |
| **Low-level** (tactical) | **Implementation**<br/>*What did you do to accomplish your goal?* | **Justification**<br/>*Why is this change being made?* |

### The Four Questions

#### 1. Intent (High-level What)

**Question**: What does this commit accomplish?

**Answer location**: Subject line / title

**Characteristics**:
- High-level goal or outcome
- Imperative mood ("Add" not "Added")
- Specific and concise
- Summarizes the commit's purpose

**Examples**:
- ✅ "Add user authentication"
- ✅ "Fix null pointer in email validation"
- ✅ "Refactor database connection pooling"
- ❌ "Updated files" (too vague)
- ❌ "Made changes to auth" (not specific)

#### 2. Context (High-level Why)

**Question**: Why does the code do what it does now? What's the current state/problem?

**Answer location**: First paragraph of body

**Characteristics**:
- Sets up the situation
- Explains current state or problem
- Provides background
- Helps reader understand necessity

**Examples**:
- "Users were accessing protected resources without verification"
- "Login form didn't validate email field presence, causing crashes"
- "Database connection pool exhaustion under high load"
- "React 16 component lifecycle methods are deprecated"

#### 3. Justification (Low-level Why)

**Question**: Why was THIS approach/change made? Why this solution?

**Answer location**: Middle of body

**Characteristics**:
- Explains decision rationale
- Discusses trade-offs if relevant
- Mentions alternatives considered
- Justifies the approach taken

**Examples**:
- "JWT tokens provide stateless auth without session storage"
- "Both 'grey' and 'gray' are common spellings users expect"
- "Redis caching reduces DB queries from 1000/sec to 50/sec"
- "Hooks are the future of React and easier to test"

#### 4. Implementation (Low-level What)

**Question**: What did you DO to accomplish the goal? How was it implemented?

**Answer location**: Later in body (or omit if obvious from code)

**Characteristics**:
- Technical details
- How the solution works
- What was changed technically
- Only include if not obvious from diff

**Examples**:
- "Add JWT middleware to verify tokens on protected routes"
- "Add null check before calling toLowerCase() on email"
- "Implement connection pool with max size of 20"
- "Convert class components to functional components with hooks"

## Message Template

### Basic Template

```
<type>(<scope>): <Intent - what this accomplishes>

<Context - why the code does what it does now>

<Justification - why THIS approach was chosen>

<Implementation - how it was done, if not obvious>

<Footer - breaking changes, issue refs>
```

### With Conventional Commits

```
type(scope): imperative subject line (max 72 chars)

Body paragraph explaining context - what's the current situation
or problem that necessitates this change? What background does
the reader need?

Second paragraph explaining justification - why this particular
approach? What trade-offs were considered? Why is this the right
solution?

Optional third paragraph on implementation details if they're not
obvious from reading the code diff. Don't duplicate what's in the
code; explain higher-level "how" if needed.

BREAKING CHANGE: Description of backwards incompatible changes
Fixes #123
Refs #456
```

### Conventional Commits Types

- **feat**: New feature
- **fix**: Bug fix  
- **refactor**: Code restructuring (no behavior change)
- **docs**: Documentation only
- **test**: Test additions/changes
- **chore**: Maintenance tasks (deps, config)
- **perf**: Performance improvement
- **style**: Formatting (no logic change)
- **ci**: CI/CD changes
- **build**: Build system changes

## Examples at Different Complexity Levels

### Simple Change

For straightforward changes, a concise message covering intent + justification is sufficient.

```
fix(ui): correct button alignment in header

Buttons were misaligned after recent CSS grid migration.
Center them using flexbox to match design spec.
```

**Analysis**:
- **Intent**: "correct button alignment" (in subject)
- **Context**: "after CSS grid migration" (brief)
- **Justification**: "match design spec"
- **Implementation**: "using flexbox" (very brief, obvious from diff)

### Medium Complexity

More complex changes need fuller explanation.

```
feat(auth): add password reset workflow

Users had no way to recover accounts when passwords were forgotten,
requiring manual admin intervention for every reset request.

Implement self-service password reset using time-limited tokens sent
via email. Tokens expire after 1 hour and can only be used once.
Uses existing email service and token generation utilities.

Refs #234
```

**Analysis**:
- **Intent**: "add password reset workflow"
- **Context**: "Users had no way to recover accounts..."
- **Justification**: "self-service... using time-limited tokens" + security rationale
- **Implementation**: "Uses existing email service and token generation"

### Complex Change

Complex changes warrant full treatment of all four elements.

```
fix(auth): prevent token reuse after logout

Currently, JWT tokens remain valid until expiration (24 hours) even
after user logout. This allows potential security issues if tokens
are intercepted or stolen - an attacker could use a token even after
the user has logged out.

To invalidate tokens immediately on logout, maintain a token blocklist
in Redis with TTL matching token expiration. The auth middleware checks
this blocklist before validating token claims. This adds ~2ms latency
to auth checks but closes the security gap.

The blocklist automatically cleans up expired entries using Redis TTL,
so no manual cleanup is needed. Token hashes (not full tokens) are
stored to minimize security exposure if the blocklist itself is
compromised.

BREAKING CHANGE: Requires Redis instance for auth service. Update
deployment config to include Redis connection string in AUTH_REDIS_URL
environment variable.

Fixes #567
```

**Analysis**:
- **Intent**: "prevent token reuse after logout" (security fix)
- **Context**: "JWT tokens remain valid... security issues..." (detailed problem)
- **Justification**: "invalidate immediately... closes security gap" (why this solution)
- **Implementation**: "token blocklist in Redis... checks before validating..." (technical approach)
- **Trade-offs**: "adds ~2ms latency" (honest about costs)
- **Details**: "Token hashes... minimize exposure" (security consideration)
- **Footer**: Breaking change with deployment implications

### Refactoring Example

Refactoring commits should emphasize "why" even more since "what" may be extensive.

```
refactor(api): extract validation logic into middleware

Route handlers in api/routes.js have grown to 200+ lines each, with
repeated validation code making them hard to test and maintain.
Adding new validation rules requires touching multiple handlers,
increasing error risk.

Extract validation into reusable middleware functions that can be
composed and tested independently. This follows single responsibility
principle and makes validation logic reusable across all routes.
Each middleware validates one concern (auth, input format, business
rules) and can be unit tested in isolation.

No functional changes - all existing tests pass without modification.
The refactoring makes validation logic explicit and easier to extend
for future requirements.
```

**Analysis**:
- **Intent**: "extract validation logic"
- **Context**: "handlers have grown... repeated code..."
- **Justification**: "single responsibility... reusable... easier to test"
- **Implementation**: "middleware functions... composed"
- **Assurance**: "No functional changes" (important for refactoring)

### Performance Optimization Example

Performance commits should include measurements.

```
perf(db): add index on users.email for faster lookups

Query performance degraded as user table grew beyond 100k rows.
Email lookups during login were taking 200-500ms per request,
causing poor user experience and timeout errors under load.

Adding B-tree index on email column reduces lookup time to <5ms.
Benchmark shows 40x improvement in query performance. Slight
overhead on inserts (~1ms) is acceptable given read-heavy workload
(1000:1 read/write ratio).

Index created with CONCURRENTLY option to avoid locking during
deployment. Migration tested on staging with 250k user records.
```

**Analysis**:
- **Intent**: "add index... for faster lookups"
- **Context**: "degraded... 200-500ms" (measured problem)
- **Justification**: "40x improvement... acceptable trade-off" (quantified benefit)
- **Implementation**: "B-tree index... CONCURRENTLY" (technical approach)
- **Validation**: "Migration tested on staging" (de-risked)

## Tailoring Detail to Complexity

Not every commit needs all four elements explicitly stated. Tailor detail to complexity:

### When to Be Brief

**Simple changes can be concise** but should still cover what/why:

```
fix(ui): remove duplicate import in Header.jsx
```

Intent and implementation are obvious; context/justification would be redundant.

```
docs(api): fix typo in authentication endpoint docs

Changed "athentication" to "authentication" in POST /login docs.
```

Trivial fix with minimal context needed.

### When to Be Thorough

**Complex changes need full explanation**:

- Architectural decisions
- Security fixes
- Performance optimizations
- Breaking changes
- Refactorings affecting many files
- Bug fixes with subtle causes
- Changes affecting public APIs

**Rule of thumb**: If a reviewer might ask "why did you do it this way?", answer preemptively in the message.

## Integration with Conventional Commits

Conventional Commits provides structure for the subject line. The body follows the What/Why framework:

### Format

```
<type>(<scope>): <imperative subject>
<blank line>
<body with What/Why framework>
<blank line>
<footer>
```

### Complete Example

```
feat(payments): add Stripe payment integration

The current manual payment processing requires admin review of each
transaction, creating delays and scaling issues as user base grows.
Automation is needed for instant payment confirmation.

Stripe provides PCI-compliant payment processing with strong fraud
detection and supports all major payment methods. Integration is
straightforward with their official SDK and reduces our compliance
burden.

Add Stripe SDK and implement payment creation, confirmation, and
webhook handling for payment events. Webhook events update order
status automatically when payment succeeds or fails.

BREAKING CHANGE: Payment API endpoint signature changed from
POST /api/pay to POST /api/payments/create to match Stripe conventions.
Clients must update API calls.

Refs #789
```

## Common Mistakes and How to Fix Them

### ❌ Mistake 1: Vague Intent

**Bad**:
```
fix: fix bug
```

**Why it's bad**: No information about what was actually fixed.

**Good**:
```
fix(auth): prevent null pointer when email field is missing

Login form didn't validate email presence before calling
toLowerCase(), causing crashes on empty submission.
Add null check before string operations.
```

### ❌ Mistake 2: Implementation Diary

**Bad**:
```
Add authentication

First I tried using sessions but that didn't work because of
CORS issues. Then I tried OAuth but the library was outdated.
Finally I settled on JWT which seems to work better after I
fixed the secret key configuration.
```

**Why it's bad**: Describes the journey, not the destination. Reviewers don't need your debug log.

**Good**:
```
feat(auth): add JWT-based authentication

Users need secure access to protected resources without
maintaining server-side session state for scalability.

JWT provides stateless authentication that scales horizontally
and integrates well with our microservices architecture.
Tokens expire after 24 hours and include user role claims
for authorization.
```

### ❌ Mistake 3: No "Why"

**Bad**:
```
Add caching layer

Added Redis caching to the application with 5-minute TTL.
Implemented cache-aside pattern with automatic invalidation.
```

**Why it's bad**: Technical details without context or justification.

**Good**:
```
perf(api): add Redis caching layer

API response times increased to 2-3 seconds under load due to
repeated database queries for largely static data (config,
user preferences).

Add Redis cache with 5-minute TTL to reduce DB load from
1000 queries/sec to ~50 queries/sec. Cache-aside pattern allows
DB to remain source of truth while serving frequently accessed
data from memory.
```

### ❌ Mistake 4: Too Much Detail

**Bad**:
```
Update user controller

Modified UserController.java lines 42-87 to change the return
type from void to boolean. Updated the method signature to
accept an additional parameter for validation mode. Refactored
the internal logic to use a switch statement instead of if-else
chains. Changed variable names to be more descriptive (u -> user,
v -> validationMode). Added comments explaining each section.
Updated corresponding test file UserControllerTest.java lines
123-145 to match new signature...
```

**Why it's bad**: Duplicates information visible in the diff. Too detailed.

**Good**:
```
refactor(api): improve user controller validation logic

User validation logic was hard to follow due to deeply nested
conditionals and unclear variable names.

Simplify control flow with switch statement and descriptive names.
Return boolean to indicate success/failure rather than throwing
exceptions for better error handling at call sites.
```

### ❌ Mistake 5: Mixing Concerns in Message

**Bad**:
```
Various fixes and improvements

- Fixed login bug
- Added new dashboard widget
- Updated dependencies
- Refactored validation code
- Fixed typos in docs
```

**Why it's bad**: This message describes multiple commits mixed into one.

**Good**: Split into separate commits, each with focused message:
```
fix(auth): prevent null pointer in login validation
feat(dashboard): add weekly analytics widget
chore(deps): update React from 16.8 to 18.2
refactor(api): extract validation into middleware
docs(api): fix typos in endpoint descriptions
```

## Tips for Writing

### Before Committing

1. **Review the diff**: Understand exactly what you're committing
   ```bash
   git diff --cached
   ```

2. **Describe in one sentence**: If you can't, commit is probably too large
   ```
   "This commit adds email validation to prevent null pointer errors"
   ```

3. **Ask yourself**:
   - What does this accomplish? (Intent)
   - Why was it needed? (Context)
   - Why this approach? (Justification)
   - How does it work? (Implementation - if not obvious)

### While Writing

1. **Use `git commit -v`**: See diff while writing message

2. **Write intent first**: Start with subject line to focus your thinking

3. **Add context**: Explain the "before" state or problem

4. **Justify your choice**: Explain why this solution

5. **Keep it concise**: Be thorough but not verbose

### After Writing

1. **Read it aloud**: Does it make sense?

2. **Imagine yourself in 6 months**: Will you understand why you made this change?

3. **Think like a reviewer**: Does this give them the context they need?

4. **Check formatting**:
   - Subject line < 72 characters
   - Blank line after subject
   - Body wrapped at 72 characters
   - Imperative mood in subject

## Subject Line Best Practices

### Length

- **Maximum 72 characters** (GitHub truncates at 72)
- **Aim for 50-60** if possible
- Use body for detail, subject for summary

### Mood

- **Use imperative**: "Add" not "Added" or "Adds"
- Why? Matches Git's own convention ("Merge branch", "Revert commit")

**Examples**:
- ✅ "Add user authentication"
- ✅ "Fix null pointer in validation"
- ✅ "Refactor database connection pooling"
- ❌ "Added user authentication"
- ❌ "Fixes null pointer"
- ❌ "Refactoring database code"

### Be Specific

- **Specific**: "Fix off-by-one error in pagination"
- **Vague**: "Fix bug"

- **Specific**: "Add Redis caching for user sessions"
- **Vague**: "Improve performance"

### Include Scope

```
feat(auth): add password reset workflow
fix(ui): correct button alignment in header
perf(db): add index on users.email
docs(api): update authentication endpoint examples
```

Scope helps readers quickly understand which part of codebase changed.

## Body Best Practices

### Formatting

- **Wrap at 72 characters** for readability in terminals
- **Use blank lines** to separate paragraphs
- **Use bullet points** for lists when appropriate

### Structure

1. **First paragraph**: Context/problem
2. **Second paragraph**: Justification/solution
3. **Third paragraph** (optional): Implementation details
4. **Footer**: References, breaking changes

### Tone

- **Be objective**: State facts, not opinions
- **Be concise**: Thorough but not verbose
- **Be helpful**: Future you will thank current you

## Footer Best Practices

### Issue References

```
Fixes #123
Refs #456, #789
Closes #234
```

### Breaking Changes

```
BREAKING CHANGE: Remove deprecated /api/v1/users endpoint.
Use /api/v2/users instead.
```

### Co-authors

```
Co-authored-by: Jane Developer <jane@example.com>
```

## Complete Real-World Examples

### Example 1: Security Fix

```
fix(auth): prevent timing attack in password comparison

String equality (==) for password comparison creates timing
vulnerability. Execution time varies based on how many characters
match, allowing attackers to guess passwords character-by-character
by measuring response times.

Use constant-time comparison (crypto.timingSafeEqual) to prevent
timing attacks. All comparisons take same time regardless of input,
eliminating timing side-channel.

Security advisory: CVE-2024-XXXX
Refs #2341
```

### Example 2: Feature Addition

```
feat(api): add rate limiting middleware

Public API endpoints had no request throttling, allowing abuse
and causing service degradation during traffic spikes. Need to
protect infrastructure while allowing legitimate usage.

Implement rate limiting with Redis-backed sliding window counter.
Default limit: 100 requests per hour per IP address. Configurable
per endpoint with X-RateLimit headers informing clients of limits
and remaining quota.

Excluded routes: /api/health, /api/status (needed for monitoring)

BREAKING CHANGE: Requires Redis connection. Set REDIS_URL
environment variable before deploying.

Refs #1234
```

### Example 3: Refactoring

```
refactor(api): extract error handling into middleware

Error handling duplicated across 20+ route handlers with
inconsistent behavior (some return JSON, some HTML, different
status codes for same errors). Adding new error types requires
updating all handlers.

Centralize error handling in Express middleware that normalizes
all errors to consistent JSON format with appropriate HTTP
status codes. Handlers can now throw errors and middleware
handles formatting automatically.

No behavior changes for valid requests. Error responses now
consistently JSON-formatted with { error: { message, code } }
structure. Existing clients should handle this gracefully as
all use JSON.parse() on error responses.
```

## Summary Checklist

Before committing, verify your message has:

- [ ] **Clear intent** in subject line (what this accomplishes)
- [ ] **Context** explaining current state/problem
- [ ] **Justification** for chosen approach
- [ ] **Implementation** details if not obvious from diff
- [ ] **Conventional Commit** format (type, scope)
- [ ] **Subject < 72 chars**, imperative mood
- [ ] **Body wrapped** at 72 characters
- [ ] **Issue references** if applicable
- [ ] **Breaking change** warnings if applicable
- [ ] **Co-authors** if pair programming

**Quick test**: Can someone unfamiliar with your work understand:
- What changed?
- Why it was needed?
- Why you chose this approach?

If yes, you've written a good commit message!

---

**Remember**: Commit messages are documentation. Invest time in writing them well—your future self and teammates will thank you.
