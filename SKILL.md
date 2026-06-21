---
name: nlm-operator
description: Use when you need to operate NotebookLM through the nlm CLI. This skill handles natural-language requests, command generation, execution, and uses a local JSON registry for ID and alias lookup.
---

# `notebooklm-mcp-cli-operator`

## Skill Overview

Use this skill when the user asks to operate NotebookLM through the `nlm` CLI or maintain a local NotebookLM registry. The skill converts natural-language requests into concrete CLI operations, resolves notebook/source/tag/artifact identities through the registry, executes appropriate shell commands, and updates the registry after state-changing operations.

The skill supports these operation families:

- **Notebook operations**: Create, rename, alias, delete, list, read, describe, and query notebooks.
- **Source operations**: Create, rename, alias, delete, list, read, and describe sources.
- **Tag operations**: Create, rename, delete, and list tags.
- **Artifact operations**: Create, delete, download, and check artifact status.
- **Registry maintenance**: Create, validate, refresh, repair, and query the local JSON registry.

## Workflow Sequence

| Stage | Description | Workflow | Input | Output |
| :--- | :--- | :--- | :--- | :--- |
| **1. Mode Selection** | Classify the user's request into one supported operation family. | User Choice | User request | Selected mode and operation intent |
| **2. Context Setup** | Load only the selected mode's workflow and shared registry requirements. | Asset Loading | Selected mode | Operation context and identity lookup plan |
| **3. Specialized Workflow** | Generate and run the required `nlm` shell commands for the selected mode. | Mode Logic | Operation context | Command results and changed NotebookLM state |
| **4. Registry Sync** | Update or verify the local JSON registry after reads or mutations. | Shared Finalization | CLI results | Current registry state |
| **5. Handover** | Report completed actions, commands run, registry changes, and any unresolved items. | Finalization | Results and registry diff | User-facing summary |

## Pre-stage Checkpoint

### Workflow Selection

Select exactly one mode before loading mode-specific assets:

- **notebooks**: Notebook-level operations.
- **sources**: Source-level operations scoped to a notebook.
- **tags**: Label/tag operations.
- **artifacts**: Studio artifact operations.
- **registry**: Registry creation, repair, lookup, validation, or refresh.

If the request spans multiple modes, split it into ordered sub-requests and execute one selected mode at a time. Persist the selected mode in working memory for the duration of that sub-request.

### HITL / Autopilot

- Use **Human in the Loop (HITL)** by default for destructive operations, ambiguous identity resolution, missing required arguments, or commands whose effect cannot be inferred confidently from `nlm --ai` documentation.
- Use **Autopilot** only when the user explicitly asks for it or when the requested operation is read-only and all required identifiers resolve unambiguously from the registry.
- Before deleting notebooks, sources, tags, or artifacts, obtain explicit user confirmation unless the user has already given a direct deletion instruction in the same turn with enough identifiers to resolve exactly one target.

### CLI Reference

If command syntax is uncertain, run:

```powershell
nlm --ai
```

Use the returned CLI documentation as the authoritative command reference for the current task.

## Core Operation Flow

### Global Stage: Mode Selection

Classify the request into one selected mode:

- Select **notebooks** for requests involving notebook creation, renaming, aliases, deletion, listing, content retrieval, description, or querying.
- Select **sources** for requests involving source creation, renaming, aliases, deletion, listing, content retrieval, or description.
- Select **tags** for requests involving tag creation, renaming, deletion, or listing.
- Select **artifacts** for requests involving artifact creation, deletion, download, or status checks.
- Select **registry** for requests involving registry initialization, validation, lookup, refresh, or repair.

Use the `ask_question` tool with `is_multi_select: false` to present the options to the user and capture their choice as a machine-readable value.
Load the selected mode's asset file from its specific sub-folder in `assets/modes/` only. Do not use another mode's workflow unless a later sub-request explicitly selects that mode.

### Global Stage: Context Setup

Before running `nlm` commands:

- Locate the registry JSON file using the registry workflow in [03-sync-registry.md](assets/modes/registry/03-sync-registry.md).
- Resolve notebook IDs from exact IDs, titles, or `notebook_alias_name`.
- Resolve source IDs from exact IDs, titles, URLs, or `source_alias_name`.
- Resolve tag IDs from `label_id`, `label_name`, or `lable_alias_name`.
- Resolve artifact IDs from `artifact_id`, artifact type, and notebook scope.
- If a natural-language reference maps to multiple registry entries, ask the user to choose.
- If a required ID is absent from the registry, run the relevant `nlm` list or describe command and then refresh the registry.

