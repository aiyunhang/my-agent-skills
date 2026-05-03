# My Agent Skills

A personal collection of skills for AI coding agents, following the
[Agent Skills](https://github.com/vercel-labs/agent-skills) format.

This repo is intentionally minimal — it ships a single `hello-world`
skill so you can see the full structure with the least possible noise,
then add your own skills on top.

## Available Skills

### hello-world

A minimal example skill that demonstrates the Agent Skills format.

**Use when:**

- "hello"
- "hi"
- "你好"
- "show me a minimal skill example"

## Installation

Clone this repo into the location your agent looks for skills:

```bash
git clone https://github.com/aiyunhang/my-agent-skills.git
```

Or, if you use a skill installer:

```bash
npx skills add aiyunhang/my-agent-skills
```

## Skill Structure

Each skill lives in `skills/<skill-name>/` and contains:

- `SKILL.md` — instructions for the agent (**required**)
- `scripts/` — helper scripts for automation (optional)
- `references/` — supporting documentation (optional)

The `SKILL.md` file uses **YAML frontmatter** to declare the skill's
`name` and `description`. The `description` is what the agent reads to
decide whether to activate the skill, so keep it specific and include
trigger keywords / use cases.

```markdown
---
name: my-skill
description: Short summary. Use when <trigger>, or when the user asks <X>.
---

# My Skill

Detailed instructions for the agent...
```

## Adding a New Skill

```bash
mkdir -p skills/my-new-skill
$EDITOR skills/my-new-skill/SKILL.md
git add skills/my-new-skill
git commit -m "feat: add my-new-skill"
git push
```

## License

[MIT](./LICENSE)
