# Step: 05-operate-artifacts

## Description

Execute NotebookLM studio artifact operations through `nlm` and synchronize artifact metadata in the registry.

## Purpose

- Resolve artifact identity within a notebook.
- Generate artifact commands from current `nlm` documentation.
- Execute create, delete, download, and status operations.
- Maintain `studio_artifact_details` in the registry.

## Pre-stage Checkpoint

- Confirm the selected mode is **artifacts**.
- Load registry rules from [03-sync-registry.md](../registry/03-sync-registry.md).
- Load handover requirements from [operation-handover.md](../../references/output_formats/operation-handover.md).
- Run `nlm --ai` when the exact artifact command syntax is not already verified in the current session.

### Version Control

- Check current worktree status before editing registry files:

```powershell
git status --short
```

## Workflow

### Process

- Parse the requested artifact operation as one of `create`, `delete`, `download`, or `status`.
- Resolve notebook scope using notebook ID, title, or `notebook_alias_name`.
- For `create`, collect artifact type, optional custom instructions, and optional visual style prompt.
- Accept artifact type values only from `audio`, `video`, `report`, `inforgraphic`, `slides`, `quiz`, `flashcards`, `data_table`, and `mindmap`.
- For operations on an existing artifact, resolve artifact identity by exact artifact ID, artifact type, and notebook scope.
- If syntax is uncertain, run `nlm --ai` and extract the relevant artifact command pattern.
- Execute the selected `nlm` command.
- For status operations, update `status` when the CLI reports a current value.
- For create operations, add or refresh the artifact object with `custom_instructions` and `visual_style_prompt` when available.
- For download operations, report the download location and update status if CLI output indicates completion.
- For delete operations, remove the matching artifact object after successful CLI deletion.
- Run `scripts/validate-registry.ps1` when the registry was changed.

### Output Format

- Report operation results using [operation-handover.md](../../references/output_formats/operation-handover.md).
- Artifact records must conform to [registry-schema.md](../../references/registry-schema.md).

## Post-stage Checkpoint

### Progress Tracking

- Update `.agents/skills-diary/nlm-operator/[<instance-name>]/checklist.md` by marking the current phase as completed.

### Version Control

- Inspect changed files:

```powershell
git status --short
```

### Human in the Loop (HITL)

- Ask for confirmation before deleting an artifact unless the current user turn gave a direct delete instruction and exactly one artifact resolved.
- Ask for clarification when artifact type or target artifact is ambiguous.

### Auto pilot

- Proceed without confirmation for create, download, and status operations when all required inputs are explicit.
- For deletion in Autopilot, continue only when the request names exactly one resolvable artifact and explicitly asks for deletion.
