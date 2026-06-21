# Step: 01-operate-notebooks

## Description

Execute notebook-level `nlm` operations and synchronize the registry entry for affected notebooks.

## Purpose

- Resolve notebook identity from IDs, titles, or aliases.
- Generate shell commands for notebook operations from current `nlm` documentation.
- Execute create, rename, alias, delete, list, get, describe, and query operations.
- Update registry notebook records after mutations.

## Pre-stage Checkpoint

- Confirm the selected mode is **notebooks**.
- Load registry rules from [03-sync-registry.md](../registry/03-sync-registry.md).
- Load handover requirements from [operation-handover.md](../../references/output_formats/operation-handover.md).
- Run `nlm --ai` when the exact notebook command syntax is not already verified in the current session.

### Version Control

- Check current worktree status before editing registry files:

```powershell
git status --short
```

## Workflow

### Process

- Parse the requested notebook operation as one of `create`, `rename`, `alias`, `delete`, `list`, `get`, `describe`, or `query`.
- For `create`, collect the notebook title and any initial alias requested by the user.
- For operations on an existing notebook, resolve the notebook with this priority: exact notebook ID, exact alias, exact title, unique fuzzy title match.
- If the request is ambiguous, stop and ask the user to choose from concrete notebook candidates.
- If syntax is uncertain, run `nlm --ai` and extract the relevant notebook command pattern.
- Execute the selected `nlm` command.
- For read-only operations, present the CLI result and refresh the registry only if the CLI output reveals stale registry data.
- For create or rename operations, refresh or update the notebook record in the registry.
- For alias operations, update only `notebook_alias_name` for the resolved notebook.
- For delete operations, remove the matching notebook record from the registry after successful CLI deletion.
- Run `scripts/validate-registry.ps1` when the registry was changed.

### Output Format

- Report operation results using [operation-handover.md](../../references/output_formats/operation-handover.md).
- Registry notebook records must conform to [registry-schema.md](../../references/registry-schema.md).

## Post-stage Checkpoint

### Progress Tracking

- Update `.agents/skills-diary/nlm-operator/[<instance-name>]/checklist.md` by marking the current phase as completed.

### Version Control

- Inspect changed files:

```powershell
git status --short
```

### Human in the Loop (HITL)

- Ask for confirmation before deleting a notebook unless the current user turn gave a direct delete instruction and exactly one notebook resolved.
- Ask for clarification when a title or alias maps to more than one notebook.

### Auto pilot

- Proceed without confirmation for read-only notebook operations.
- Proceed without confirmation for create, rename, and alias updates when all required inputs are explicit.
- For deletion in Autopilot, continue only when the request names exactly one resolvable notebook and explicitly asks for deletion.
