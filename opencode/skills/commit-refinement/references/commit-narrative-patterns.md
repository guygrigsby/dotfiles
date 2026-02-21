# Commit Narrative Patterns

## Introduction

Just as a good story has structure, good commits form a narrative that guides readers through your changes. This document provides patterns for organizing commits into coherent, reviewable stories.

**Key concept**: Think of commits as building blocks that construct your narrative. Each block should be a specific type (refactor, feature, fix, test, docs) and placed in a logical order.

### Why Narrative Matters

A well-structured commit narrative:
- **Helps reviewers**: They can evaluate changes incrementally without overwhelming context switches
- **Aids debugging**: `git bisect` can pinpoint issues in smaller, focused commits
- **Supports collaboration**: Other developers understand not just what changed, but why and how
- **Documents evolution**: Future maintainers see the thought process behind decisions

## Pattern 1: Linear Feature Build

**Use when**: Implementing a new feature from scratch

**Structure**:
1. Foundation commit (setup, scaffolding, dependencies)
2. Core implementation (the heart of the feature)
3. Edge cases and refinements
4. Tests
5. Documentation

**Rationale**: Build from the ground up. Each commit sets up what follows. Reviewers can understand the foundation before evaluating how it's used.

### Example: Image Manipulation Feature

**Original messy history**:
```
6a885eb WIP
692f477 Finish script
b3348a0 Add --invert and --grey
9512893 Add --output option
1689371 Add GitHub Actions CI .yml
6af4476 Add requirements.txt + other build fixes
9cd6412 Let users use --gray option spelling
```

**Problems**:
- WIP commits clutter narrative
- Requirements.txt added late (needed from the start)
- Gray spelling added separately from grey option
- No clear progression

**Refined linear narrative**:
```
096ee13 Create initial image modifier script
        - Basic script structure
        - Argument parsing foundation
        - Image loading capability
        - requirements.txt for dependencies
        
381d3af Add --output option
        - Extend argparse with output path
        - Add save functionality
        
3e5e5f6 Add --invert option
        - Implement color inversion
        - Extend modifier choices
        
2d164e2 Add --grey option
        - Implement greyscale conversion
        - Add to modifier choices
        
851f2a0 Add --gray as alias for --grey
        - Accept both spellings
        - Update argparse definition
        
3bf4ec4 Add GitHub Actions CI
        - Linting workflow
        - Dependency installation
        - Test runner configuration
```

**Why this is better**:
- Clear progression: basic → features → polish → infrastructure
- Each commit is self-contained
- Dependencies (requirements.txt) included where first needed
- Related changes grouped (grey/gray together)

### Example: API Endpoint

**Linear build**:
```
1. Add database schema for user profiles
2. Add UserProfile model and repository
3. Add GET /api/users/:id endpoint
4. Add POST /api/users endpoint  
5. Add PUT /api/users/:id endpoint
6. Add request validation middleware
7. Add integration tests for user API
8. Add API documentation
```

Each step builds on the previous, making review straightforward.

## Pattern 2: Refactor-Then-Implement

**Use when**: Code needs restructuring before adding a feature

**Structure**:
1. Extract/isolate existing components
2. Simplify or clean up extracted code
3. Implement new feature using clean foundation
4. Add tests for new feature

**Rationale**: Don't mix refactoring with feature work. Show reviewers "here's the cleanup, and here's what it enables."

### Example: Adding Validation to Monolithic Handler

**Narrative**:
```
1. Extract validation logic from UserHandler into ValidationUtils
   - Isolate validation code
   - No functional changes
   - Tests remain green

2. Simplify ValidationUtils interface
   - Remove duplicate methods
   - Standardize return types
   - Update existing call sites

3. Add email validation to user registration
   - Use ValidationUtils.validateEmail()
   - Extend registration handler
   - Return 400 for invalid emails

4. Add tests for email validation
   - Test valid email formats
   - Test invalid email rejection
   - Test edge cases
```

