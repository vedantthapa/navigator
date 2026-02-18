## ADDED Requirements

### Requirement: Evidence linking is available from form and detail views
The system SHALL provide controls to link evidence to assumptions, threats, and mitigations from both the evidence form and the evidence detail view.

#### Scenario: User links evidence while creating
- **WHEN** the user uses the link control on the evidence form
- **THEN** the selected assumption, threat, or mitigation is linked to the evidence item

### Requirement: Evidence linking uses a searchable selector
The system SHALL allow the user to search and select a single related entity at a time using a dropdown selector.

#### Scenario: User searches for a related entity
- **WHEN** the user types into the link selector
- **THEN** the selector filters available entities and allows a single selection

### Requirement: Evidence can be unlinked from related entities
The system SHALL allow the user to unlink evidence from assumptions, threats, or mitigations from the evidence detail view.

#### Scenario: User removes a linked entity
- **WHEN** the user chooses to remove a linked entity
- **THEN** the relationship is removed and the detail view updates to reflect the change
