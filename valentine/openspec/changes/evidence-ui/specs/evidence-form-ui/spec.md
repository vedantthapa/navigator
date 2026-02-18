## ADDED Requirements

### Requirement: Evidence form captures core fields
The system SHALL provide a create/edit form that captures evidence name, description, evidence type, optional tags, optional NIST controls, and the type-specific content field.

#### Scenario: User selects a JSON evidence type
- **WHEN** the user selects the JSON evidence type
- **THEN** the form shows the JSON content input and hides the blob store link input

### Requirement: Evidence form pre-populates existing values
The system SHALL pre-populate the edit form with the existing evidence values.

#### Scenario: User edits existing evidence
- **WHEN** the user opens the edit form for an existing evidence item
- **THEN** the form fields contain the current evidence values

### Requirement: Evidence form surfaces server validation
The system SHALL display validation errors returned by the composer changeset on submit.

#### Scenario: User submits invalid evidence
- **WHEN** the user submits the form with invalid data
- **THEN** the form displays the validation errors from the server response

### Requirement: Evidence form provides JSON feedback
The system SHALL display an inline error when the JSON content input is not valid JSON.

#### Scenario: User enters invalid JSON
- **WHEN** the user enters malformed JSON in the JSON content input
- **THEN** the form shows an inline validation message for the JSON field
