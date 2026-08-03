# bin

Personal helper scripts. Not symlinked by `install.sh` yet - run them by path,
or add `~/dotfiles/bin` to `PATH`.

## recap-relay

Optional companion to the `visual-recap` skill. Turns a generated recap page
from "select text, copy a question, paste it into chat" into "select text, get
an inline answer" - closer to Google's Magic Pointer, minus voice and gesture.

```sh
~/dotfiles/bin/recap-relay
# then open the URL it prints
```

It serves `/tmp/visual-recap` on `http://127.0.0.1:8787` and answers
`POST /ask` by shelling out to the already-authenticated `claude` CLI. Ctrl-C
stops it; nothing keeps running.

### How much to trust the answers

Not much, for anything load-bearing. Two error layers stack:

1. `PAGE_CONTEXT` is a *summary written by an agent that read the source* - not a
   primary source. A misreading there gets repeated fluently and confidently.
2. It runs on Haiku by default (chosen for ~4s latency) and can drift even when
   the context is right.

Treat it as a reading aid ("what does this word mean, keep me moving"), not a
source of truth ("is this claim right, should I design around it"). For that,
go to the actual files, Jira, or Confluence - none of which the relay can see.

To keep that from being implicit, every answer carries a provenance tag that the
page renders as a colored footer:

| Tag | Meaning |
| --- | --- |
| `page` | grounded in `PAGE_CONTEXT` - still a paraphrase, not the source |
| `general` | model's own knowledge, nothing to do with this codebase |
| `not-covered` | project-specific and absent from the page; background only |
| `unknown` | the tag was missing from the response - trust nothing |

### One relay, all pages

Not one per page. The relay serves the whole `--dir`, and `POST /ask` is
stateless - each page posts its own `PAGE_CONTEXT` with the selection, so the
server never needs to know which page is asking. Start it once and every recap
page in the directory works.

Starting a second one on the same port just fails with "address already in use";
reuse the running one, or pass `--port`.

### Disk cleanup

Age-based cleanup is already handled by the OS, so the relay only does what the
OS won't. Verified from `/usr/libexec/tmp_cleaner`, which macOS runs daily at
midnight (`com.apple.tmp_cleaner`):

```
daily_clean_tmps_days="3"
args="-atime +$daily_clean_tmps_days -mtime +$daily_clean_tmps_days"
```

So anything in `/tmp` untouched for 3 days by atime, mtime *and* ctime is
removed automatically - and a page you keep reopening is never reaped, because
atime keeps resetting.

What that leaves is thinning a pile of pages from one active week. Prune by
count:

```sh
recap-relay --prune --dry-run     # list what would go, delete nothing
recap-relay --prune               # keep the newest 5, delete the rest
recap-relay --prune --keep 2
```

`--prune` exits without starting a server. Startup also prints the page count
and total size, so the footprint is visible without going to look.

### Lifetime

Closing the browser tab does **not** stop the server - they are unrelated
processes. Two backstops:

- It exits on its own after 30 minutes with no requests (`--idle-timeout`, `0`
  disables). Verified: it shuts down and releases the port.
- Kill it manually any time:

```sh
pkill -f recap-relay
lsof -nP -iTCP:8787 -sTCP:LISTEN   # confirm nothing is left
```

### What it can and can't answer

The relay is a plain `claude -p` call with **no MCP servers and no tools** -
`--strict-mcp-config` with no config, and Read/Grep/Bash/WebSearch/Task all
disallowed. It is deliberately much less capable than a Claude Code chat
session. It is also **not offline**: the server is local, but inference is a
real API call.

| Question type | Answered? | From |
| --- | --- | --- |
| General technical concepts (goroutines, gRPC, Kubernetes) | yes | model's own knowledge |
| This page's project specifics (Terrapin, `SessionState`, the ticket) | yes | `PAGE_CONTEXT` in the page |
| Datadog internals the page omits (LLMObs, Rapid) | partially | general background, plus an explicit "not in this page" |
| Anything needing your actual repo, Slack, or Jira | no | ask in a chat session instead |

`PAGE_CONTEXT` is a string authored into each page at generation time - the
relay does not read the DOM, so page content left out of that string is
invisible to it.

The system prompt has to hold two rules at once: use own knowledge freely for
general concepts, defer to `PAGE_CONTEXT` for project specifics. A first draft
only had the second rule and refused "what is a goroutine" as
not-covered-by-context - if you see that failure mode return, that balance is
what regressed.

### Why it serves the page instead of just exposing an endpoint

A page opened as `file://` has a null origin and generally cannot `fetch()` a
localhost endpoint. Serving the HTML from the same origin sidesteps CORS
entirely. Recap pages use a relative `/ask` URL, so the same file works both
ways: through the relay it answers inline, opened directly as `file://` the
fetch rejects and it falls back to copying a question to the clipboard.

### Why the page supplies the context, not the repo

Measured on `terrapin.SessionState`:

| Approach | Time | Result |
| --- | --- | --- |
| `--add-dir` + Read/Grep so the model searches the repo | 12.1s | failed to find the package |
| Page sends its own prose as context, no tools | 3.6s | accurate |

Recap pages are written from reading the source, so the page already holds the
authoritative explanation. Each generated page carries a `PAGE_CONTEXT` string
that gets posted alongside the selection.

### Scope

- Binds `127.0.0.1` only - the endpoint runs a subprocess per request and has
  no auth, so it must not be reachable off-host. Verified refused on the LAN IP.
- Serves only the `--dir` directory (default `/tmp/visual-recap`).
- Passes the prompt as a subprocess argument list, never through a shell.
- Caps selection at 2000 chars and context at 12000, with a 60s claude timeout.
- Any local process can reach it while it runs. It is meant to be started when
  you sit down to read a recap and stopped after - not left up.
