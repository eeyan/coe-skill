# Example COE

This is a fictional example demonstrating a well-written COE for an agentic coding workflow incident.

---

# COE: Payment API Rate Limiting Removed During Refactor

| Field | Value |
|-------|-------|
| **Date** | 2026-02-15 |
| **Severity** | SEV-2 |
| **Author** | Jamie Chen |
| **Status** | Final |
| **Duration** | 14:22 - 15:47 UTC (1h 25m) |

---

## Summary

On February 15, 2026, the payment processing API experienced a cascade failure after rate limiting middleware was inadvertently removed during an AI-assisted code refactor. The issue was discovered when downstream payment provider Stripe returned HTTP 429 errors at scale, causing checkout failures for customers. The incident was mitigated by reverting the deployment at 15:31 UTC and resolved once the revert propagated at 15:47 UTC.

## Customer Impact

- **Users affected**: 4,218 users (6.2% of active users during the window)
- **Duration of impact**: 1 hour 9 minutes (14:38 - 15:47 UTC)
- **Operations affected**: Checkout completely unavailable for affected users; cart and browsing unaffected
- **Revenue impact**: Estimated $23,400 in delayed orders (87% completed within 2 hours of resolution)
- **Downstream effects**: Stripe rate limit quota consumed; secondary payment provider failover not triggered

## Timeline

| Time (UTC) | Event |
|------------|-------|
| 11:30 | Developer initiates refactor of payment middleware using Claude Code with prompt: "Clean up the middleware chain, remove unused middleware, improve error handling" |
| 11:48 | Claude removes `rateLimiter.js` middleware from the chain, noting it appeared redundant with Stripe's built-in limits |
| 11:52 | Developer reviews diff, approves changes. PR created. |
| 12:15 | CI pipeline passes — no tests covered rate limiting behavior |
| 12:30 | PR merged after code review (reviewer focused on error handling changes, did not notice rate limiter removal) |
| 14:22 | Deployment to production completes |
| 14:38 | First Stripe 429 errors appear in logs |
| 14:45 | CloudWatch alarm triggers for elevated 5xx rate on payment endpoint |
| 14:47 | On-call engineer acknowledges alert, begins investigation |
| 14:52 | Engineer identifies spike in Stripe API calls correlating with deployment |
| 15:05 | Engineer reviews deployment diff, identifies rate limiter removal |
| 15:15 | Decision made to revert rather than hotfix |
| 15:31 | Revert deployment initiated |
| 15:47 | Revert fully propagated, error rates return to baseline |

## Metrics

- **Baseline**: Payment API: ~120 req/s, Stripe 429 rate: <0.01%
- **During incident**: Payment API: ~800 req/s to Stripe (no client-side throttling), Stripe 429 rate: 34%
- **Detection method**: CloudWatch alarm on 5xx rate threshold (>5% for 3 minutes)
- **Monitoring gaps**: No alarm specifically for Stripe 429 responses; no alarm for request rate to Stripe exceeding expected volume
- **Recovery confirmation**: Stripe 429 rate returned to <0.01%, checkout success rate returned to 99.7%

---

## Incident Questions

1. Why didn't the AI assistant know that rate limiting middleware was critical?
2. Why weren't there tests for rate limiting behavior?
3. Why didn't code review catch the removal of a critical middleware?
4. Why did the prompt instruct removal of "unused" middleware without defining what counts as unused?
5. Has rate limiting been accidentally removed or bypassed before?

## Five Whys

**Problem**: Payment checkout failed for 4,218 users because Stripe rate limits were exceeded after our client-side rate limiter was removed.

1. **Why were Stripe rate limits exceeded?**
   Our client-side rate limiting middleware was removed, so requests hit Stripe at full volume without throttling.

2. **Why was the rate limiting middleware removed?**
   During an AI-assisted refactor, Claude identified it as potentially redundant and removed it. The developer approved the change in code review.

3. **Why did the AI consider the rate limiter redundant?**
   CLAUDE.md had no documentation about critical middleware components or architectural constraints. The rate limiter had no code comments explaining its purpose. The AI had no context that client-side rate limiting was required regardless of provider limits.

4. **Why were there no tests to catch the removal?**
   Rate limiting was implemented as middleware but had no integration tests verifying its presence or behavior. The test suite focused on business logic, not infrastructure middleware.

5. **Why was there no deployment safeguard for removing middleware?**
   No automated check verifies that critical middleware components remain in the chain after changes. No hook or CI step validates the middleware stack against a known-good configuration.

**Root Causes**:
- **RC-1**: CLAUDE.md lacked documentation of critical infrastructure components and architectural constraints, so the AI assistant had no way to know the rate limiter was essential
- **RC-2**: No tests existed for rate limiting behavior, allowing silent removal
- **RC-3**: No automated check validates the middleware stack integrity before deployment

---

## Action Items

