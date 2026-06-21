# NotebookLM CLI Operator Skill

A professional AI CLI skill for managing and operating NotebookLM through the `nlm` command-line interface. This skill translates natural language requests into precise CLI operations, maintains a local identity registry, and handles complex workflows for notebooks, sources, tags, and artifacts.

## Installation

To use this skill with your AI agent, clone the repository into your skills directory:

```bash
git clone https://github.com/bewilderbeast24/ai-skills-nlm_operator.git nlm-operator
```

## Overview

The NotebookLM CLI Operator acts as an intelligent bridge between natural language intent and the `nlm` CLI. It eliminates the need to manually manage long hexadecimal IDs by maintaining a local JSON registry that maps human-readable titles and aliases to their respective NotebookLM identities.

### Core Capabilities

- **Notebook Management**: Create, rename, delete, and query notebooks.
- **Source Operations**: Add, list, and describe sources within specific notebooks.
- **Tagging System**: Organize notebooks and sources with labels and aliases.
- **Artifact Generation**: Create and download studio artifacts like audio overviews, reports, and quizzes.
- **Registry Synchronization**: Automatically keep a local database of your NotebookLM state for fast lookup.

## Usage Walkthrough

### 1. Registry Initialization
Before performing operations, initialize the local registry to index your existing notebooks.

**Request:** "Refresh my NotebookLM registry."
**Action:** The skill executes `nlm list` and populates `notebooklm-registry.json`.

### 2. Notebook Operations
Manage the lifecycle of your notebooks using natural language.

**Request:** "Create a new notebook called 'Project Alpha' and give it the alias 'alpha'."
**Request:** "What is the content of my 'Research' notebook?"
**Request:** "Delete the notebook with alias 'temp-notes'."

### 3. Source Management
Add and inspect sources within your notebooks.

**Request:** "Add the PDF at './docs/specs.pdf' to the 'alpha' notebook."
**Request:** "List all sources in my 'PowerQuery' notebook."
**Request:** "Summarize the source 'API Specification' in the 'alpha' notebook."

### 4. Tagging and Organization
Use tags to categorize your resources.

**Request:** "Tag the 'alpha' notebook with 'Urgent'."
**Request:** "Rename the 'Draft' tag to 'Final'."

### 5. Artifact Generation
Create specialized artifacts from your notebook content.

**Request:** "Generate an audio overview for the 'alpha' notebook."
**Request:** "Download the latest quiz artifact from 'Research'."

## Technical Architecture

### Identity Resolution
The skill uses a local `notebooklm-registry.json` file. When a request mentions a notebook by title or alias, the skill:
1. Searches the registry for a match.
2. Resolves the corresponding NotebookLM ID.
3. Constructs the `nlm` command using the resolved ID.

### Workflow Logic
Operations follow a structured sequence:
1. **Mode Selection**: Classification of request (notebooks, sources, tags, etc.).
2. **Context Setup**: Loading relevant registry data and resolving IDs.
3. **Execution**: Generation and execution of shell commands.
4. **Registry Sync**: Updating the local JSON file to reflect changes.
5. **Handover**: Providing a summary of actions and results.

### Safety and Controls
- **Human in the Loop (HITL)**: Required for destructive operations (delete) or when identity resolution is ambiguous.
- **Autopilot**: Used for read-only operations or when explicitly requested.

## Configuration

The skill looks for the registry at `notebooklm-registry.json` in the working directory by default. You can specify a different path via the `NOTEBOOKLM_REGISTRY` environment variable.

## Development and Validation

The skill includes a PowerShell script for registry validation:
```powershell
./scripts/validate-registry.ps1
```
This ensures the local registry maintains a valid schema and consistent data structure.
