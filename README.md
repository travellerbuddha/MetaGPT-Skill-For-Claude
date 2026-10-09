<div align="center">

# MetaGPT Skill for Claude

**A software company in a slash command.**

One idea in → PRD, architecture, task plan, working code and passing tests out.
Powered by Claude Code subagents. No API key. No extra bill.

![Claude Code](https://img.shields.io/badge/Claude_Code-skill-D97757?style=flat-square)
![MetaGPT SOP](https://img.shields.io/badge/MetaGPT-SOP-111111?style=flat-square)
![API key](https://img.shields.io/badge/API_key-not_needed-2ea44f?style=flat-square)
![Ponytail](https://img.shields.io/badge/ponytail-enabled-111111?style=flat-square)

</div>

---

```text
/metagpt "A CLI todo app that saves to JSON (Python)"
```

```text
  Product Manager   ──▶  docs/<project>/01-prd.md            goals · user stories · competitors · P0/P1/P2
        │
  Architect         ──▶  docs/<project>/02-system-design.md  file list · class diagram · call flow
        │
  Project Manager   ──▶  docs/<project>/03-tasks.md          packages · dependency-ordered tasks
        │
  Engineer          ──▶  <project>/                          complete code, no TODOs
        │
  QA Engineer       ──▶  <project>/tests/                    write, run, bounce bugs back (≤ 3 rounds)
```

That example run produced a 7-file Python package and **97 passing tests**.

## Why

[MetaGPT](https://github.com/FoundationAgents/MetaGPT) showed that `Code = SOP(Team)`: give each role one standard document, and let the next role work only from the documents before it. The idea is good, but the framework needs an LLM API key and a Python stack.

This repo keeps the SOP and drops the stack. Each MetaGPT role is a Claude Code subagent. Their document fields mirror MetaGPT's own templates. Claude Code runs them in order inside the session, on your subscription.

## Quick start

1. Open this repo in [Claude Code](https://claude.ai/code): terminal, desktop or web.
2. Type:

   ```text
   /metagpt "your idea here"
   ```

Write the idea in any language and the documents come back in that language.

| Flag | What it does |
|---|---|
| `--no-implement` | Stop after the plan: PRD, design and tasks only |
| `--no-tests` | Skip the QA stage |
| `--inc <project>` | Add a requirement to an existing project; every role writes "Refined" sections |

## What's inside

```text
.claude/
├── skills/metagpt/SKILL.md      # the orchestrator: the SOP, step by step
├── agents/metagpt-*.md          # 5 roles: PM, Architect, Project Manager, Engineer, QA
└── settings.json                # enables the ponytail plugin
tools/metagpt/                   # optional: real MetaGPT on the Claude API
```

### Ponytail, on by default

[Ponytail](https://github.com/DietrichGebert/ponytail) makes the agents write the least code that fully solves the task. It never cuts validation, error handling or security. Say `normal mode` to turn it off for a session.

### Optional: real MetaGPT on the Claude API

If you have an `ANTHROPIC_API_KEY` and want the original Python framework, `tools/metagpt/setup.sh` installs a pinned MetaGPT. The patches make it work with current Claude models:

- adaptive thinking and effort instead of `budget_tokens`, which Claude 4.6+ rejects
- parsing for responses with more than one block
- cost tracking on streamed calls
- 5.x prices and 1M-token context windows
- Anthropic-format images
- fixes for dependencies that have drifted on PyPI

```bash
export ANTHROPIC_API_KEY=...
./tools/metagpt/setup.sh
vendor/MetaGPT/.venv/bin/metagpt "Create a 2048 game" --investment 3
```

Details: [`tools/metagpt/README.md`](tools/metagpt/README.md).

## Credits

- [MetaGPT](https://github.com/FoundationAgents/MetaGPT): the SOP, the roles and the document templates (MIT)
- [Ponytail](https://github.com/DietrichGebert/ponytail): the less-is-more coding discipline (MIT)
- [Claude Code](https://claude.ai/code): the runtime
