## 1. Evidence Routing + Data Access

- [x] 1.1 Add workspace routes for evidence list, detail, and form (new/edit)
- [x] 1.2 Fetch evidence records for list and detail views via composer API
- [x] 1.3 Wire create/update actions to composer changesets and surface validation errors

## 2. Evidence Form UI

- [x] 2.1 Build LiveView form with fields for name, description, type, tags, and NIST controls
- [x] 2.2 Toggle JSON content vs blob store link inputs based on evidence type
- [x] 2.3 Add client-side JSON validation feedback for invalid JSON content
- [x] 2.4 Pre-populate edit form fields with existing evidence values

## 3. Evidence Detail UI

- [x] 3.1 Render evidence metadata (name, description, type, tags, NIST controls)
- [x] 3.2 Render JSON content as formatted JSON and blob store content as a link
- [x] 3.3 Add navigation from evidence list to detail view

## 4. Evidence Linking UI

- [x] 4.1 Add link controls on form and detail views for assumptions, threats, and mitigations
- [x] 4.2 Use DropdownSelectComponent to search/filter and select single related entities
- [x] 4.3 Implement unlink actions from the detail view and refresh related entities

## 5. Tests

- [x] 5.1 Add LiveView tests for evidence form create/edit flows and validation errors
- [x] 5.2 Add LiveView tests for evidence detail rendering by evidence type
- [x] 5.3 Add LiveView tests for linking/unlinking evidence to related entities
