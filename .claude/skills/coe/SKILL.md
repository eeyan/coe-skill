---
name: coe
description: >
  Guide creation of Correction of Error (COE) documents for agentic coding workflows.
  Interactive walkthrough of impact, timeline, five whys, and action items.
  Action items include CLAUDE.md updates, new skills, memories, hooks, and code fixes.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebFetch, WebSearch
argument-hint: "brief description of the incident, or path to existing notes"
---

# Correction of Error (COE)

You are guiding the user through creating a Correction of Error document. A COE is a structured, blameless post-incident analysis adapted from Amazon's operational excellence process, framed for agentic coding workflows.

The "system" under analysis includes not just code, but the entire human-AI development process: project instructions (CLAUDE.md), skills, memories, hooks, settings, review workflows, and collaboration patterns.

Read the following supporting files before starting:
- [template.md](template.md) for the document structure
- [anti-patterns.md](anti-patterns.md) for quality guardrails
- [examples.md](examples.md) for a reference example

---

## Phase 1: Context Gathering

1. If `$ARGUMENTS` is provided:
   - If it looks like a file path, read that file for incident context
   - Otherwise, treat it as a brief incident description

2. Search the workspace for related context:
   - Look for existing COE documents, incident notes, or postmortems
   - Check git history for recent changes related to the incident
   - Read CLAUDE.md if it exists to understand current project instructions

3. Ask the user the following questions (adapt based on what you already know):
   - What happened? Describe the incident in a few sentences.
   - When did it start and when was it resolved?
   - How was the issue discovered? (Alert, user report, code review, testing, etc.)
   - What was the development process context?
     - Was an AI coding assistant involved? Which one?
     - Were there CLAUDE.md / project instructions in place?
     - Were relevant skills, hooks, or memories configured?
     - What was the review and testing process?

Wait for the user's answers before proceeding.

---

## Phase 2: Supporting Information

Work through each section, asking targeted follow-up questions.

### 2a. Summary

Draft a 3-5 sentence summary covering:
- What service/system was affected
- When it started and ended (use UTC or note the timezone)
- How it was discovered
- How it was mitigated
- Brief scope of impact

Present the draft and ask the user to confirm or correct it.

### 2b. Customer Impact

Ask for specific, quantifiable impact. Push back on vague answers:
- How many customers/users were affected?
- What operations were degraded vs. completely unavailable?
- What was the duration of customer-facing impact?
- Was there revenue impact? If so, estimated amount.
- Were there downstream effects (other teams, services, SLAs)?

If the user gives vague answers like "some customers" or "a few hours," ask them to quantify with specific numbers or ranges.

### 2c. Timeline

Build the timeline chronologically. For each entry ask:
- What time (UTC)?
- What happened?
- Who took what action?
- What was the result?

Rules for the timeline:
- Use consistent timezone notation (UTC preferred, or specify e.g. "PT")
- Each entry should follow logically from the previous one
- Flag any gaps longer than 10 minutes and ask the user to explain what happened during that gap
- Include both automated events (alerts, deployments) and human actions

### 2d. Metrics

Ask about:
- What dashboards or monitoring showed the problem?
- What were the normal baseline values vs. incident values?
- How was the scope of impact determined?
- Were there monitoring gaps that delayed detection?
- What metrics will be used to confirm the fix is working?

---

## Phase 3: Analysis

### 3a. Development Process Questions

Ask targeted questions about the agentic workflow (skip any that are clearly not relevant):
- Did CLAUDE.md have sufficient guidance to prevent this type of error?
- Were there skills that should have caught this? (e.g., a pre-deploy check, a validation skill)
- Did the AI assistant have the right context or memories for this work?
- Were hooks configured to validate this type of change? (e.g., pre-commit, post-edit)
- Was the prompt or instruction to the AI clear and specific enough?
- Did the code review process catch AI-generated issues? If not, why?
- Were tests adequate for the changes made?

### 3b. Five Whys

This is the most critical section. Walk through it iteratively:

1. Start with: "Why did [the incident] happen?"
2. For each answer, ask: "Why did [that] happen?"
3. Continue until you reach an infrastructure, process, or tooling failure
4. Aim for at least 5 levels, but depth matters more than count

**HARD RULE — Blameless Termination:**
The Five Whys must NEVER terminate at:
- Human error ("the engineer made a mistake")
- AI error ("Claude generated bad code")
- Individual blame of any kind

If the analysis reaches human or AI error, push back explicitly:

> "This root cause points to an individual action rather than a systemic gap. Let's go deeper: Why did the system allow this mistake to happen? What guardrail, instruction, review step, or automated check was missing that could have caught this?"

