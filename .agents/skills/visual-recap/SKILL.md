---
name: visual-recap
description: Generate a single self-contained local HTML file that visually shows a code change - a colored diff plus a flow diagram of the logic/feature - instead of a wall of markdown or a raw git diff. Use when the user asks to "visualize" a change, wants a "visual plan/recap", or wants to see the code flow of a new feature. Triggered by /visual-recap.
---

# Visual Recap

v1 - homegrown alternative to third-party `/visual-plan`-style skills. No hosted
service, no npm dependency: one local HTML file, opened in the browser. Iterate on
this file based on feedback about what was/wasn't useful - this is not settled.

## When to run

- Explicit `/visual-recap` invocation.
- User asks to "show this visually", "visualize the change/plan/flow", or similar.
- Proactively offer it after a non-trivial multi-file change, the same way
  `checkpoint` offers a retro - don't insist if declined.

## Steps

1. **Scope the change.** Default to the working tree diff (`git diff` for unstaged +
   `git diff --cached` for staged) if there are local changes; otherwise diff the
   current branch against its merge-base with the default branch
   (`git merge-base origin/main HEAD`). If ambiguous, ask which range.
2. **Read the actual changed files** (not just the diff hunks) enough to describe
   the flow accurately - don't invent structure that isn't in the code.
3. **Write a short plan/summary section**: what changed and why, grounded in the
   diff and commit messages, 3-6 bullets. This replaces the markdown plan the user
   would otherwise get in chat.
3b. **Add a "Concepts" section when the change touches machinery the reader may
   not know well** (a framework like Temporal, an unfamiliar subsystem, a
   protocol). Two parts, in this order:
   - What the surrounding code does *in the first place* - the role of the
     function/file being modified, before any mention of the change.
   - Plain-language definitions of the terms the rest of the page leans on, each
     tied to why it matters *here* rather than a generic glossary entry.
   Ask the user if unsure how much they know; default to including it for
   framework-level work and skipping it for routine changes in familiar code.
4. **Build one Mermaid flowchart** of the code flow or new feature path - the
   actual call/data flow through the changed functions, not a generic architecture
   diagram. Skip this if the change has no meaningful flow (e.g. a pure config
   tweak) rather than forcing a diagram.
5. **Render the diff** as simple colored HTML (green `+` lines, red `-` lines,
   monospace, file headers as section breaks) - parse `git diff` output directly,
   no external diff library. Two CSS traps that both cause content to spill
   outside its box, and both must be handled:
   - Diff lines: use `white-space: pre` (never `pre-wrap`, which destroys column
     alignment) inside a wrapper that is `display:inline-block; min-width:100%`,
     itself inside an `overflow-x:auto` container. The inner wrapper is what makes
     the row background colors extend the full scroll width instead of stopping at
     the viewport edge.
   - Any `<pre>` inside a CSS grid or flex column needs `min-width:0` on the
     column. Grid/flex items default to `min-width:auto`, which refuses to shrink
     and pushes wide code out of the card.
6. **Assemble one self-contained HTML file** in this fixed section order - same
   order every time, so a returning reader doesn't have to re-scan the page:
   a "start here" callout, the plan summary, the Concepts section (collapsed by
   default if present), the Mermaid diagram (loaded via CDN
   `<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js">`,
   rendered client-side), then the diff, then a closing next-action line. Plain
   CSS, no build step, no external files. See "Cognitive-load rules" below for
   the concrete layout/typography constraints this section must follow.
7. **Write it to `/tmp/visual-recap/<slug>-<YYYYMMDD-HHMMSS>.html`** (slug from the
   ticket key or branch name).
8. **Serve it, don't open the file path.** Opening `file:///tmp/...` makes the
   relative `POST /ask` fail, so "Ask about this" silently degrades to a clipboard
   copy. Always try to reach the page over HTTP first:
   1. Find a relay already serving `/tmp/visual-recap`. A listening port is NOT
      proof - confirm the process with `ps -p <pid> -o args=` and check it is
      `recap-relay`. **Do not assume 8787 is the relay**: Datadog's
      `headroom proxy` commonly occupies it, and it answers 404 for these files
      rather than failing loudly.
   2. If no relay is running, start one on a free port
      (`~/dotfiles/bin/recap-relay --port 9000`, backgrounded), guarded by a
      `-x` check on the script. Poll until `curl` reaches `/`.
   3. Verify the page itself with
      `curl -s -o /dev/null -w '%{http_code}' <url>` and require `200` before
      opening - a served root does not imply the file is served.
   4. `open <url>` on macOS, guarded by `command -v open`.
   5. Smoke-test `/ask` itself before declaring it working - a `200` on the page
      says nothing about the endpoint. `curl -X POST .../ask` with a real
      `{"selection","context"}` body and require a `200` plus an `answer` field.
   Note the relay **exits after 1800s idle**. It will therefore be dead on any
   session that returns to an older page, and the symptom is a silent drop back to
   clipboard copying. Re-probe and restart rather than assuming a relay started
   earlier is still up, and launch it detached (`nohup ... &`) so it is not tied to
   a single tool call.
   Fall back to `open <path>` only when the relay script is missing or won't
   start, and say so explicitly, because inline answers will not work in that
   case.