**Why separated**:
- Commits 1-2 are pure refactoring (no behavior change)
- Commit 3 is pure feature (new behavior)
- Commit 4 is pure testing
- Reviewer can verify refactoring didn't break anything, then evaluate new feature

### Example: Database Performance Optimization

**Narrative**:
```
1. Extract query logic from OrderService into OrderRepository
2. Add database indexes for common queries
3. Implement query result caching
4. Add performance benchmarks
```

Clean refactoring before optimization makes cause-and-effect clear.

## Pattern 3: Bug Fix Narrative

**Use when**: Fixing a defect

**Structure**:
1. Add failing test that reproduces the bug
2. Fix the bug
3. Verify fix with updated test
4. (Optional) Add regression tests for edge cases
5. (Optional) Remove debug logging added during investigation

**Rationale**: Test-first shows the problem clearly. Fix is obvious. Tests verify solution.

### Example: Off-By-One Error

**Narrative**:
```
1. Add test showing pagination off-by-one error
   - Test expects 10 items per page
   - Currently returns 11 on last page
   - Test fails as expected

2. Fix pagination boundary condition
   - Change `<=` to `<` in page slice logic
   - Test now passes

3. Add edge case tests for pagination
   - Empty result set
   - Single page of results
   - Exact multiple of page size
```

**Why this works**:
- Bug is demonstrated with failing test
- Fix is focused on one thing
- Additional tests prevent regression

### Example: Null Pointer Exception

**Narrative**:
```
1. Add test reproducing NPE when email field is null
2. Add null check before calling toLowerCase() on email
3. Add tests for other nullable string fields
```

Simple, clear, reviewable.

## Pattern 4: Dependency Update

**Use when**: Upgrading libraries or dependencies

**Structure**:
1. Prepare code for compatibility (deprecate old API usage)
2. Update dependency version
3. Adapt code to new API
4. Update tests to match new behavior
5. Update documentation

**Rationale**: Separate preparation from the update itself. Make breaking changes visible.

### Example: Upgrading React

**Narrative**:
```
1. Replace deprecated componentWillMount with componentDidMount
   - Update all class components
   - No functional changes
   - Warnings eliminated

2. Upgrade React from 16.8 to 18.2
   - Update package.json
   - Update yarn.lock

3. Migrate to createRoot API
   - Replace ReactDOM.render()
   - Update index.js entry point

4. Fix test utilities for React 18
   - Use new render API in tests
   - Update enzyme configuration

5. Update component documentation with React 18 patterns
```

**Why separated**:
- Commit 1: Code ready for upgrade
- Commit 2: Just the version bump (easy to review/revert)
- Commits 3-4: Adaptations required by new version
- Commit 5: Documentation sync

## Pattern 5: Building Blocks Approach

**Use when**: Complex feature with multiple orthogonal aspects

**Categories of commits**:
- **refactor**: Code restructuring, no behavior change
- **feat**: New functionality
- **fix**: Bug corrections
- **test**: Test additions/updates
- **docs**: Documentation only
- **style**: Formatting, no logic change
- **chore**: Dependency updates, config changes
- **perf**: Performance improvements

**Rule**: Don't mix categories in a single commit.

### Example: Authentication System

**Building blocks narrative**:
```
refactor: extract auth logic from UserController into AuthService

feat: add JWT token generation to AuthService

feat: add token validation middleware

fix: prevent token reuse after logout with blocklist

test: add AuthService unit tests

test: add auth middleware integration tests

docs: add authentication API documentation

chore: add bcrypt dependency for password hashing

perf: cache blocklist lookups in Redis
```

**Why this works**:
- Each commit is single-purpose
- Can review/revert by type
- Clear separation of concerns

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Stream of Consciousness

**Bad narrative**:
```
abc1234 WIP
def5678 More WIP
ghi9012 Fix typo
jkl3456 Fix another typo  
mno7890 Actually works now
pqr4567 Add tests
stu8901 Fix test
vwx2345 Review feedback
```

