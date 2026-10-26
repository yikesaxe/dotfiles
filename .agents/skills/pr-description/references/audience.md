# Audience and depth

Order information from purpose to implementation. Keep the top useful to a
reader who does not know the package, while retaining technical evidence below.

- **Overview:** Explain the problem, change, and expected outcome in up to three
  sentences. Prefer plain language; keep function names and code out of it.
- **Changes and examples:** Address the engineers reviewing the diff. Name exact
  APIs, lifecycle boundaries, compatibility changes, and affected consumers where
  they matter. Group by conceptual change, not by file.
- **Decisions:** Explain the choice and tradeoff plainly, then put implementation
  mechanics underneath if needed. Include only decisions that were actually made.
- **Testing:** Be precise about commands, observed results, and coverage limits.
  Distinguish functional evidence from telemetry, compilation, and static checks.

Use short, descriptive headings and disclosure summaries that remain useful when
collapsed. Keep paragraphs and summary lines on one physical line so the target
renderer controls wrapping. Do not expose audience labels in the final artifact.

Use GitHub links for important code references, preferably to a stable revision
when available. Verify targets against the actual branch and diff. Prefer symbol
names over fragile line citations in durable explanations.
