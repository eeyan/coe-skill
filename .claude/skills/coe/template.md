# COE: [Title]

| Field | Value |
|-------|-------|
| **Date** | YYYY-MM-DD |
| **Severity** | SEV-1 / SEV-2 / SEV-3 |
| **Author** | [Name] |
| **Status** | Draft / In Review / Final |
| **Duration** | [Start time] - [End time] (UTC) |

---

## Summary

<!-- 3-5 sentences: What service was affected, when, how it was discovered, how it was mitigated, scope of impact -->

## Customer Impact

<!-- Quantified impact with specific numbers -->

- **Users affected**: [number or percentage of total]
- **Duration of impact**: [minutes/hours]
- **Operations affected**: [what was degraded vs. unavailable]
- **Revenue impact**: [estimated amount, if applicable]
- **Downstream effects**: [other teams, services, SLAs affected]

## Timeline

<!-- Chronological, UTC. Explain any gaps >10 minutes. Each entry follows logically from the previous. -->

| Time (UTC) | Event |
|------------|-------|
| HH:MM | [Trigger event] |
| HH:MM | [Detection / alert / report] |
| HH:MM | [Investigation begins] |
| HH:MM | [Root cause identified] |
| HH:MM | [Mitigation applied] |
| HH:MM | [Resolution confirmed] |

## Metrics

<!-- Quantified measurements showing the impact and recovery -->

- **Baseline**: [normal values for key metrics]
- **During incident**: [values during the incident]
- **Detection method**: [how the problem was identified]
- **Monitoring gaps**: [any gaps that delayed detection]
- **Recovery confirmation**: [metrics used to confirm resolution]

---

## Incident Questions

<!-- Key questions that guided the investigation -->

1. [Question about detection]
2. [Question about prevention]
3. [Question about scope]
4. [Question about development process]
5. [Question about similar past incidents]

## Five Whys

<!-- Each level must dig deeper into systemic causes. NEVER terminate at human or AI error. -->

**Problem**: [The incident in one sentence]

1. **Why?** [First cause]
2. **Why?** [Deeper cause]
3. **Why?** [Deeper still]
4. **Why?** [Systemic/process gap]
5. **Why?** [Root infrastructure, tooling, or process failure]

**Root Cause(s)**:
- [RC-1: Systemic root cause]
- [RC-2: Additional root cause, if applicable]

---

## Action Items

| ID | Action | Type | Owner | Priority | Due Date | Category | Root Cause |
|----|--------|------|-------|----------|----------|----------|------------|
| AI-1 | [Specific action] | [CLAUDE.md update / New skill / Hook / Code / Process / Test / Memory / Settings] | [Name/Team] | P0-P3 | YYYY-MM-DD | Prevention / Detection / Response | RC-1 |
| AI-2 | [Specific action] | [Type] | [Name/Team] | P0-P3 | YYYY-MM-DD | [Category] | RC-2 |

## Recurrence

<!-- Has this type of failure happened before? -->

- **Prior incidents**: [Yes/No — if yes, reference prior COEs]
- **Prior action items**: [What was done before? Why didn't it prevent recurrence?]
- **What's different this time**: [Why this fix will stick]

## Narrative

<!-- Executive-readable narrative linking root causes to action items -->

### Executive Summary

[1-2 sentences for leadership]

### What Happened

[Clear, non-jargon description of the incident]

### What Went Well

- [Effective detection, response, communication, or tooling]

### What Went Wrong

- [Gaps in process, tooling, instructions, or review]

### Where We Got Lucky

- [Things that could have made it worse but didn't]

### Human-AI Collaboration

<!-- Reflection on the agentic development process -->

- [What worked in the AI-assisted workflow]
- [What instructions or context were missing]
- [How the development process will be improved]

### Root Cause to Action Item Mapping

<!-- Trace each root cause to its corrective actions -->

- **RC-1** → AI-1, AI-2: [Brief explanation of how the actions address the cause]
- **RC-2** → AI-3: [Brief explanation]

---

## Related Items

- **Prior COEs**: [Links to related COEs]
- **Tickets**: [JIRA, Linear, GitHub Issue links]
- **Runbooks**: [Links to relevant runbooks]
- **Dashboards**: [Monitoring dashboard links]
- **CLAUDE.md**: [Relevant sections updated as part of this COE]