**Why it's bad**:
- No clear story
- Reviewers can't understand incremental value
- Can't bisect effectively
- Typo fixes should be squashed

**Fix with rebase**:
```
pick abc1234 WIP
fixup def5678 More WIP
fixup ghi9012 Fix typo
fixup jkl3456 Fix another typo
fixup mno7890 Actually works now
pick pqr4567 Add tests
fixup stu8901 Fix test
drop vwx2345 Review feedback  # Incorporated into main commits

# Then reword abc1234 with proper message
```

**Result**:
```
abc1234 Add user authentication feature
pqr4567 Add authentication tests
```

### ❌ Anti-Pattern 2: Topic Jumping

**Bad narrative**:
```
abc1234 Add user login
def5678 Add admin dashboard
ghi9012 Finish user login
jkl3456 Add admin analytics
mno7890 Fix login bug
pqr4567 Add admin export
```

**Why it's bad**:
- Forces context switches
- Hard to review related changes together
- Difficult to understand dependencies

**Fix with reorder**:
```
# Reorder to group topics
pick abc1234 Add user login
pick ghi9012 Finish user login
pick mno7890 Fix login bug
pick def5678 Add admin dashboard
pick jkl3456 Add admin analytics
pick pqr4567 Add admin export

# Then combine login commits
pick abc1234 Add user login
squash ghi9012 Finish user login
fixup mno7890 Fix login bug
pick def5678 Add admin dashboard
...
```

**Result**:
```
abc1234 Add user login feature
def5678 Add admin dashboard
jkl3456 Add admin analytics
pqr4567 Add admin export
```

### ❌ Anti-Pattern 3: Mixed Concerns

**Bad commit**:
```
abc1234 Add user profile feature
  - frontend/UserProfile.jsx (UI)
  - backend/userController.js (API)
  - database/migrations/001_users.sql (schema)
  - tests/userProfile.test.js (tests)
  - docs/api.md (documentation)
  - style/formatting.css (unrelated styling)
  - config/webpack.config.js (build config update)
```

**Why it's bad**:
- Too much to digest at once
- Mixes feature work with unrelated changes
- Hard to review thoroughly
- Can't revert feature without reverting styling/config

**Fix with split**:
```
# Use git rebase -i with 'edit', then split

abc1234 Add user database schema
def5678 Add user profile backend API
ghi9012 Add user profile frontend component
jkl3456 Add user profile tests
mno7890 Add user profile API documentation
pqr4567 Update webpack config for production builds
stu8901 Update global styling
```

**Result**: Each concern is reviewable independently.

### ❌ Anti-Pattern 4: Fix-Up Hell

**Bad narrative**:
```
abc1234 Add authentication
def5678 Fix typo in auth.js
ghi9012 Fix bug in auth validation
jkl3456 Add missing import
mno7890 Fix another auth bug
pqr4567 Fix test
```

**Why it's bad**:
- Shows your debug process, not the solution
- Wastes reviewer time
- Makes bisect hit broken commits

**Fix with fixup**:
```
pick abc1234 Add authentication
fixup def5678 Fix typo in auth.js
fixup ghi9012 Fix bug in auth validation
fixup jkl3456 Add missing import
fixup mno7890 Fix another auth bug
fixup pqr4567 Fix test

# Then reword to explain complete feature
```

**Result**:
```
abc1234 Add JWT-based authentication
  - Login and signup endpoints
  - Token validation middleware
  - Password hashing with bcrypt
  - Comprehensive test coverage
```

### ❌ Anti-Pattern 5: Mega Commit

**Bad commit**:
```
abc1234 Implement entire user management system
  (342 files changed, 8453 insertions, 2341 deletions)
```

**Why it's bad**:
- Impossible to review effectively
- Mixes many distinct features
- Can't understand individual parts
- Bisect becomes useless

**Fix with split into narrative**:
```
1. Add user database schema
2. Add User model and repository
3. Add user registration endpoint
4. Add user login endpoint
5. Add password reset workflow
6. Add email verification
7. Add user profile endpoints
8. Add admin user management
9. Add user management tests
10. Add user management documentation
```

