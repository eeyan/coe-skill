# COE Anti-Patterns

Reference guide showing common mistakes in COE documents and how to fix them. Use this during the quality audit to identify issues.

---

## 1. Shallow Five Whys

**Bad:**
> 1. Why did the API break? → The engineer deployed a bad config.
>
> Root cause: Engineer error.

**Good:**
> 1. Why did the API break? → A config change set the connection pool to 0.
> 2. Why was an invalid value accepted? → The config schema has no validation for minimum pool size.
> 3. Why is there no config validation? → Config files are loaded as raw YAML with no schema enforcement.
> 4. Why was this not caught in CI? → CI runs unit tests but does not validate config against a schema.
> 5. Why is config validation not part of CI? → No config validation tooling exists in the project.
>
> Root cause: No config schema validation in the deployment pipeline.

**Rule:** Keep asking "why" until you reach a systemic gap. If you can fix it with a process, tool, or instruction change rather than telling someone to "be more careful," you're at the right depth.

---

## 2. Blaming Humans or AI

**Bad:**
> Root cause: The developer didn't review the AI's changes carefully enough.

> Root cause: Claude generated incorrect code.

**Good:**
> Root cause: CLAUDE.md did not document that the authentication middleware is load-bearing infrastructure. Without this context, neither AI nor human reviewers could distinguish it from unused code. No automated check validates the middleware chain.

**Rule:** "Human error" and "AI error" are symptoms, not root causes. Ask: Why did the system allow this? What guardrail, instruction, or check was missing?

---

## 3. Vague Action Items

**Bad:**
> - Be more careful with deployments
> - Improve code review process
> - Add better monitoring

**Good:**
> | ID | Action | Type | Owner | Priority | Due | Category | Root Cause |
> |----|--------|------|-------|----------|-----|----------|------------|
> | AI-1 | Add deployment config schema validation to CI pipeline using JSON Schema | Code change | Platform team | P1 | 2026-03-15 | Prevention | RC-1 |
> | AI-2 | Add "Critical Infrastructure" section to CLAUDE.md listing components that require explicit approval before modification | CLAUDE.md update | Tech Lead | P0 | 2026-03-02 | Prevention | RC-2 |
> | AI-3 | Create pre-commit hook that blocks deletion of files in `infrastructure/` without a `--force-infra` flag | Hook configuration | DevOps | P1 | 2026-03-10 | Prevention | RC-2 |

**Rule:** Every action item must answer: What exactly will change? Who will do it? By when? How does it connect to a root cause?

---

## 4. Missing Impact Quantification

**Bad:**
> Several customers experienced issues with the checkout flow for some time.

**Good:**
> 4,218 users (6.2% of active users) experienced checkout failures for 69 minutes (14:38-15:47 UTC). Estimated revenue impact: $23,400 in delayed orders, of which 87% were recovered within 2 hours.

**Rule:** Use specific numbers: count of affected users, duration in minutes, percentage of total, revenue impact. If exact numbers aren't available, provide ranges with the methodology used to estimate.

---

## 5. Timeline Gaps

**Bad:**
> | Time | Event |
> |------|-------|
> | 02:00 | Alert fired for high error rate |
> | 05:30 | Fix deployed to production |

3.5 hours unaccounted for.

**Good:**
> | Time | Event |
> |------|-------|
> | 02:00 | PagerDuty alert fires for error rate >5% on payment API |
> | 02:08 | On-call (Jamie) acknowledges, begins investigating CloudWatch |
> | 02:15 | Identifies correlation with 01:45 deployment, begins reviewing diff |
> | 02:30 | Finds config change in connection pool settings, suspects root cause |
> | 02:45 | Reproduces in staging by applying same config — confirms root cause |
> | 03:00 | Begins writing fix, tests locally |
> | 03:30 | Fix PR created, expedited review by Sarah |
> | 03:45 | CI passes, PR merged |
> | 04:00 | Deployment to production initiated |
> | 04:15 | Deployment complete, monitoring error rates |
> | 04:30 | Error rates return to baseline, incident resolved |

**Rule:** Every gap >10 minutes must be explained. The timeline should read like a story — each entry follows logically from the previous one.

---

## 6. Orphaned Action Items

**Bad:**
Action items that don't trace back to any root cause from the Five Whys analysis, or root causes with no corresponding action items.

> Root causes: RC-1 (no config validation), RC-2 (missing tests)
>
> Action items:
> - AI-1: Add config validation → RC-1
> - AI-2: Refactor the logging system → ???
> - *(RC-2 has no action item)*

**Good:**
Every root cause has at least one action item. Every action item references a root cause.

> Root causes: RC-1 (no config validation), RC-2 (missing tests)
>
> Action items:
> - AI-1: Add config schema validation to CI → RC-1
> - AI-2: Add integration tests for connection pool configuration → RC-2
> - AI-3: Add config change detection alarm to CloudWatch → RC-1

**Rule:** The action items table and root causes should have full bidirectional traceability. No orphans in either direction.

---

## 7. Missing Agentic Action Items

**Bad:**
The incident was caused in part by the AI development workflow, but all action items are traditional code fixes:

> The AI assistant removed critical middleware during a refactor because it lacked context.
>
> Action items:
> - AI-1: Restore the middleware (Code change)
> - AI-2: Add tests for the middleware (Test addition)

The immediate fix is there, but nothing prevents the same class of error from recurring in future AI-assisted work.

**Good:**
Action items include improvements to the agentic workflow:

> Action items:
> - AI-1: Restore the middleware (Code change)
> - AI-2: Add tests for the middleware (Test addition)
> - AI-3: Add "Critical Infrastructure" section to CLAUDE.md documenting components that must not be modified without explicit approval (CLAUDE.md update)
> - AI-4: Create pre-commit hook that warns when infrastructure middleware files are modified (Hook configuration)
> - AI-5: Save memory noting that this middleware is architecturally critical (New memory)
> - AI-6: Create `/infra-check` skill that validates infrastructure components before PR creation (New skill)

**Rule:** If the development process (including AI-assisted workflows) contributed to the incident, at least one action item should improve the agentic workflow: CLAUDE.md updates, new skills, new memories, hook configurations, or settings changes. Fixing only the code without fixing the process that produced the bad code means you'll be writing this COE again.
