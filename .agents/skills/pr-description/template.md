# PR description outline

This is an outline, not text to publish verbatim. Replace prompts with verified
content, omit optional sections that add no value, and retain repository-required
fields. Never leave placeholders or authoring instructions in the final draft.

## Overview

Explain the problem, this PR's change, and its expected outcome in up to three sentences.

## Approach

Group the meaningful changes into a few concise bullets. Include the important scope boundary or compatibility impact.

### At a glance (optional)

Include a minimal user-facing usage example, a small Mermaid sequence diagram for changed flow, or a compact mapping table only when it makes the design easier to understand. Clearly distinguish new behavior from existing behavior.

### Implementation decisions (optional)

For each real decision, use a short subsection or a disclosure block:

<details>
<summary><b>Decision title</b> - the choice in a short phrase</summary>

**Chosen:** Explain the approach.

**Why:** Explain the constraint or tradeoff, including the weakest point reviewers should scrutinize.

**Alternatives considered:** Include only alternatives actually investigated, with the reason each was not chosen.

</details>

## Testing

For each applicable category (unit, integration/E2E, manual), state the command, observed result, and behavior verified. Say explicitly what was not run or remains unverified. Do not add empty categories solely to fill the template.

For lengthy evidence, keep the outcome visible and collapse supporting detail:

<details>
<summary><b>Test category</b> - observed outcome</summary>

Include the exact command and the relevant evidence. Link large logs or artifacts rather than pasting unrelated output. Label excerpted output as an excerpt.

</details>

## Reviewer guide (optional)

For a cross-team or large change, tell each reviewer where to start, what contract affects them, and what deserves scrutiny. Link the relevant components.

## Rollout and risks (when applicable)

State verified rollout gates, operational or compatibility risks, rollback considerations, and remaining limitations. Distinguish proposed rollout from current configuration.
