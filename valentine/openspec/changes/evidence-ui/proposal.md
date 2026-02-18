## Why

Evidence is currently managed through the API and only surfaced as a read-only list in the UI. This slows down workflows for security reviews and makes it hard for users to add or organize evidence as they work. A first-class UI for creating, editing, and linking evidence removes friction and keeps evidence management in the same place as the rest of the workspace flow.

## What Changes

- Add UI flows to create and edit evidence records, including support for JSON data and file links.
- Add an evidence detail view that shows metadata, content/link, and related entities.
- Add UI controls to link evidence to assumptions, threats, and mitigations during creation or from the detail view.
- Enhance the evidence list with create entry points and quick actions for edit/delete.

## Capabilities

### New Capabilities
- `evidence-form-ui`: Create and edit evidence with required fields, validation, and type-specific inputs.
- `evidence-detail-view`: View a single evidence item with metadata, content/link preview, and related entities.
- `evidence-linking-ui`: Link and unlink evidence to assumptions, threats, and mitigations from the UI.

### Modified Capabilities

## Impact

- LiveView pages under `lib/valentine_web/live/workspace_live/evidence` for list, form, and detail views.
- Workspace routing to support evidence detail and edit pages.
- Composer evidence API and changeset validation for UI-driven edits.
- Frontend hooks or components for form inputs, optional JSON validation, and link selectors.
