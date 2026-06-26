# Step: 04-operate-tags

## Description

Execute tag and label operations through `nlm` and synchronize `label_details` in the registry.

## Purpose

- Resolve tag identity from IDs, names, or aliases.
- Generate tag commands from current `nlm` documentation.
- Execute create, rename, delete, and list operations.
- Maintain tag metadata and source associations in the registry.

## Pre-stage Checkpoint

- Confirm the selected mode is **tags**.
- Load registry rules from [03-sync-registry.md](../registry/03-sync-registry.md).
- Load handover requirements from [operation-handover.md](../../references/output_formats/operation-handover.md).
- Run `nlm --ai` when the exact tag command syntax is not already verified in the current session.

### Version Control

- Check current worktree status before editing registry files:

```powershell
git status --short
```

## Workflow

### Process

- Parse the requested tag operation as one of `create`, `rename`, `delete`, or `list`.
- Resolve notebook scope if the CLI command or registry target is notebook-specific.
- Resolve tag identity using `label_id`, `label_name`, or `lable_alias_name`.
- Preserve the registry key spelling `lable_alias_name` because it is specified by the user.
- If syntax is uncertain, run `nlm --ai` and extract the relevant tag or label command pattern.
- Execute the selected `nlm` command.
- For list operations, present CLI output and refresh `label_details` when possible.
- For create or rename operations, refresh or update the matching label object.
- For delete operations, remove the matching label object after successful CLI deletion.
- Run `scripts/validate-registry.ps1` when the registry was changed.

### Output Format

- Report operation results using [operation-handover.md](../../references/output_formats/operation-handover.md).
- Tag records must conform to [registry-schema.md](../../references/registry-schema.md).

## Post-stage Checkpoint

### Progress Tracking

- Update `.agents/skills-diary/nlm-operator/[<instance-name>]/checklist.md` by marking the current phase as completed.

### Version Control

- Inspect changed files:

```powershell
git status --short
```

### Human in the Loop (HITL)

- Ask for confirmation before deleting a tag unless the current user turn gave a direct delete instruction and exactly one tag resolved.
- Ask for clarification when tag identity or notebook scope is ambiguous.

### Auto pilot

- Proceed without confirmation for list, create, and rename operations when all required inputs are explicit.
- For deletion in Autopilot, continue only when the request names exactly one resolvable tag and explicitly asks for deletion.
