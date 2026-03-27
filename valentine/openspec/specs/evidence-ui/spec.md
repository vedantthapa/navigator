# Evidence UI

## Purpose

This capability provides comprehensive user interface for creating, editing, and managing evidence records within workspaces. It includes evidence type-specific inputs, NIST control tagging, markdown description support, standardized display formatting, and filter enhancements.

## Requirements

### Requirement: Evidence create UI
The system SHALL provide a full-page evidence creation view within a workspace.

#### Scenario: Open new evidence page
- **WHEN** a user navigates to the evidence creation route for a workspace
- **THEN** the system displays a full-page form to create evidence

### Requirement: Evidence edit UI
The system SHALL provide a full-page evidence editing view for an existing evidence record.

#### Scenario: Open edit evidence page
- **WHEN** a user navigates to an evidence edit route
- **THEN** the system displays a full-page form pre-filled with the evidence details

### Requirement: Evidence type inputs
The system SHALL conditionally display evidence inputs based on the evidence type.

#### Scenario: JSON content evidence
- **WHEN** the user selects JSON content as the evidence type
- **THEN** the system displays an input for JSON content and hides the file link input

#### Scenario: File link evidence
- **WHEN** the user selects file link as the evidence type
- **THEN** the system displays an input for a blob store URL and hides the JSON content input

### Requirement: NIST control tagging and auto-linking
The system SHALL accept NIST controls via tag-style input and SHALL auto-link evidence to assumptions, threats, and mitigations by NIST controls on save.

#### Scenario: Create with NIST controls
- **WHEN** the user saves new evidence with NIST controls
- **THEN** the system persists the controls and auto-links evidence to matching entities by NIST controls

#### Scenario: Edit with updated NIST controls
- **WHEN** the user updates NIST controls and saves an existing evidence record
- **THEN** the system re-runs NIST auto-linking using the updated controls

### Requirement: Validation feedback
The system SHALL surface validation errors for required evidence fields in the create and edit views.

#### Scenario: Missing required fields
- **WHEN** a user attempts to save evidence without required fields
- **THEN** the system displays validation errors on the form

#### Scenario: Validation errors use consistent terminology
- **WHEN** user submits invalid evidence data
- **THEN** validation error messages SHALL use standardized evidence type names ("JSON Content", "File Link") rather than technical values

### Requirement: Markdown description editing
The evidence description field SHALL provide a Write/Preview tab interface for markdown editing.

#### Scenario: Write markdown in description
- **WHEN** user is on the evidence create/edit page
- **THEN** the description field displays Write and Preview tabs for markdown editing

#### Scenario: Preview markdown rendering
- **WHEN** user enters markdown text and switches to Preview tab
- **THEN** the system renders the markdown as formatted HTML

#### Scenario: Save markdown description
- **WHEN** user enters markdown in the description field and saves
- **THEN** the markdown text is stored and the evidence saves successfully

### Requirement: Markdown description rendering
The evidence description SHALL be rendered as formatted HTML in all views where evidence is displayed.

#### Scenario: Display formatted descriptions
- **WHEN** evidence with markdown description is displayed
- **THEN** the description is rendered as formatted HTML with visible styling (bold, italic, lists, links, etc.)

#### Scenario: Plain text descriptions render safely
- **WHEN** evidence has a plain text description without markdown syntax
- **THEN** the description renders as regular text with special characters escaped safely

#### Scenario: Existing descriptions remain compatible
- **WHEN** evidence created before markdown support is viewed or edited
- **THEN** plain text descriptions render without errors and can be enhanced with markdown formatting

### Requirement: Markdown security
The markdown rendering SHALL prevent execution of malicious content and XSS attacks.

#### Scenario: HTML and JavaScript neutralized
- **WHEN** user enters raw HTML or JavaScript in the description field
- **THEN** the content is escaped and rendered as text without executing

### Requirement: Evidence type display standardization
The system SHALL display all evidence type options consistently as "JSON Content" and "File Link" across all user interface contexts.

#### Scenario: Standardized type display in forms
- **WHEN** user views the evidence create or edit form
- **THEN** the evidence type dropdown options display "JSON Content" and "File Link"

#### Scenario: Standardized type display in filters
- **WHEN** user opens the evidence type filter on the index page
- **THEN** the filter options display "JSON Content" and "File Link"

#### Scenario: Standardized type display in cards
- **WHEN** user views an evidence item in a list or detail view
- **THEN** the evidence type displays as "JSON Content" or "File Link"

#### Scenario: Form field labels match type names
- **WHEN** user selects an evidence type in the form
- **THEN** the conditional field label displays the same standardized name (e.g., "JSON Content" not "JSON content", "File Link" not "Blob store URL")

### Requirement: Filter component custom labels
FilterComponent SHALL accept an optional labels parameter to override default display behavior for evidence type filters.

#### Scenario: Evidence filter uses custom labels
- **WHEN** user opens the evidence type filter on the index page
- **THEN** the filter displays standardized evidence type names using custom labels

#### Scenario: Filter component remains generic
- **WHEN** FilterComponent is used for other entity types
- **THEN** their display behavior remains unchanged and backward compatible