| ID | Action | Type | Owner | Priority | Due Date | Category | Root Cause |
|----|--------|------|-------|----------|----------|----------|------------|
| AI-1 | Add "Critical Middleware" section to CLAUDE.md listing components that must never be removed without explicit discussion (rate limiter, auth, CORS, request logging) | CLAUDE.md update | Jamie Chen | P0 | 2026-02-17 | Prevention | RC-1 |
| AI-2 | Create `/middleware-check` skill that validates the middleware chain against CLAUDE.md's critical list before PR creation | New skill | Platform team | P1 | 2026-03-01 | Prevention | RC-3 |
| AI-3 | Add integration tests for rate limiting: verify middleware is present, verify requests are throttled at configured limits | Test addition | Alex Rivera | P1 | 2026-02-28 | Detection | RC-2 |
| AI-4 | Add pre-commit hook that warns when files in `middleware/` directory are deleted or when middleware registrations are removed from the chain | Hook configuration | Jamie Chen | P1 | 2026-02-22 | Prevention | RC-3 |
| AI-5 | Save memory: "Payment API rate limiting middleware (rateLimiter.js) is critical infrastructure — must never be removed. Client-side rate limiting is required regardless of provider-side limits." | New memory | Jamie Chen | P0 | 2026-02-16 | Prevention | RC-1 |
| AI-6 | Add Stripe 429 response rate alarm to CloudWatch (threshold: >1% for 2 minutes) | Code change | SRE team | P1 | 2026-02-22 | Detection | RC-2 |

## Recurrence

- **Prior incidents**: No prior incidents involving rate limiter removal
- **Prior action items**: N/A
- **What's different this time**: This is the first incident of this type, driven by the introduction of AI-assisted refactoring without sufficient guardrails. Action items address the new risk category.

## Narrative

### Executive Summary

A routine AI-assisted code refactor removed critical rate limiting middleware from the payment API, causing 4,218 customers to experience checkout failures for 69 minutes. The incident reveals gaps in how we communicate architectural constraints to AI coding assistants.

### What Happened

A developer used Claude Code to refactor the payment middleware chain, asking it to "clean up, remove unused middleware, and improve error handling." Claude identified the rate limiting middleware as potentially redundant — since Stripe has its own rate limits — and removed it from the chain. The change passed CI (no tests covered rate limiting), was approved in code review (the reviewer focused on the error handling improvements), and was deployed to production.

Without client-side rate limiting, our payment API sent requests to Stripe at full volume. Within 16 minutes of deployment, Stripe's rate limits were hit and 34% of payment requests started failing with 429 errors.

### What Went Well

- CloudWatch alarm detected the elevated 5xx rate within 7 minutes of first errors
- On-call engineer quickly correlated the error spike with the deployment
- Decision to revert (rather than hotfix) was correct — full resolution in 16 minutes after decision
- 87% of affected orders were completed within 2 hours of resolution

### What Went Wrong

- CLAUDE.md had no information about critical middleware components, leaving the AI assistant without context to make safe decisions during refactoring
- The rate limiter had no code comments explaining why client-side rate limiting is needed in addition to Stripe's limits
- No integration tests existed for rate limiting behavior
- Code review did not catch the removal — the diff was large and the reviewer focused on the error handling changes
- No automated check validates that critical middleware remains in the chain

### Where We Got Lucky

- The incident occurred during moderate traffic (weekday afternoon) — during a peak period, customer impact could have been 3-5x higher
- Stripe's rate limit response was graceful (429 with retry-after header) rather than a hard block, which would have caused longer recovery
- No payment data was lost or corrupted; failed transactions were cleanly rejected

### Human-AI Collaboration

This incident highlights a gap in how we provide architectural context to AI coding assistants. Claude made a reasonable inference — that client-side rate limiting is redundant when the provider has its own limits — but lacked the context that our rate limiter serves a different purpose (protecting our Stripe API quota, not just protecting Stripe).

The core issue is not that "the AI got it wrong" but that our project instructions didn't communicate which components are architecturally critical. Without this context, any assistant (human or AI) could make the same mistake.

Action items AI-1 (CLAUDE.md update) and AI-5 (memory) directly address this by making architectural constraints explicit. AI-2 (middleware-check skill) and AI-4 (pre-commit hook) add automated guardrails so this class of error is caught before deployment regardless of who or what makes the change.

### Root Cause to Action Item Mapping

- **RC-1** (Missing architectural context in CLAUDE.md) → AI-1 (document critical middleware), AI-5 (save memory for Claude)
- **RC-2** (No tests for rate limiting) → AI-3 (add integration tests), AI-6 (add Stripe 429 alarm)
- **RC-3** (No middleware stack validation) → AI-2 (middleware-check skill), AI-4 (pre-commit hook)

---

## Related Items

- **Tickets**: PLATFORM-1847 (CLAUDE.md update), PLATFORM-1848 (middleware-check skill), PAY-892 (rate limit tests)
- **Dashboards**: CloudWatch Payment API dashboard, Stripe API usage dashboard
- **CLAUDE.md**: New "Critical Middleware" section added as AI-1
