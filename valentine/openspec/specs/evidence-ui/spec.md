# Evidence UI

## Purpose

This capability provides comprehensive user interface for creating, editing, and managing evidence records within workspaces. It includes an optional attachment workflow with description-only evidence support, markdown description editing, NIST control tagging, standardized display formatting, and a redesigned form layout with improved interaction patterns.

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

The system SHALL provide an optional attachment workflow where evidence type selection is not required upfront, allowing users to create description-only evidence or optionally add attachments.

#### Scenario: Description-only default state
- **WHEN** user opens the evidence creation form
- **THEN** the system displays the form ready for description-only evidence
- **AND** two card buttons SHALL offer optional attachment types

#### Scenario: Link URL attachment
- **WHEN** the user clicks "Link URL" card button
- **THEN** the system displays a URL text input for blob store links
- **AND** hides the card buttons
- **AND** displays a "Clear" button to return to description-only state

#### Scenario: Paste JSON attachment
- **WHEN** the user clicks "Paste JSON" card button
- **THEN** the system displays a textarea for JSON content
- **AND** hides the card buttons
- **AND** displays a "Clear" button to return to description-only state

#### Scenario: Clear attachment returns to description-only
- **WHEN** user clicks "Clear" button from an attachment state
- **THEN** evidence_type resets to `:description_only`
- **AND** attachment fields are cleared
- **AND** card buttons are displayed again

### Requirement: NIST control tagging and auto-linking
The system SHALL accept NIST controls via tag-style input and SHALL auto-link evidence to assumptions, threats, and mitigations by NIST controls on save.

#### Scenario: Create with NIST controls
- **WHEN** the user saves new evidence with NIST controls
- **THEN** the system persists the controls and auto-links evidence to matching entities by NIST controls

#### Scenario: Edit with updated NIST controls
- **WHEN** the user updates NIST controls and saves an existing evidence record
- **THEN** the system re-runs NIST auto-linking using the updated controls

### Requirement: Validation feedback

The system SHALL surface validation errors for required evidence fields including name, description, and type-specific attachment content in the create and edit views.

#### Scenario: Missing required fields
- **WHEN** a user attempts to save evidence without name or description
- **THEN** the system displays validation errors on the form

#### Scenario: Missing type-specific content
- **WHEN** user has selected an attachment type but not provided the required content
- **THEN** the system displays appropriate validation error

#### Scenario: Validation errors use consistent terminology
- **WHEN** user submits invalid evidence data
- **THEN** validation error messages SHALL use standardized evidence type names ("Description Only", "JSON Content", "File Link") rather than technical values

### Requirement: Markdown description editing

The evidence description field SHALL be required and provide a Write/Preview tab interface for markdown editing.

#### Scenario: Description is required
- **WHEN** user is on the evidence create/edit page
- **THEN** description field SHALL display label "Description *"
- **AND** description SHALL be required for form submission

#### Scenario: Write markdown in description
- **WHEN** user interacts with description field
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

### Requirement: Name field is prominently displayed as primary input

The evidence name input field SHALL be prominently displayed as the primary form input with appropriate styling and required field indicator.

#### Scenario: Name field rendering
- **WHEN** evidence form is displayed
- **THEN** name field SHALL have label "Name *" indicating it's required
- **AND** name field SHALL be visually prominent as the primary input

#### Scenario: Name field focus state
- **WHEN** user focuses name input field
- **THEN** field SHALL show focus indicator

### Requirement: Evidence number display below name

The form SHALL display the evidence number in format `#EVD-{numeric_id}` below the name field when editing existing evidence.

#### Scenario: Evidence number shown for existing evidence
- **WHEN** editing existing evidence with numeric_id
- **THEN** form SHALL display `#EVD-{numeric_id}` below name field

#### Scenario: Evidence number hidden for new evidence
- **WHEN** creating new evidence without numeric_id
- **THEN** evidence number SHALL NOT be displayed

### Requirement: Reduced spacing for tighter layout