Keep digging until you reach one of these systemic categories:
- Missing or insufficient project instructions (CLAUDE.md)
- Missing automated checks (hooks, CI, linting)
- Missing skills or workflows
- Insufficient testing or test coverage
- Inadequate monitoring or alerting
- Missing documentation or runbooks
- Process gaps (review, deployment, rollback)
- Tooling limitations or misconfigurations
- Architecture or design issues

Present each "why" level to the user for confirmation before proceeding deeper.

---

## Phase 4: Corrections

### 4a. Action Items

For each root cause identified in the Five Whys, work with the user to define a concrete action item. Each action item must have:

| Field | Description |
|-------|-------------|
| **ID** | Sequential (AI-1, AI-2, ...) |
| **Action** | Specific, concrete change to make |
| **Type** | One of: CLAUDE.md update, New skill, New memory, Hook configuration, Settings change, Code change, Process change, Test addition |
| **Owner** | Person or team responsible |
| **Priority** | P0 (do now), P1 (this sprint), P2 (this quarter), P3 (backlog) |
| **Due Date** | Target completion date |
| **Category** | Prevention, Detection, or Response |
| **Root Cause** | Which Five Whys root cause this addresses (e.g., "Why #3") |

Guide the user to consider agentic action items alongside traditional ones:
- **CLAUDE.md updates**: Add rules, constraints, or guidance that would have prevented this
- **New skills**: Create skills that automate checks, enforce patterns, or validate changes
- **New memories**: Save context that Claude should remember across sessions to avoid this class of error
- **Hook configurations**: Add pre-commit, post-edit, or notification hooks that catch issues automatically
- **Settings changes**: Update permissions, tool access, or model configuration
- **Code changes**: Traditional fixes, refactoring, dependency updates
- **Process changes**: Review requirements, deployment gates, testing workflows, rollback procedures
- **Test additions**: New tests that would have caught this specific failure

If the development process contributed to the error and there are no agentic action items (CLAUDE.md, skills, memories, hooks), explicitly ask: "The development process was involved in this incident. Should we add action items to improve the AI workflow — like updating CLAUDE.md, adding a hook, or creating a skill?"

### 4b. Recurrence Check

Ask the user:
- Has this type of failure happened before?
- If yes, were there prior action items? Why didn't they prevent recurrence?
- If this is a repeat failure, what's different about this fix?

### 4c. Narrative

Draft a narrative that:
- Opens with a 1-2 sentence executive summary
- Describes what happened in clear, non-jargon language
- Covers three sections:
  - **What went well**: Detection speed, response effectiveness, communication, tooling that helped
  - **What went wrong**: Gaps in process, tooling, instructions, or review
  - **Where we got lucky**: Things that could have made it worse but didn't
- Links each root cause to its corresponding action items by ID
- Reflects on the human-AI collaboration: what worked, what the AI missed, what instructions were lacking
- Addresses recurrence if applicable
- Is written for a broad audience (not just engineering)

Present the draft narrative and ask the user to review and refine.

### 4d. Related Items

Ask for references to:
- Prior COEs for similar issues
- Tickets or issues (JIRA, Linear, GitHub Issues)
- Runbooks or playbooks
- Monitoring dashboards
- Relevant CLAUDE.md sections or skills

---

## Phase 5: Generation and Audit

### 5a. Generate the Document

1. Determine output location:
   - If a `coes/` directory exists, write there
   - Otherwise, create a `coes/` directory
2. Generate the filename: `COE-{YYYY-MM-DD}-{slug}.md` where slug is a short kebab-case description
3. Write the complete COE document using the structure from template.md
4. Include all sections with the content gathered through the walkthrough

### 5b. Quality Audit

After generating the document, run a quality audit. Check each dimension:

| Check | Criteria |
|-------|----------|
| **Five Whys depth** | At least 3 levels deep; reaches systemic cause |
| **Blamelessness** | No root cause terminates at human or AI error |
| **Customer impact quantified** | Specific numbers for affected users, duration, revenue |
| **Timeline complete** | No unexplained gaps >10 minutes |
| **Action items complete** | Each has owner, due date, priority, and root cause reference |
| **Action items traceable** | Every root cause has at least one action item |
| **No orphaned action items** | Every action item traces to a root cause |
| **Recurrence addressed** | Prior incidents acknowledged; differences in fix noted |
| **Narrative quality** | Executive-readable; covers went well/wrong/lucky |
| **Metrics included** | Baselines, incident values, and monitoring noted |
| **Agentic improvements** | If dev process was involved, action items improve the AI workflow |

Present the audit results as a scorecard. For any failing checks, provide specific suggestions for improvement and offer to iterate on those sections.

### 5c. Offer Next Steps

After the audit, suggest:
- Implementing action items that can be done immediately (e.g., CLAUDE.md updates, new hooks)
- Scheduling the COE for team review
- Setting up tracking for action items with due dates
