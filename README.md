# COE Skill for Claude Code

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that guides you through creating **Correction of Error (COE)** documents — structured, blameless post-incident analysis adapted from Amazon's operational excellence process, reframed for **agentic coding workflows**.

## What is a COE?

A Correction of Error is a structured process for analyzing incidents and preventing recurrence. Unlike traditional postmortems, COEs are:

- **Blameless** — root causes must be systemic, never individual blame (human or AI)
- **Action-oriented** — every root cause gets a concrete, owned, dated action item
- **Traceable** — action items map directly to root causes via Five Whys analysis
- **Process-aware** — analyzes the development workflow, not just the code

## Why agentic?

When AI coding assistants are part of your development process, the "system" that produces errors extends beyond code. This skill treats CLAUDE.md files, skills, memories, hooks, and human-AI collaboration patterns as part of the system under analysis.

Action items aren't just code fixes — they include:

| Type | Example |
|------|---------|
| **CLAUDE.md update** | Document critical infrastructure components that must not be removed |
| **New skill** | Create a `/middleware-check` skill to validate the middleware chain |
| **New memory** | Save context about architectural constraints across sessions |
| **Hook configuration** | Add pre-commit hook that warns when infrastructure files are modified |
| **Settings change** | Update tool permissions or model configuration |
| **Code change** | Traditional fixes, tests, linting rules |
| **Process change** | Review workflows, deployment gates, testing requirements |

## Installation

### Option 1: Clone into your project (recommended)

Copy the skill directory into any project:

```bash
# From your project root
mkdir -p .claude/skills
cp -r /path/to/coe-skill/.claude/skills/coe .claude/skills/coe
```

### Option 2: Install as a personal skill (available in all projects)

```bash
mkdir -p ~/.claude/skills
cp -r /path/to/coe-skill/.claude/skills/coe ~/.claude/skills/coe
```

### Option 3: Clone and symlink

```bash
git clone https://github.com/iananderson/coe-skill.git ~/coe-skill

# Per-project
mkdir -p .claude/skills
ln -s ~/coe-skill/.claude/skills/coe .claude/skills/coe

# Or personal (all projects)
mkdir -p ~/.claude/skills
ln -s ~/coe-skill/.claude/skills/coe ~/.claude/skills/coe
```

## Usage

In Claude Code, run:

```
/coe
```

Or with context:

```
/coe The payment API went down after yesterday's deployment
/coe path/to/incident-notes.md
```

The skill walks you through five phases interactively:

1. **Context Gathering** — Describe the incident and development process context
2. **Supporting Information** — Summary, customer impact (quantified), timeline, metrics
3. **Analysis** — Development process questions and Five Whys root cause analysis
4. **Corrections** — Action items (with agentic types), narrative, recurrence check
5. **Generation & Audit** — Produces a `COE-{date}-{slug}.md` file and runs a quality scorecard

## Five Whys Rules

The skill enforces blameless root cause analysis:

- Root causes must terminate at **infrastructure, process, or tooling failures**
- "The engineer made a mistake" is **not** a valid root cause — dig deeper into why the system allowed the mistake
- "Claude generated bad code" is **not** a valid root cause — ask what instructions, guardrails, or checks were missing
- Keep asking "why" until you reach something fixable with a process, tool, or instruction change

## Quality Audit

After generating the COE document, the skill runs an automated quality check:

| Check | What it verifies |
|-------|-----------------|
| Five Whys depth | At least 3 levels; reaches systemic cause |
| Blamelessness | No root cause terminates at human or AI error |
| Impact quantified | Specific numbers for users, duration, revenue |
| Timeline complete | No unexplained gaps >10 minutes |
| Action items complete | Each has owner, due date, priority, root cause ref |
| Traceability | Every root cause has action items; no orphans |
| Recurrence | Prior incidents acknowledged |
| Narrative quality | Executive-readable; covers went well/wrong/lucky |
| Agentic improvements | Dev process action items present when relevant |

## File Structure

```
.claude/skills/coe/
  SKILL.md            # Main skill — interactive walkthrough
  template.md         # Empty COE template with section guidance
  examples.md         # Complete example COE (fictional agentic scenario)
  anti-patterns.md    # Bad vs. good examples for 7 common mistakes
```

## Compatibility

This skill follows the [Agent Skills](https://agentskills.io) open standard and works with:

- **Claude Code** (CLI, desktop app, web app, IDE extensions)
- **Kiro**
- **Codex**
- Any tool supporting the Agent Skills standard

Claude Code-specific frontmatter fields (`allowed-tools`, etc.) are safely ignored by other tools.

## License

MIT
