# Navigator Constitution

<!--
═══════════════════════════════════════════════════════════════════════════════
SYNC IMPACT REPORT - Version 1.0.0
═══════════════════════════════════════════════════════════════════════════════

Version Change: INITIAL → 1.0.0 (MINOR: Initial constitution establishment)

Modified Principles:
  - All principles newly established (initial version)

Added Sections:
  - Core Principles (5 principles)
  - Security & Compliance Requirements
  - Quality & Testing Standards
  - Governance

Removed Sections:
  - None (initial version)

Templates Requiring Updates:
  ✅ .specify/templates/plan-template.md - Constitution Check section present
  ✅ .specify/templates/spec-template.md - Requirements alignment validated
  ✅ .specify/templates/tasks-template.md - Task categorization aligns with principles
  ✅ .specify/templates/checklist-template.md - Generic template, no principle-specific updates needed
  ✅ .specify/templates/agent-file-template.md - Generic template, no governance references needed

Follow-up TODOs:
  - None - all templates validated and aligned with constitution principles

═══════════════════════════════════════════════════════════════════════════════
-->

## Core Principles

### I. Real-Time Collaboration First

Navigator MUST support real-time, multi-user collaboration as a foundational capability. All features involving threat models, diagrams, and documentation MUST enable concurrent editing without data loss. Phoenix LiveView connections MUST be stable and properly handle disconnection/reconnection scenarios.

**Rationale**: Threat modeling is inherently collaborative, involving security experts, developers, and stakeholders. Real-time collaboration eliminates handoffs and enables immediate feedback during security design reviews.

### II. Security by Design (NON-NEGOTIABLE)

Security considerations MUST be integrated into every feature from inception, not retrofitted. All data handling MUST follow secure coding practices. Authentication and authorization MUST be enforced at every layer. Security vulnerabilities identified by tools like Sobelow MUST be addressed before merging.

**Rationale**: As a security tool, Navigator must exemplify security best practices. Users trust Navigator to protect sensitive threat model data and compliance documentation.

### III. Test Coverage for Critical Paths

All critical user workflows MUST have automated test coverage, including:
- Workspace creation and management
- Threat statement creation and AI-assisted generation
- Data flow diagram editing and persistence
- Real-time collaboration synchronization
- NIST control mapping and export functionality

Tests MUST be written before implementation for new features. Test suite MUST pass on CI before merging.

**Rationale**: Navigator handles security-critical information. Regressions could lead to lost threat analysis or incorrect compliance documentation, undermining trust in the tool.

### IV. AI-Assisted, Human-Validated

AI features MUST augment human expertise, never replace it. All AI-generated content (threat statements, architecture analysis) MUST be clearly marked and require human review. Users MUST retain full control to accept, modify, or reject AI suggestions.

**Rationale**: Threat modeling requires contextual understanding and judgment that AI cannot fully replicate. The human expert remains the authority, with AI providing acceleration and suggestions.

### V. Compliance Documentation as Artifact

Compliance documentation (NIST control mappings, security assessments) MUST be automatically derivable from the living threat model. Manual compliance reporting MUST be minimized through automated exports. Documentation MUST stay synchronized with the current threat model state.

**Rationale**: Manual compliance documentation creates maintenance burden and drift from reality. Treating compliance as an artifact of good threat modeling practices ensures accuracy and reduces overhead.

## Security & Compliance Requirements

### Authentication & Authorization

- Multi-provider authentication MUST be supported (AWS Cognito, Google, Microsoft Entra ID)
- Authorization checks MUST occur at both route and data access levels
- API authentication MUST use token-based mechanisms with proper validation
- Session management MUST follow OWASP best practices

### Data Protection

- Sensitive configuration (API keys, client secrets) MUST use environment variables
- Database credentials MUST never be committed to version control
- AI API keys MUST be protected and rotated regularly
- Workspace data MUST be isolated by authenticated user/team access

### Security Tooling

- Sobelow static analysis MUST run in CI pipeline
- Known vulnerabilities in dependencies MUST be addressed promptly
- Security-focused code reviews MUST be conducted for authentication and authorization changes

## Quality & Testing Standards

### Code Quality Gates

- All code MUST pass `mix format --check-formatted` before merge
- Elixir compiler warnings MUST be addressed (no warning policy)
- Code reviews MUST verify adherence to Phoenix/Elixir conventions

### Testing Requirements

- New features MUST include tests for primary user workflows
- Bug fixes MUST include regression tests
- Integration tests MUST cover AI provider interactions and real-time collaboration
- Test suite MUST complete in under 30 minutes

### Performance Standards

- LiveView connections MUST establish within 2 seconds
- Diagram rendering MUST handle 100+ nodes without degradation
- Database queries MUST use proper indexing for workspace and threat lookups
- Real-time updates MUST propagate to all connected clients within 500ms

## Governance

### Amendment Process

This constitution governs all development practices for Navigator. Amendments require:

1. Documented justification for the change
2. Review by project maintainers
3. Update of all dependent templates and documentation
4. Version increment following semantic versioning

### Versioning Policy

Constitution versions follow MAJOR.MINOR.PATCH:
- **MAJOR**: Backward-incompatible changes (principle removal, fundamental redefinition)
- **MINOR**: New principles added or material expansions to guidance
- **PATCH**: Clarifications, wording improvements, non-semantic refinements

### Compliance Review

All pull requests MUST verify compliance with these principles:
- Code reviews MUST reference relevant principles when requesting changes
- Feature specifications MUST demonstrate alignment with Core Principles
- Architectural decisions MUST be justified against Security & Compliance Requirements

Complexity introduced MUST be justified. Deviations from established principles require explicit documentation and approval.

For runtime development guidance, consult `.github/copilot-instructions.md` and the specification templates in `.specify/templates/`.

**Version**: 1.0.0 | **Ratified**: 2026-01-06 | **Last Amended**: 2026-01-06
