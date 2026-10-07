---
name: obs
description: Load content from an Obsidian vault note into the current conversation context. Use whenever the user invokes /obs, references a vault note path, or wants to read from their Obsidian brain before running another skill (e.g. "/brainstorming /obs 'path'", "/obs 'path' sections: Summary"). Accepts an optional sections filter to pull specific headings only.
---

## Vault

```
/Users/moralesbang/Library/Mobile Documents/iCloud~md~obsidian/Documents/Owlet's brain
```

## Invocation format

```
/obs '<relative-path>' [sections: <Section Name> [and <Section Name>...]]
```

- `<relative-path>` — path relative to the vault root, without the `.md` extension.
- `sections:` — optional. One or more heading names (any level), comma- or "and"-separated.  
  If omitted, the entire file is loaded.

**Examples:**
```
/obs '30 Engineering/Prompt - Dynamic forms endpoints switch'
/obs '30 Engineering/Prompt - Dynamic forms endpoints switch' sections: Summary
/obs '30 Engineering/Prompt - Dynamic forms endpoints switch' sections: Summary and Rules
```

## Steps

### 1. Resolve the file path

Append `.md` to the relative path and join with the vault root:

```
<vault>/<relative-path>.md
```

### 2. Read the file

Use the Read tool on the resolved path.

### 3. Apply sections filter (if provided)

If `sections:` was specified, extract only the content under each named heading:

- A heading matches if its text (stripping `#` characters and surrounding whitespace) equals the requested section name — **case-insensitive**.
- Include the heading line itself in the output.
- A section ends when the next heading of **equal or lesser depth** appears (e.g. a `##` section ends at the next `##` or `#`), or at end of file.
- If multiple sections are requested, output them in the order they appear in the file.
- If a requested section is not found, note it briefly: `> Section "X" not found.`

### 4. Output the content

Present the extracted content clearly labeled so the rest of the conversation can use it:

```
**Vault note:** `<relative-path>`
[*Sections: <names>* | *Full file*]

---

<content>
```

Keep the label concise — the content is what matters. Do not summarize or paraphrase; output the raw markdown as-is so the exact wording is preserved for whatever skill or task follows.
