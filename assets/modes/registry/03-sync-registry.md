# Step: 03-sync-registry

## Description

Create, validate, refresh, repair, and query the local NotebookLM registry JSON used for ID and alias lookup.

## Purpose

- Keep notebook, source, tag, note, and artifact metadata discoverable.
- Provide deterministic identity resolution for natural-language requests.
- Preserve aliases across refreshes when CLI output does not include them.
- Validate registry JSON before handover.

## Pre-stage Checkpoint

- Confirm the selected mode is **registry**, or that another selected mode requires registry lookup or synchronization.
- Load schema requirements from [registry-schema.md](../../references/registry-schema.md).
- Load handover requirements from [operation-handover.md](../../references/output_formats/operation-handover.md).
- Run `nlm --ai` when refresh commands are uncertain.

### Version Control

- Check current worktree status before editing registry files:

```powershell
git status --short
```

## Workflow

### Process

- Check for the existence of registry file called [notebooklm-registry.json](../../references/notebooklm-registry.json).
- If no registry exists and the operation needs one, create `notebooklm-registry.json` in `.gemini/skills/nlm-operator/references/notebooklm-registry.json`.
- For lookup operations, search notebook aliases and titles first, then source aliases, source titles, URLs, tag names, tag aliases, note titles, and artifact IDs.
- For refresh operations, run the relevant `nlm` list or describe commands and map CLI output into the registry schema.
- Preserve existing alias fields when refreshed CLI output has the same object ID but no alias information.
- Use `null` for unknown optional values and arrays for missing nested collections.
- Repair only fields that can be proven from CLI output or unambiguous user instruction.
- Validate JSON syntax and required top-level keys with `scripts/validate-registry.ps1`.

### Output Format

- Registry files must be JSON arrays of notebook objects.
- Registry records must conform to [registry-schema.md](../../references/registry-schema.md).
- Report registry work using [operation-handover.md](../../references/output_formats/operation-handover.md).

## Post-stage Checkpoint

### Progress Tracking

- Update `.agents/skills-diary/nlm-operator/[<instance-name>]/checklist.md` by marking the current phase as completed.

### Version Control

- Inspect changed files:

```powershell
git status --short
```

### Human in the Loop (HITL)

- Ask before overwriting an existing registry file with a rebuilt version.
- Ask when two registry records claim the same alias or when CLI output conflicts with existing IDs.

### Auto pilot

- Create a missing registry at `notebooklm-registry.json` when the user requested registry-backed work and no path was specified.
- Preserve existing aliases during refresh.
- Prefer additive repair over deletion unless the CLI proves an object no longer exists.