Form subheads SHALL use reduced spacing for a tighter, more compact layout.

#### Scenario: Subhead spacing
- **WHEN** form is rendered
- **THEN** subhead elements SHALL have consistent reduced spacing
- **AND** layout SHALL be more compact than previous design

### Requirement: Two-column layout with sidebar at top

The form SHALL use a two-column layout where the right sidebar (NIST Controls/Tags) starts at the same vertical level as the "Name" label.

#### Scenario: Two-column layout structure
- **WHEN** form is rendered
- **THEN** main content SHALL occupy left column
- **AND** sidebar (NIST Controls/Tags) SHALL occupy right column
- **AND** sidebar SHALL start at same vertical position as "Name" label

### Requirement: No full-width divider after name

The form SHALL NOT display a full-width divider between the name field and subsequent sections.

#### Scenario: Name section layout
- **WHEN** form is rendered
- **THEN** no divider element SHALL appear after name field
- **AND** description section SHALL follow directly with standard spacing

### Requirement: Optional attachment section with conditional UI

The "Attach Evidence" section SHALL be labeled as optional and display different UI based on evidence type state.

#### Scenario: Attachment section label
- **WHEN** attachment section is rendered
- **THEN** label SHALL read "Attach Evidence (Optional)"

#### Scenario: Description-only state shows card buttons
- **WHEN** evidence_type is `:description_only`
- **THEN** two compact card buttons SHALL be displayed
- **AND** buttons SHALL offer "Link URL" and "Paste JSON" options

#### Scenario: Blob store link state shows URL input
- **WHEN** evidence_type is `:blob_store_link`
- **THEN** URL text input field SHALL be displayed
- **AND** "Clear" button SHALL be visible

#### Scenario: JSON data state shows textarea
- **WHEN** evidence_type is `:json_data`
- **THEN** JSON textarea SHALL be displayed
- **AND** "Clear" button SHALL be visible

### Requirement: Compact attachment type selection

Attachment type card buttons SHALL display in a compact horizontal layout with icon and text together for space-efficient presentation.

#### Scenario: Card button structure
- **WHEN** description-only state shows card buttons
- **THEN** buttons SHALL be displayed compactly side-by-side
- **AND** each button SHALL show icon and text together
- **AND** button text SHALL be "Link URL" or "Paste JSON"
- **AND** no additional help text SHALL be shown on buttons

#### Scenario: Card button interaction
- **WHEN** user clicks "Link URL" card button
- **THEN** evidence_type SHALL change to `:blob_store_link`
- **AND** URL input field SHALL be displayed

- **WHEN** user clicks "Paste JSON" card button
- **THEN** evidence_type SHALL change to `:json_data`
- **AND** JSON textarea SHALL be displayed

### Requirement: Clear button resets to description-only state

A "Clear" button SHALL allow users to reset evidence type back to `:description_only` and clear attachment fields.

#### Scenario: Clear button visibility
- **WHEN** evidence_type is `:blob_store_link` or `:json_data`
- **THEN** "Clear" button SHALL be displayed

#### Scenario: Clear button action
- **WHEN** user clicks "Clear" button
- **THEN** evidence_type SHALL reset to `:description_only`
- **AND** `blob_store_link` field SHALL be cleared
- **AND** `json_data` field SHALL be cleared
- **AND** two card buttons SHALL be displayed again

### Requirement: LiveView event handlers for evidence type changes

The LiveView SHALL provide event handlers for setting and clearing evidence type.

#### Scenario: Set evidence type event
- **WHEN** `set_evidence_type` event is triggered with type parameter
- **THEN** evidence_type SHALL be updated to specified type
- **AND** form SHALL re-render with appropriate UI

#### Scenario: Clear evidence type event
- **WHEN** `clear_evidence_type` event is triggered
- **THEN** evidence_type SHALL be set to `:description_only`
- **AND** attachment fields SHALL be cleared
- **AND** form SHALL re-render showing card buttons
