# Repository Guide for AI Agents

This repository contains a personal collection of Agent Skills.

## Layout

- Each skill lives in `skills/<skill-name>/`
- Every skill MUST have a `SKILL.md` at its root
- Optional: `scripts/`, `references/` inside the skill folder

## SKILL.md format

Every `SKILL.md` MUST start with YAML frontmatter:

```yaml
---
name: <skill-name>          # must match the folder name
description: <one or two sentences describing when to use this skill>
---
```

The `description` is the **only** signal the agent uses to decide
whether to load this skill, so:

- Keep it specific
- Include the trigger keywords or user intents
- Avoid marketing language

## Conventions

- Skill names use `kebab-case`
- One skill per folder — don't bundle unrelated capabilities
- Prefer short, focused skills over giant catch-all ones