### Execution: Notebooks

Use [01-operate-notebooks.md](assets/modes/notebooks/01-operate-notebooks.md) for notebook operations. Support:

- Creating notebooks.
- Renaming notebooks.
- Adding or updating notebook aliases.
- Deleting notebooks.
- Listing notebooks.
- Getting notebook content.
- Describing notebook content.
- Querying notebook content.

After mutating notebook state, update the registry entry or remove it if deleted.

### Execution: Sources

Use [02-operate-sources.md](assets/modes/sources/02-operate-sources.md) for source operations. Support:

- Creating sources in a notebook.
- Renaming sources.
- Adding or updating source aliases.
- Deleting sources.
- Listing sources.
- Getting source content.
- Describing source content.

After mutating source state, update `source_details` for the affected notebook.

### Execution: Registry Maintenance

Use [03-sync-registry.md](assets/modes/registry/03-sync-registry.md) for registry maintenance. Support:

- Initializing the registry when missing.
- Refreshing notebook, source, tag, note, and artifact metadata.
- Validating registry schema and JSON syntax.
- Repairing stale aliases or missing IDs when CLI output provides enough evidence.
- Looking up IDs by title, alias, URL, or artifact metadata.

### Execution: Tags

Use [04-operate-tags.md](assets/modes/tags/04-operate-tags.md) for tag operations. Support:

- Creating tags.
- Renaming tags.
- Deleting tags.
- Listing tags.

After mutating tag state, update `label_details` for affected notebooks.

### Execution: Artifacts

Use [05-operate-artifacts.md](assets/modes/artifacts/05-operate-artifacts.md) for artifact operations. Support:

- Creating artifacts.
- Deleting artifacts.
- Downloading artifacts.
- Checking artifact status.

Artifact type values must be one of: `audio`, `video`, `report`, `inforgraphic`, `slides`, `quiz`, `flashcards`, `data_table`, or `mindmap`. Preserve the user's spelling for `inforgraphic` because it is specified as an admissible registry value.

After mutating artifact state, update `studio_artifact_details` for the affected notebook.

### Global Stage: Registry Sync

The registry must be valid JSON and contain an array of notebook objects. Each notebook object must preserve this shape:

```json
{
  "notebook-id": "notebook-123",
  "title": "Research Notebook",
  "source_count": 0,
  "notebook_alias_name": "research",
  "source_details": [],
  "label_details": [],
  "note_details": [],
  "studio_artifact_details": []
}
```

Use `null` for unknown optional values and arrays for nested collections. Do not write comments into the registry JSON.

### Global Stage: Handover

For every completed request, report:

- The selected mode and operation.
- The `nlm` commands run, summarized with sensitive paths or tokens omitted if present.
- The main CLI result.
- The registry file changed and the affected notebook/source/tag/artifact entries.
- Any follow-up required because CLI output, registry data, or user input was insufficient.

## Handover & Confirmation

The skill is complete for a request when:

- The requested `nlm` operation has been executed or a concrete blocker has been identified.
- The registry has been refreshed or updated when the operation changes NotebookLM state.
- The final response states what changed, what command evidence supports it, and where registry state was stored.
- Ambiguous or destructive operations have received HITL confirmation unless Autopilot was explicitly active.

## Additional Instructions

- **Naming Conventions**:
    - **Notebook Alias Format**: `<field-type>-<sub-field>-<notebook-type>` (e.g., `tech-xl-powerquery`).
    - **Source Alias Format**: `<source>-<notebook-type>-<source-description>` (e.g., `source-powerquery-specification`).
- Prefer `nlm --ai` over remembered CLI syntax whenever a command form is uncertain.
- Never fabricate NotebookLM IDs. Resolve IDs from CLI output or the registry only.
- Keep the registry valid JSON at all times; comments belong in skill references, not registry data.
- Use [checklist.md](references/checklist.md) to track multi-step operations.
- Use [registry-schema.md](references/registry-schema.md) and `scripts/validate-registry.ps1` before handing over registry maintenance work.
- All temporary scripts generated while execution of skills (scripts which will be deleted after execution) will be written in `.gemini/skills-diary/temp-scripts/<timestamp>/` as directory
