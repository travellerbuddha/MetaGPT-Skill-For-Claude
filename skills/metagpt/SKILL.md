---
name: metagpt
description: Run a MetaGPT-style "software company" (Product Manager → Architect → Project Manager → Engineer → QA) inside Claude Code to turn a one-line idea into a PRD, system design, task plan, working code and tests. Use when the user says /metagpt, "MetaGPT", "yazılım şirketi", or asks to build an app from an idea end to end. No API key needed.
---

# MetaGPT in Claude Code

MetaGPT's core idea: `Code = SOP(Team)`. Each role produces one standard document, and the next role works only from the documents before it. You are the orchestrator. Run the roles with the Agent tool in this order and pass each one the project name and the paths, never your own summary of a document.

The role agents ship with this plugin. Installed as a plugin they are named `metagpt:metagpt-<role>` (e.g. `metagpt:metagpt-product-manager`); inside this repo without the plugin they are `metagpt-<role>`. Use whichever exists. Below they are written as `metagpt-<role>`.

Input: the user's idea (the skill arguments). Options the user may add:
- `--no-implement`: stop after the plan, which means skipping steps 4–5.
- `--no-tests`: skip step 5.
- `--inc <project_name>`: incremental change to an existing project. Every role reads the existing documents and code and writes "Refined" sections.

Write documents in the language of the user's idea. If the idea is in Turkish, write in Turkish.

## Steps

1. **Product Manager**: `subagent_type: metagpt-product-manager`, with the idea verbatim. It writes `docs/<project_name>/01-prd.md` and returns `project_name`.
   Then show the user the Product Goals, the P0 requirements and the "Anything UNCLEAR" assumptions in a few lines. If an assumption changes what gets built (platform, language, data source), ask before continuing. Otherwise continue.
2. **Architect**: `metagpt-architect`. It writes `02-system-design.md`.
3. **Project Manager**: `metagpt-project-manager`. It writes `03-tasks.md` and returns the ordered task list.
4. **Engineer**: `metagpt-engineer`, with the project directory `<project_name>/`. Leave test files from the task list to QA.
   - At most 4 files: run one engineer for all files.
   - More than 4 files: give one engineer the whole list in order (consistency beats parallelism). Split it only for very large projects of more than 15 files, in dependency order, so that a file never starts before the files it imports are written.
   - Then run the code once: start command, build, or `python -m py_compile` / `node --check`. Fix import and syntax errors with one more engineer call that names the file and the error.
5. **QA Engineer**: `metagpt-qa-engineer`. If it reports code bugs, send each bug to an engineer with `file: problem`, then re-run QA. Do at most 3 rounds, as MetaGPT does. If bugs remain after that, report them; never hide them.
6. **Summary**: list the documents and code paths, how to run the project, the test result (pass/fail counts), and the assumptions and limitations still open.

## Rules

- A role does not do another role's job. For example, an engineer does not change the PRD; if there is a contradiction it reports it, and you decide.
- Keep the mermaid diagrams in the documents as they are; GitHub renders them.
- Project output goes in `<project_name>/` at the repo root and the documents go in `docs/<project_name>/`. Unless the user asks, commit them like any other change.