9. Tell the user the URL (or path, if it fell back) and what's in it. Ask what
   worked or didn't - feed that back into this SKILL.md rather than silently
   reverting to plain markdown next time.

## Cognitive-load rules

The reader may have ADHD - these constraints exist independent of whether
ADHD-mode is active in chat, because they're properties of the file, not the
conversation. Applies to every generated page:

- **Lead with a "start here" callout at the top**: 1-2 lines, what this page is
  and where to look first (e.g. "Read the diagram, then the diff for
  `session.go`"). This is the file's equivalent of leading a reply with the next
  action - the reader shouldn't have to scroll to find out why the page exists.
- **Fixed section order, every time** (see step 6). Predictable structure is
  the single highest-leverage change for ADHD/cognitive-accessibility readers -
  a returning reader should never have to re-learn the page layout.
- **Collapse secondary detail with `<details>/<summary>`.** Concepts sections,
  full file lists, and anything past the top 1-2 "must read" blocks default to
  collapsed. Nothing should force-scroll past content the reader didn't ask to
  expand.
- **No motion.** No auto-playing anything, no CSS animation/transition on load,
  no auto-scroll. Static page, reader controls all reveals (via `<details>`).
- **Chunk text, don't shrink it.** No single paragraph over ~4 lines, and
  prefer bullets over prose for anything list-shaped - but that's a rule about
  paragraph *shape*, not a word budget. Split a long explanation into several
  short paragraphs or a `<details>` block instead of cutting content to fit
  one short paragraph. This matters most for the Concepts section and anything
  behind a collapsed `<summary>`: the reader already paid the click-to-open
  cost, so give them the full explanation there, not a stub that still sends
  them back to chat. Thin content behind a click is worse than no click at
  all - it adds friction without saving any.
- **Comfortable typography**: body text >= 15px, `line-height: 1.6`, and cap
  text block width (`max-width: 70ch` or so) - long unbroken lines are harder
  to track back to the start of the next one.
- **Font stack**: lead with `"Atkinson Hyperlegible", "Lexend"` (loaded via
  Google Fonts CDN, same pattern as the Mermaid CDN script), falling back to
  system sans (`-apple-system, "Segoe UI", Arial, sans-serif`) if the CDN is
  unreachable. These two have the strongest evidence base for reducing letter
  crowding/confusion; Arial/Verdana are the safe fallback, not the first
  choice. Never use an italic body font - italics measurably hurt letterform
  recognition. Keep monospace (code/diffs) on the system mono stack - no
  legibility research targets code fonts specifically.
- **Contrast without halation**: off-white text on near-black background, not
  pure `#fff`/`#000` - pure black-on-white or white-on-black causes a glow
  effect (halation) that actively hurts readability, including for the ~1 in 3
  people with astigmatism. `#e6e8ee` text on `#0f1115` background (this file's
  existing palette) is already in the right range - don't "improve" it toward
  pure black/white.
- **Bold the one thing that matters per card**, mute the rest (lower-contrast
  color, smaller size) - don't bold everything, that's the same as bolding
  nothing.
- **Multi-file diffs get a progress cue**: a small "3 files changed" /
  "file 2 of 3" style header per diff section, not just a wall of concatenated
  diffs with no sense of how much is left.
- **End on one concrete next action**, not a recap. Same rule as chat replies:
  the last thing on the page is something doable, not a summary of what was
  just shown.
- **Inline click-to-expand glossary for jargon**, instead of making the reader
  copy a term back into chat to ask what it means. Any term used in prose that
  isn't defined by the sentence itself - a service name, an unfamiliar type,
  an internal API - becomes a `<button class="gloss-term">` inline; clicking
  it toggles a `<span class="gloss-pop">` directly after it open/closed. Pure
  CSS/JS, no network call, still works offline once the page has loaded. Reuse
  the exact markup/JS/CSS below rather than inventing a new pattern per file:

  ```html
  <span class="gloss">
    <button class="gloss-term" onclick="toggleGloss(this)">Terrapin</button>
    <span class="gloss-pop">Datadog's remote sandbox service - runs a real
    pod per session, reachable over gRPC.</span>
  </span>
  ```
  ```css
  .gloss-term { background:none; border:none; padding:0; margin:0; font:inherit;
    color:var(--accent); text-decoration:underline dotted; text-underline-offset:2px;
    cursor:pointer; }
  .gloss-pop { display:none; margin:6px 0 6px 0; padding:8px 12px;
    border-left:3px solid var(--accent); background:#131722; font-size:13.5px;
    color:var(--muted); max-width:60ch; }
  .gloss-pop.open { display:block; }
  ```
  ```js
  function toggleGloss(btn) { btn.nextElementSibling.classList.toggle('open'); }
  ```
  Pair this with a `showAnswer(selection, answer, source)` helper and a fixed
  dismissible panel (bottom-right, `max-height:70vh; overflow-y:auto`,
  `white-space:pre-wrap`) that shows the answer plus its `source:` tag. Do not use
  `alert()` - it blocks the page and loses the answer on dismiss.

  **The relay's `/ask` contract**, so this doesn't have to be rediscovered:
  request `{"selection": "...", "context": "..."}`, response
  `{"answer": "...", "source": "page" | "general" | "unknown"}`. Any other request
  field name returns `400`.

  A real `<button>` gets keyboard access (Enter/Space) for free - don't
  substitute a bare `<span onclick>`. Only glossary-ize terms this page can
  actually define well in 1-2 sentences; if a question needs more than that,
  it belongs in the chat conversation, not the file - don't stretch this into
  a live Q&A feature (that needs a real LLM call, which breaks the
  self-contained/offline file and would mean shipping API credentials into a
  static HTML file - see Notes).
- **Select-any-text "ask about this" button**, for the terms the glossary
  didn't anticipate. The glossary only covers what got pre-written; this
  covers everything else on the page. On text selection, a small floating
  button appears near the selection; clicking it copies a pre-filled question
  (selection + page title/ticket context) to the clipboard so the reader can
  paste it straight into chat instead of retyping what they just read. Still
  no network call - it copies text, it doesn't answer the question itself.
  Include on every generated page alongside the glossary:

  ```html
  <button id="ask-btn" class="ask-btn" style="display:none">Ask about this</button>
  ```
  ```css
  .ask-btn { position:fixed; z-index:1000; font-size:12.5px; padding:5px 10px;
    border-radius:6px; border:1px solid var(--accent); background:#131722;
    color:var(--accent); cursor:pointer; }
  ```
  ```js
  (function () {
    var btn = document.getElementById('ask-btn');
    var pageContext = document.title; // swap in the ticket key/slug per file
    document.addEventListener('mouseup', function () {
      var sel = window.getSelection();
      var text = sel.toString().trim();
      if (!text) { btn.style.display = 'none'; return; }
      var rect = sel.getRangeAt(0).getBoundingClientRect();
      btn.style.left = Math.max(8, rect.left) + 'px';
      btn.style.top = (rect.bottom + 6) + 'px';
      btn.style.display = 'block';
      btn.onclick = function () {
        btn.textContent = 'Asking...';
        // The relay's field MUST be named "selection" - it 400s on anything else.
        // And fetch() resolves on 4xx/5xx, so r.ok must be checked explicitly:
        // without it, a relay error is indistinguishable from no relay at all and
        // the clipboard fallback fires while the relay is running perfectly.
        fetch('/ask', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ selection: text, context: PAGE_CONTEXT })
        }).then(function (r) {
          if (!r.ok) { throw new Error('relay ' + r.status); }
          return r.json();          // -> { answer, source }
        }).then(function (d) {
          showAnswer(text, d.answer || '(empty answer)', d.source || 'unknown');
          btn.style.display = 'none'; btn.textContent = 'Ask about this';
        }).catch(function () {
          navigator.clipboard.writeText('From "' + pageContext + '", explain: "' + text + '"');
          btn.textContent = 'No relay — copied';   // name the fallback, don't hide it
          setTimeout(function () { btn.style.display = 'none'; btn.textContent = 'Ask about this'; }, 1800);
        });
      };
    });
    document.addEventListener('mousedown', function (e) {
      if (e.target !== btn) btn.style.display = 'none';
    });
  })();
  ```
  Set `pageContext` to the actual ticket key/slug when generating the file, not
  the literal `document.title` fallback, so the copied question carries real
  context (e.g. `"AIPAW-1789 terrapin recap"` rather than a generic page title).

## Notes

- Self-contained means: no server, no account, no localhost bridge. Just a file.
  This is the contract - don't add a required server dependency to it.
- Every page must still work opened straight from disk. `~/dotfiles/bin/recap-relay`
  is an *optional* companion that serves `/tmp/visual-recap` and answers a
  relative `POST /ask` by shelling to the `claude` CLI, so selections get an
  inline answer instead of a clipboard copy. Generated pages should post to the
  relative `/ask` URL and fall back to the clipboard path when that fetch
  rejects - which is what happens when the file is opened directly. Because the
  relay grounds answers in a `PAGE_CONTEXT` string the page carries, populate
  that string with the page's own concept prose when generating (measured: page
  context answered accurately in 3.6s; letting the model search the repo instead
  took 12s and still missed the package). See `bin/README.md`.
- If the diff is large, don't dump every file into one diagram - pick the 1-2
  files/functions that carry the actual logic change and note the rest were
  mechanical.
- Requires internet only to load the Mermaid CDN script when the file is opened -
  generation itself is fully offline.
