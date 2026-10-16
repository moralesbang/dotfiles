---
name: work-standard
description: Rewrite or create one Humand engineering standard under `~/Projects/Work/_workspace/standards/`, grounded in the governed repos, and repoint its consumers.
disable-model-invocation: true
---

Writes **one standard**, either rewriting an existing file or creating a new one, and repoints its consumers. The diff stays uncommitted in `~/Projects/Work/_workspace` for the user to review and commit.

`~/Projects/Work/_workspace/standards/meta/standard-authoring.md` owns the authoring rules; read it before anything else. Rule IDs below (`STD-…`) point into it; this skill holds only the procedure. `standards/README.md` owns the prefixes.

The standard is written in English; everything said to the user, in Spanish.

## Inputs

| input | |
|---|---|
| **Mode** | **rewrite**: the path of an existing standard. **create**: the domain plus its source material (notes, conversation, repo paths). Create with no source material → ask the user for it. |

The target file with uncommitted changes (`git -C ~/Projects/Work/_workspace status --porcelain`) → ask the user before starting, so the diff they review holds this run alone.

## 1. Ground

Read the source: the file (rewrite) or the material (create). From its scope, name the governed repos under `~/Projects/Work/`. Then dispatch, in one message:

- **Repo**, one subagent per governed repo. For each source statement or candidate rule: whether the repo's practice is consistent, mixed, or contradicts it, with `file:line`; the validation commands and CI checks that exist; conventions the repo follows consistently that the source omits; and source lines that only restate what one file read or one command shows (STD-CON-001).
- **Plugin**, for domains `HumandDev/hu-ai-agent-plugin` covers (React frontend: `humand-web`, `humand-backoffice`, `hu-material-ds`); skipped otherwise (git, translations). Reads `plugins/humand-react/` fresh at `main` through `gh api repos/HumandDev/hu-ai-agent-plugin/contents/<path>?ref=main`: every `rules/` file, and every `skills/*/SKILL.md` touching the domain. Returns each requirement the source lacks and each that contradicts it, quoted with its path.
- **Consumers**: every pointer to the target file, by file name, section, or rule ID, in `~/.claude/skills/work-*/`, `standards/`, `_workspace/WORKFLOW_MANIFEST.md`, and each `~/Projects/Work/*/CLAUDE.md`. Returns `file:line` and the section or ID each one names.

Every subagent prompt carries the clean-room boundary: never read, search, or browse `humand-main-api`; never search Linear.

Done when every subagent has returned, every source statement carries its repo evidence, and every consumer pointer is listed.

## 2. Decide

Build the **coverage map** (rewrite only, STD-REW-004): each source statement → the rule ID or section that will hold it, or *eliminated* with its reason (duplicate, no-op, obsolete, STD-CON-001). The map stays in your context; the report shows the eliminations.

Collect the **decisions**, and only these:

- each contradiction: source against itself, against repo practice, or against another standard (STD-REW-003);
- each material policy change, including a convention the repo follows that the source omits (STD-REW-002);
- each plugin finding, one decision apiece: the standard takes plugin content only on the user's answer;
- create mode: the prefix and its README category; a collision is its own decision (STD-IDX-002).

Put them to the user in one grilling round: numbered, each with your recommended answer, worded so "yes" accepts it. Wait for the answers. No decisions → no round.

The plugin is an authoring input only: the standard never names it, in Precedence, References, or anywhere else.

Done when every decision has the user's answer and every source statement has its map entry.

## 3. Write

Write the standard to `standards/<name>.md` under `standard-authoring.md`. Rewrite: every rule that already has an ID keeps it (STD-RULE-004); new IDs take the README prefix.

Run the meta-standard's Validation against the file and fix each failure.

Done when every item of `standard-authoring.md` → Validation passes and every map entry lands where the map says.

## 4. Repoint

- **README**: the standard's entry, prefix, and scope phrase in `standards/README.md` (STD-IDX-001).
- **Pointers**: each consumer pointer whose section or ID changed is edited to the new name, and nothing else in that consumer (STD-SOT-006).
- **Semantic impacts**: a consumer whose behavior the new policy changes (a skill restating a changed rule, a step relying on removed policy) stays as is and goes into the report.

Done when every listed pointer resolves to a section or ID that exists in the new file.

## Output

In Spanish, each section present only when it has content:

```
work-standard · <rewrite|create> · <file> · <n> rules · prefix <PREFIX>
```

- **Política nueva o cambiada**: rule ID, before → after, its evidence. The user vetoes from here.
- **Eliminado o fusionado**: each original statement, quoted, with its reason. Every line deleted under STD-CON-001 is listed one by one.
- **Decisiones**: each contradiction and plugin finding with the user's answer.
- **Punteros actualizados**: `file:line`, old → new.
- **Impactos semánticos (no aplicados)**: consumer, and what would change.
- **README**: entry added or changed.

Close with `git -C ~/Projects/Work/_workspace diff` for review; pointer edits outside `_workspace` (skills, repo `CLAUDE.md`) are listed above, since that diff does not show them.
