# Registry Schema

The registry is a JSON file containing an array of notebook objects. The default path is `notebooklm-registry.json` in the vault root unless the user provides another path or `NOTEBOOKLM_REGISTRY` is set.

## Notebook Object

Required keys:

- `notebook-id`: NotebookLM notebook ID as a string.
- `title`: Notebook title as a string.
- `source_count`: Number of sources as a number or numeric string.
- `notebook_alias_name`: User-defined alias string or `null`.
- `source_details`: Array of source objects.
- `label_details`: Array of label objects.
- `note_details`: Array of note objects.
- `studio_artifact_details`: Array of artifact objects.

## Source Object

Required keys:

- `id`: Source ID as a string.
- `title`: Source title as a string or `null`.
- `type`: Source type as a string or `null`.
- `url`: Source URL as a string or `null`.
- `source_alias_name`: User-defined source alias as a string or `null`.

## Label Object

Required keys:

- `label_id`: Label ID as a string.
- `label_name`: Label name as a string.
- `lable_alias_name`: User-defined label alias as a string or `null`.
- `emoji`: Emoji string or `null`.
- `source_ids`: Array of source ID strings.

The key `lable_alias_name` intentionally preserves the spelling from the user specification.

## Note Object

Required keys:

- `note_id`: Note ID as a string.
- `note_title`: Note title as a string.
- `note_content`: Note content as a string or `null`.
- `preview`: Note preview as a string or `null`.

## Artifact Object

Required keys:

- `artifact_id`: Artifact ID as a string.
- `type`: One of `audio`, `video`, `report`, `inforgraphic`, `slides`, `quiz`, `flashcards`, `data_table`, or `mindmap`.
- `status`: Artifact completion status as a string or `null`.
- `custom_instructions`: User instructions as a string or `null`.
- `visual_style_prompt`: Visual style prompt as a string or `null`.

## Example

```json
[
  {
    "notebook-id": "notebook-123",
    "title": "Research Notebook",
    "source_count": 1,
    "notebook_alias_name": "research",
    "source_details": [
      {
        "id": "source-123",
        "title": "Paper",
        "type": "pdf",
        "url": null,
        "source_alias_name": "paper"
      }
    ],
    "label_details": [],
    "note_details": [],
    "studio_artifact_details": []
  }
]
```
