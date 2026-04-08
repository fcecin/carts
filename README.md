# carts

Cartridges for [`golem`](https://github.com/fcecin/golem) — a context scheduler for LLMs.

Install `golem` first, then fetch these carts:

```
golem fetch github.com/fcecin/carts
```

## cart-doer

General-purpose codebase transformer. Give it any task ("normalize isNil calls", "rename all ref types", "add error handling") and it will study the codebase, build skills from scratch, cache them, test on sample files, then execute across the full codebase. Discovers and uses installed carts at runtime — no hardcoded domain knowledge.

```
golem init ~/work/my-task
golem cart-init doer ~/work/my-task
# describe the task, point to the repo
golem clauder --dir ~/work/my-task --idle 20 --claude-args="--dangerously-skip-permissions"
```

Skills are cached in `golem/cache/` and reused across future tasks.

## cart-meta-doer

Promotes doer skills into publishable standalone carts. Run it on a completed doer workspace — it reads the cached skills and workspace evidence, assembles raw materials, then launches a golem session to polish them into a complete cart with manifest, cart-init script, tests, and evidence.

```
cd ~/work/my-task    # completed doer workspace
golem cart-init meta-doer .
# enter cart name, clauder launches automatically
```

## cart-fixer-isnil

The first cart produced by the doer→meta-doer pipeline. Normalizes Nim `isNil` calls to `.isNil()` method syntax. Pre-scans files with grep to skip non-matching files. Processed 546 files in 20 minutes with zero remaining violations.

```
golem init ~/work/fix-isnil
golem cart-init fixer-isnil ~/work/fix-isnil
golem run
```

## cart-logos-delivery-styler

Nim style enforcement for the [logos-delivery](https://github.com/logos-messaging/logos-delivery) codebase using the [Status Nim style guide](https://github.com/status-im/nim-style-guide). Thorough but expensive — 51 concerns per file, one file per session, 10-15 minutes per file on Opus.

```
golem init ~/work/style-run
golem cart-init styler ~/work/style-run
golem run
```

### Workspace output

- `workspace/report.md` — what was changed per file and per concern
- `workspace/suggestions.md` — items flagged but not fixed
- `workspace/log.md` — timestamped activity log (dual-logged by tools and model)
- `workspace/cheats.md` — protocol deviations the model made
- `workspace/confusion.md` — ambiguities encountered
- `workspace/runs/golem-session-report-N.md` — one per session

## Infrastructure carts

### cart-code-processor

File-by-file codebase walker. Provides the `walk` tool (init, next, done, skip, status, reset). Cursor-based state persists in `workspace/.walk/` for resume across sessions.

### cart-file-stepper

Enforces one file per session. Prevents context degradation on heavy workloads. Depends on cart-code-processor.

### cart-concern-walker

Iterates through a list of concerns (style rules, checks, review topics) one at a time. Concerns are defined in a pipe-separated text file with optional verify commands that run automatically.

### cart-splicer

Splits large file-processing tasks into directory scopes. Each run processes one scope. Provides `splice` and `splice-plan` tools.

## cart-golem-writer

The golem's own voice. Reads the entire golem installation — kernel, carts, tower essays, cache, local work dirs, laboratory — and writes essays about what it finds. Not documentation. Not changelogs. Essays.

Idea sourcing is driven by task.md (the main thread), with fallbacks to golem state changes, web search seeded by external sources, or silence. The cart will skip a day rather than publish filler.

```
golem init ~/work/writer
golem cart-init golem-writer ~/work/writer
# set up blog archive, idea sources, publishing method
golem clauder --dir ~/work/writer
```

Designed for daily cron-triggered runs via clauder.

## cart-daemon

Installs and removes system services on the local machine — cron jobs, systemd timers, systemd units. Surveys the system first, refuses to install packages, prefers user-level over root, stages files before deploying, tests everything, and documents the undo procedure.

```
golem init ~/work/my-service
golem cart-init daemon ~/work/my-service
# describe the service in plain English
golem run
```

The undo section in the report is mandatory — every installation is reversible.

## Post-run carts

### cart-critic

Appends a post-completion critique phase to task.md. Writes a brutal `workspace/critique.md` with a 0-5 star rating.

```
golem cart-init critic ~/work/style-run
golem run
```

### cart-rescuer

Replaces task.md. Reviews a failed or incomplete workspace, reverts bad changes, and writes a new task.md scoped for the next productive run.

```
golem cart-init rescuer ~/work/style-run
golem run
```