**Result**: Reviewable, logical progression.

## Creating Your Outline

Before coding (or during refinement), create an outline of your commit narrative:

### Step 1: List All Changes Needed

Brainstorm everything that needs to happen:
- Database schema changes
- Model updates
- API endpoints
- Frontend components
- Tests
- Documentation
- Configuration
- Dependencies

### Step 2: Group by Logical Unit

Cluster related changes:
- Schema + model (database layer)
- API endpoints (backend layer)
- Components (frontend layer)
- Tests (verification)
- Docs (communication)

### Step 3: Order from Foundation to Feature

Arrange so each commit builds on previous:
1. Database foundation
2. Models using database
3. API using models
4. Frontend using API
5. Tests verifying all layers
6. Documentation explaining system

### Step 4: Identify Dependencies

Note which commits must come before others:
- Schema before models
- Models before API
- API before frontend
- Features before tests

### Step 5: Plan Commit Sequence

Write outline in commit-like format:
```
1. Add user database schema
2. Add User model with repository pattern
3. Add POST /api/users endpoint
4. Add GET /api/users/:id endpoint
5. Add UserProfile React component
6. Add user management integration tests
7. Add API documentation for user endpoints
```

### Step 6: Include in PR Description

Add outline to pull request:
```markdown
## Commit Narrative

This PR implements user management with the following structure:

1. **Database layer**: User schema and migrations
2. **Model layer**: User model with repository pattern
3. **API layer**: RESTful user endpoints
4. **UI layer**: User profile and management components
5. **Testing**: Integration and unit tests
6. **Documentation**: API docs and component docs

Each commit is atomic and can be reviewed independently.
```

## Case Study 1: Image Modifier Script

Adapted from GitHub's blog post example.

### Original Stream of Consciousness

```
6a885eb WIP
692f477 Finish script
b3348a0 Add --invert and --grey
9512893 Add --output option
1689371 Add GitHub Actions CI .yml
6af4476 Add requirements.txt + other build fixes
9cd6412 Let users use --gray option spelling
```

### Problems Identified

1. **Topic jumping**: output option added after color options
2. **Mixed commits**: requirements.txt bundled with CI fixes
3. **Incomplete commits**: WIP split from "Finish script"
4. **Fragmented features**: --grey and --gray in separate commits
5. **No narrative arc**: Random order doesn't tell a story

### Outline Created

```
Narrative: Build image modifier script from foundation to features

1. Create working script with basic structure
2. Add output option (extends basic functionality)
3. Add color modification options
   a. Invert
   b. Greyscale (both spellings)
4. Add CI/CD infrastructure
```

### Refinement Steps

**Step 1**: Combine incomplete commits
```
pick 6a885eb WIP
squash 692f477 Finish script
fixup 6af4476 Add requirements.txt  # Move up, needs to be in initial commit
```

**Step 2**: Reorder to match narrative
```
pick 096ee13 Create initial image modifier script  # Combined WIP + Finish + requirements
pick 9512893 Add --output option  # Moved up
pick b3348a0 Add --invert and --grey  # Will split this
pick 9cd6412 Let users use --gray spelling  # Keep for now
pick 1689371 Add GitHub Actions CI  # Moved down
```

**Step 3**: Split combined color options
```
# Mark as edit
edit b3348a0 Add --invert and --grey

# When paused
git reset HEAD~
git add -p  # Select invert code
git commit -m "Add --invert option"
git add -p  # Select grey code
git commit -m "Add --grey option"
git rebase --continue
```

**Step 4**: Improve messages
```
# Use reword on each commit to add context
reword 096ee13 Create initial image modifier script
reword 381d3af Add --output option
# etc.
```

### Final Refined Narrative

