---
name: hello-world
description: A minimal example skill that greets the user. Use when the user says "hello", "hi", "你好", or explicitly asks for a hello-world demo of the Agent Skills format.
---

# Hello World Skill

The simplest possible skill — a friendly greeting demo that shows how the
Agent Skills format works.

## When to use

- The user types "hello", "hi", "hey", "你好" or any similar greeting
- The user explicitly asks for a hello-world / minimal example skill
- You want to verify that skills are correctly loaded by the agent

## Instructions

When this skill is activated, the agent should:

1. Greet the user warmly **in the user's language**
   (e.g. respond in 中文 if the user wrote 中文)
2. Briefly introduce yourself as an AI assistant powered by Agent Skills
3. Ask how you can help today

Keep the response short (1–3 sentences). Do **not** dump a long explanation
of what skills are unless the user asks.

## Example

User: hello
Assistant: Hi there! I'm your AI assistant — how can I help you today?

User: 你好
Assistant: 你好！我是你的 AI 助手,今天有什么可以帮你的吗?
