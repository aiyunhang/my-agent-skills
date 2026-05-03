---
name: hello-world
description: A minimal example skill that greets the user by their system username. Use when the user says "hello", "hi", "hey", "你好", or explicitly asks for a hello-world demo of the Agent Skills format.
---

# Hello World Skill

The simplest possible skill — a friendly greeting demo that shows how the
Agent Skills format works **and** how a skill can run a shell command and
use its output in the response.

## When to use

- The user types "hello", "hi", "hey", "你好" or any similar greeting
- The user explicitly asks for a hello-world / minimal example skill
- You want to verify that skills are correctly loaded by the agent

## Instructions

When this skill is activated, the agent **MUST** follow these steps in order:

1. **Run the shell command `whoami`** to detect the current OS username.
   - You can either invoke `whoami` directly, or run the bundled helper
     `bash scripts/whoami.sh` from this skill's directory.
   - Capture stdout (trimmed) into a variable conceptually called
     `$USER_NAME`.
2. Greet the user warmly **in the user's language**, embedding the
   captured username in the greeting (e.g. "Hello, **alice**!").
3. Briefly introduce yourself as an AI assistant powered by Agent Skills.
4. Ask how you can help today.

Keep the final response short (1–3 sentences). Do **not** dump a long
explanation of what skills are unless the user asks.

### Error handling

- If `whoami` fails (non-zero exit, empty output, or the shell tool is
  unavailable), fall back to the literal greeting `"Hello, friend!"` and
  continue with steps 3–4. Do **not** ask the user for their name.

## Example

```text
User: hello
[agent runs: whoami  →  "alice"]
Assistant: Hi there, alice! I'm your AI assistant — how can I help you today?
```

```text
User: 你好
[agent runs: whoami  →  "kunkun"]
Assistant: 你好,kunkun!我是你的 AI 助手,今天有什么可以帮你的吗?
```

```text
User: hi
[agent runs: whoami  →  ERROR]
Assistant: Hello, friend! I'm your AI assistant — how can I help you today?
```

## Notes

- `whoami` is **not** executed when this skill is installed (`git clone`
  / `npx skills add`). It is only executed when the skill is **activated**
  by a matching user message, because skills are passive prompts that the
  agent reads on demand.
