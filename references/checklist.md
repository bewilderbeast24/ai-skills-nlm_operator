# NotebookLM MCP CLI Operator Checklist

Use this checklist for multi-step requests and registry-changing work.

- [ ] Select exactly one mode for the current sub-request.
- [ ] Load only the selected asset workflow.
- [ ] Locate or initialize the registry file.
- [ ] Resolve notebook scope when required.
- [ ] Resolve source, tag, artifact, or note identity when required.
- [ ] Run `nlm --ai` if command syntax is uncertain.
- [ ] Execute the `nlm` command.
- [ ] Capture command output needed for registry updates.
- [ ] Update registry JSON after state-changing operations.
- [ ] Preserve aliases during registry refresh.
- [ ] Run `scripts/validate-registry.ps1` after registry edits.
- [ ] Report results using `references/output_formats/operation-handover.md`.
