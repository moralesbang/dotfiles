---
name: work-translations
description: Translations to Humand's standard. Use before writing any key under `hu-translations/locale/`, including when a `humand-web` or `humand-backoffice` change needs new copy.
model: opus
effort: medium
---

Writes a **change** to the locale keys of `~/Projects/Work/hu-translations`, in every locale, and validates it. The repo is written as checked out, whichever repo the session runs in; branch, commit, and PR are the caller's job.

`~/Projects/Work/_workspace/standards/translations.md` owns the standard; read it before writing. Rule IDs below (`TR-…`) point into it. The repo's `.claude/skills/sync-translations/rules.md` is the **glossary**: fixed terms per locale (Muro → Feed) and how the `timezones` namespace is sourced.

**Placement** narrows TR-KEY-002 and TR-KEY-003 to the change: each new or renamed key takes its sorted place among its neighbours, and every pre-existing key keeps its position, every file its own format. The diff carries the change alone.

## Inputs

| input | |
|---|---|
| **Change** | Required. Each key's namespace, path, and operation: **add**, **edit**, **rename**, **delete**, or **fix** (a non-`es` value, `es` untouched). From a consumer repo, namespace and path come from its `t()` calls. |
| **`es` copy** | Required for add and edit: the words of the user, ticket, or design, verbatim. Missing → ask the user for it. |

## 1. Plan

List each key with its operation. Naming and placement follow the standard's Defaults and TR-KEY-001. Sort each edit by what changed in `es`:

- **format**: punctuation, capitalisation, or a renamed placeholder; the translatable words stay;
- **content**: the words change.

Run the standard's Escalation now, before any write. `es` copy that breaks a TR-ES rule is one of its contradictions: propose the corrected copy. A new namespace takes its TR-MOB-001 classification, and a web/admin-only key in a namespace mobile receives its TR-MOB-002 choice.

Done when every key has a namespace, a path, and an operation (plus its kind, for an edit), every add and edit has its `es` copy, and every Escalation case has the user's answer.

## 2. Mechanical

The changes that need no translator, applied inline:

- **`es`**: every add and edit written into `locale/es/` as given (TR-001).
- **rename**: the key moves in every locale, keeping each locale's value; its plural variants (`_few`, `_many`, …) move with it.
- **delete**: the key leaves every locale, with its plural variants.
- **format** edit: each locale's existing value takes the same transformation, and the rest of it stays as is, even where it reads wrong.
- **new namespace**: an empty `{}` file and its `index.ts` import and export in every locale (TR-NS-001), plus the blacklist entry its classification calls for.
- **deleted namespace**: its file, `index.ts` import and export, and blacklist entry go from every locale (TR-NS-002).

Blacklist edits follow the repo's `CLAUDE.md` (categories, ordering).

Done when every operation above has landed in every locale it touches.

## 3. Translate

The **translation** work: every add, every content edit, every fix. One subagent per locale with work (a fix touches only its named locales), all dispatched in one message with `model: opus` and `effort: medium`. Each locale owns its own files, so subagents never collide.

Each subagent's prompt carries:

- its locale, its files, and its keys, each with the `es` value; a fix adds the current value and what is wrong with it;
- the paths of the standard and the glossary, to read before writing;
- the rules that bind its result: TR-LOC-001 (target-language copy), TR-FMT-001–003 (placeholders, tags, the plural categories its language needs), TR-NO-001 for `no`, the standard's Defaults → Wording against its locale's existing terms, and placement (above);
- the return: the keys written, and every key whose `es` meaning it could not pin down.

Done when every subagent has returned and every key one flagged is settled with the user.

## 4. Validate

From the repo root:

1. `bun <skill dir>/scripts/check.ts --fix`: restores placement in every touched file, then checks the rest of the standard's Validation that `i18n:check` leaves out. Its `note` lines name touched files whose pre-existing order or format is off the standard.
2. `bun run i18n:check`.
3. `bun test`, when the check reports a blacklist change.

Each `review` line from the check is fixed, or is a value identical by nature (TR-LOC-001 "Not a violation"). The judgement items stay: changed `es` copy against TR-ES-001–003, changed `no` copy in Bokmål.

Done when the check exits 0 with every review settled, `i18n:check` and any `bun test` pass, and the judgement items hold.

## Output

```
work-translations · <n> keys · <operations> · <m> locales
check ✓ · i18n:check ✓ · bun test <✓ | n/a>
```

Then the **PR notes** for the caller's PR body, in a fenced `markdown` block, each line present only when it has content:

- mobile classification of each new namespace or web/admin-only key (TR-MOB-001, TR-MOB-002);
- every exception taken and every SHOULD broken, by rule ID;
- the locales and keys carrying English fallback (TR-LOC-001);
- each touched file from the check's `note` lines, by rule ID, with its order or format kept as found.

From a consumer repo, the consumer picks the change up through the `work-dependency-bump` skill.
