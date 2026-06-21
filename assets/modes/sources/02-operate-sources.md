# Step: 02-operate-sources

## Description

Execute source-level `nlm` operations within a resolved notebook and synchronize source metadata in the registry.

## Purpose

- Resolve notebook scope before resolving source identity.
- Generate source commands from current `nlm` documentation.
- Execute create, rename, alias, delete, list, get, and describe operations.
- Maintain `source_details` for the affected notebook.

## Pre-stage Checkpoint

- Confirm the selected mode is **sources**.
- Load registry rules from [03-sync-registry.md](../registry/03-sync-registry.md).
- Load handover requirements from [operation-handover.md](../../references/output_formats/operation-handover.md).
- Run `nlm --ai` when the exact source command syntax is not already verified in the current session.

### Version Control

- Check current worktree status before editing registry files:

```powershell
git status --short
```

## Workflow

### Process

- Parse the requested source operation as one of `create`, `rename`, `alias`, `delete`, `list`, `get`, or `describe`.
- Resolve the notebook scope first using notebook ID, notebook title, or `notebook_alias_name`.
- For `create`, collect the source input type, source title when provided, URL or local path when relevant, and optional alias.
- For operations on an existing source, resolve source identity within the selected notebook using exact source ID, exact alias, exact title, exact URL, or unique fuzzy title match.
- If a source reference is ambiguous, stop and ask the user to choose from concrete source candidates.
- If syntax is uncertain, run `nlm --ai` and extract the relevant source command pattern.
- Execute the selected `nlm` command.
- For read-only operations, present the CLI result and refresh `source_details` only if stale registry data is detected.
- For create or rename operations, refresh or update the matching source object.
- For alias operations, update only `source_alias_name`.
- For delete operations, remove the matching source object from `source_details` after successful CLI deletion and update `source_count`.
- Run `scripts/validate-registry.ps1` when the registry was changed.

### Output Format

- Report operation results using [operation-handover.md](../../references/output_formats/operation-handover.md).
- Source records must conform to [registry-schema.md](../../references/registry-schema.md).

## Post-stage Checkpoint

### Progress Tracking

- Update `.agents/skills-diary/nlm-operator/[<instance-name>]/checklist.md` by marking the current phase as completed.

### Version Control

- Inspect changed files:

```powershell
git status --short
```

### Human in the Loop (HITL)

- Ask for confirmation before deleting a source unless the current user turn gave a direct delete instruction and exactly one source resolved.
- Ask for clarification when notebook or source identity is ambiguous.

### Auto pilot

- Proceed without confirmation for read-only source operations.
- Proceed without confirmation for create, rename, and alias updates when all required inputs are explicit.
- For deletion in Autopilot, continue only when the request names exactly one resolvable source and explicitly asks for deletion.
