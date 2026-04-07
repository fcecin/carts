# carts

Cartridges for [`golem`](https://github.com/fcecin/golem) — a context scheduler for LLMs.

Install `golem` first, then fetch these carts:

```
golem fetch github.com/fcecin/carts
```

## cart-logos-delivery-styler

Nim style enforcement for the [logos-delivery](https://github.com/logos-messaging/logos-delivery) codebase using the [Status Nim style guide](https://github.com/status-im/nim-style-guide).

### Workflow

```
golem init ~/work/style-run
golem cart-init styler ~/work/style-run
# When prompted, enter: https://github.com/logos-messaging/logos-delivery
cd ~/work/style-run
golem run
# Paste the boot phrase when prompted
```

Each `golem run` processes one file and stops. Run it again to process the next file. There are typically 500+ files in the codebase, so this takes many sessions.

### Performance warning

This cart was developed for thoroughness, not speed. It will obliterate your Claude subscription tokens. Each file is checked against 51 style concerns, each with a two-step process (tool-guided grep inspection + manual code scan by the model). A single file takes 10-15 minutes of Opus time.

The goal is for the output to be thorough and correct, not fast or cheap. That said, the output is not compiled and is not guaranteed to be actually thorough or any good. The following workspace files should be inspected to assess quality:

- `workspace/report.md` — what was changed per file and per concern. Every concern gets an entry even if no violations were found.
- `workspace/suggestions.md` — items the model flagged but did not fix (API breaks, ambiguous cases, things requiring compilation to verify).
- `workspace/log.md` — timestamped activity log with dual entries from both the tools (unfakeable) and the model. Can be used to detect cheating or skipped work.
- `workspace/cheats.md` — protocol deviations the model made (if it cut corners, it must document them here).
- `workspace/confusion.md` — ambiguities the model encountered in the instructions.
- `workspace/runs/golem-session-report-N.md` — one per session, summarizing what was done and why.

### Companion carts

The styler depends on these carts (fetched automatically as part of the same monorepo):

- **cart-file-stepper** — enforces one file per session to keep context fresh
- **cart-concern-walker** — iterates through style concerns with verify commands
- **cart-code-processor** — file-by-file walker with cursor-based state

### Post-run carts

- **cart-critic** — appends to task.md. After the styler finishes, writes a brutal `critique.md` with a 0-5 star rating. Use: `golem cart-init critic ~/work/style-run`
- **cart-rescuer** — replaces task.md. Rescues a failed or incomplete run by reverting bad changes and writing a new scoped task. Use: `golem cart-init rescuer ~/work/style-run`

## cart-file-stepper

Enforces one file per session. The walker iterates files as usual but the stepper makes the model stop after processing each file. This prevents context degradation on heavy workloads. Depends on cart-code-processor.

## cart-concern-walker

Iterates through a list of concerns (style rules, checks, review topics) one at a time. Concerns are defined in a pipe-separated text file with optional verify commands that run automatically. Logs to `workspace/log.md` with timestamps.

## cart-code-processor

File-by-file codebase walker. Provides the `walk` tool (init, next, done, skip, status, reset). Cursor-based state persists in `workspace/.walk/` for resume across sessions.

## cart-splicer

Splits large file-processing tasks into directory scopes. Each run processes one scope. Provides `splice` and `splice-plan` tools. Used when per-directory granularity is sufficient (lighter workloads than per-file stepping).

## cart-critic

Appends a post-completion critique phase to task.md. After the main task finishes, writes `workspace/critique.md` with a detailed analysis and a 0-5 star rating. Brutal and unforgiving.

## cart-rescuer

Replaces task.md. Reviews a failed or incomplete workspace, reverts bad changes, and writes a new task.md scoped for the next productive run. The surgeon of the cart ecosystem.
