## Context

Evidence is currently surfaced as a read-only list. The workspace UI needs first-class flows to create, edit, view, and link evidence items while staying consistent with existing LiveView-based workspace patterns. Backend changes should reuse the existing composer API and changeset validation so UI-driven edits follow the same rules as other updates.

## Goals / Non-Goals

**Goals:**
- Add LiveView pages for evidence list, create/edit form, and detail view.
- Support evidence types with JSON content and file links, including validation feedback.
- Allow linking and unlinking evidence to assumptions, threats, and mitigations from the UI.

**Non-Goals:**
- Redesigning the evidence data model beyond fields required for UI flows.
- Implementing bulk import/export or advanced search.
- Introducing new services outside the existing Phoenix/composer stack.
- File upload workflows; only blob store links are supported for now.

## Decisions

- Implement separate LiveViews for list, form, and detail pages to align with existing workspace routing and to keep state and permissions isolated. Alternative: single LiveView with modal flows; rejected due to complexity and harder URL/state sharing.
- Use composer changesets for all create/update actions, surfacing validation errors directly in the form. Alternative: client-only validation; rejected because it risks drift from server rules.
- Add a lightweight JSON validation hook in the form for immediate feedback, but keep the server as the source of truth. Alternative: no client validation; rejected because JSON errors are hard to spot post-submit.
- Capture file evidence as `blob_store_link` URLs only; no upload UI. Alternative: integrate uploads now; rejected to keep the UI minimal and align with existing evidence generation patterns.
- Use `ValentineWeb.WorkspaceLive.Components.DropdownSelectComponent` for linking selectors with simple client-side filtering and one relation per action. Alternative: multi-select or async search; deferred to keep the UI minimal.
- Render evidence detail content conditionally (formatted JSON or link preview) and keep the output read-only. Alternative: inline editing on detail page; deferred to keep flows focused.

## Risks / Trade-offs

- [Complex form state for JSON + link inputs] -> Mitigation: isolate inputs into components and keep validation paths consistent with changesets.
- [Linking UI adds extra queries and latency] -> Mitigation: keep selectors focused to the current workspace scope and lazy-load options where possible.
- [Authorization mismatches between UI and API] -> Mitigation: reuse existing workspace authorization checks and surface clear error states.

## Migration Plan

- Add new routes and LiveView modules under the evidence workspace namespace.
- Wire composer API calls for create/update/link flows.
- Roll out behind existing navigation entry points; no data migration required.
- Rollback by removing routes and UI entry points if regressions appear.

## Open Questions

- None for now. Revisit if entity lists grow or file uploads become a requirement.