```
096ee13 Create initial image modifier script
        
        Implements basic script that loads an image file and displays it.
        Uses argparse for CLI, PIL for image handling.
        Includes requirements.txt for dependencies.

381d3af Add --output option
        
        Allow users to save modified images instead of just displaying.
        Extends argparse with --output <path> argument.

3e5e5f6 Add --invert option
        
        Implement color inversion transformation.
        Inverts RGB values for artistic effect.

2d164e2 Add --grey option
        
        Implement greyscale conversion transformation.
        Converts images to grayscale using luminosity method.

851f2a0 Add --gray as alias for --grey
        
        Accept both 'grey' and 'gray' spellings in argparse definition.
        Common spelling variation should not cause user error.

3bf4ec4 Add GitHub Actions CI
        
        Set up linting workflow with flake8.
        Runs on push and pull request to ensure code quality.
```

### Benefits Achieved

- ✅ Clear narrative progression
- ✅ Each commit is atomic (builds and runs)
- ✅ Grouped related features (color options together)
- ✅ Infrastructure (CI) added at logical endpoint
- ✅ Messages explain what and why
- ✅ Reviewable commit-by-commit

## Case Study 2: API Rate Limiting

### Initial Messy Commits

```
abc1234 Start rate limiting
def5678 WIP redis
ghi9012 Fix redis connection
jkl3456 Add middleware
mno7890 Fix bug
pqr4567 Add tests
stu8901 Fix tests
vwx2345 Add docs
```

### Outline

```
1. Add Redis dependency and configuration
2. Implement rate limiting middleware
3. Apply middleware to API routes
4. Add rate limiting tests
5. Document rate limiting in API docs
```

### Refined Narrative

```
abc1234 Add Redis dependency for rate limiting
        
        Install redis client and add connection configuration.
        Redis will store request counts per client IP.

def5678 Implement rate limiting middleware
        
        Track requests per IP in Redis with sliding window.
        Return 429 Too Many Requests after limit exceeded.
        Default: 100 requests per hour.

ghi9012 Apply rate limiting to public API routes
        
        Add rate limiter middleware to all /api/* routes.
        Exclude /api/health and /api/status from limits.

jkl3456 Add rate limiting integration tests
        
        Verify limits enforced correctly.
        Test limit reset after window expires.
        Test excluded routes bypass limiter.

mno7890 Document rate limiting in API docs
        
        Add rate limit information to API documentation.
        Include headers returned (X-RateLimit-*).
        Explain how limits work and how to request increases.
```

## Tips for Good Narratives

### DO ✅

1. **Plan before coding**: Outline helps guide development
2. **Group related changes**: Keep building blocks together
3. **Order logically**: Foundation before features
4. **One thing per commit**: Single purpose, easy to explain
5. **Atomic commits**: Each commit works independently
6. **Clear messages**: Explain what and why
7. **Review your outline**: Does it tell a good story?

### DON'T ❌

1. **Mix building blocks**: Don't combine refactor + feature + fix
2. **Jump between topics**: Finish one thing before starting another
3. **Leave WIP commits**: Squash them into meaningful commits
4. **Create mega commits**: Split large changes into steps
5. **Forget the "why"**: Messages should explain reasoning
6. **Skip the outline**: Flying blind leads to messy history

## Practice Exercise

Take this messy history and outline how you'd refine it:

```
abc1234 Add user table
def5678 Add login page
ghi9012 Fix user table
jkl3456 Add login API
mno7890 Add signup page
pqr4567 Fix login API bug
stu8901 Add signup API
vwx2345 Add CSS
yza6789 Fix CSS
```

**Your outline should**:
- Group database/backend/frontend separately
- Order foundation-first
- Combine fixes with originals
- Create logical narrative

**Sample refined narrative**:
```
1. Add user database schema (combines abc1234 + ghi9012)
2. Add user authentication API endpoints (combines jkl3456 + pqr4567 + stu8901)
3. Add login page UI (def5678)
4. Add signup page UI (mno7890)
5. Add authentication styling (combines vwx2345 + yza6789)
```

---

**Remember**: A good commit narrative is like a good book—it has a beginning, middle, and end, and tells a coherent story that readers can follow and learn from.
