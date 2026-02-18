## ADDED Requirements

### Requirement: Evidence detail view shows core metadata
The system SHALL render an evidence detail view that displays name, description, evidence type, tags, NIST controls, and related entities.

#### Scenario: User views evidence detail
- **WHEN** the user navigates to an evidence detail page
- **THEN** the evidence metadata and related entities are visible

### Requirement: Evidence detail view renders content by type
The system SHALL render JSON evidence content as formatted JSON and blob store evidence content as a clickable link.

#### Scenario: Evidence detail for JSON content
- **WHEN** the evidence type is JSON
- **THEN** the detail view shows the JSON content in a formatted, readable block

#### Scenario: Evidence detail for blob store link
- **WHEN** the evidence type is blob store link
- **THEN** the detail view shows a clickable link to the blob store URL

### Requirement: Evidence detail view supports navigation
The system SHALL provide a routable detail page for a specific evidence item within a workspace.

#### Scenario: User follows a detail link from the evidence list
- **WHEN** the user selects an evidence item from the list
- **THEN** the user is routed to the detail page for that evidence item
