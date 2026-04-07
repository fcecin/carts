# cart-file-stepper

depends: cart-code-processor

Processes one file per session. The file walker iterates through files as
usual, but this cartridge enforces a hard stop after each file. The next
`golem run` resumes at the next file.

This is for tasks where each file consumes significant context (e.g. running
many concerns per file). One file per session keeps the context window fresh
and prevents degradation.

## Protocol

### Startup

Initialize the walker as needed (the walker will RESUME if already initialized).
Then call `walk next` to get the current file.

If `walk next` prints `DONE`, all files are processed. Print:

```
=== ALL FILES COMPLETE ===
All files have been processed.
Final results are in workspace/report.md
```

Write the session report and stop.

### Per-file

1. `walk next` — get the file to process.
2. Process the file according to the instructions from other loaded cartridges.
3. `walk done` — mark the file as processed.
4. Write the session report and stop. ONE file per session.

Do not call `walk next` again after `walk done`. The session is over.
The next `golem run` picks up at the next file automatically.

### Output across sessions

workspace/report.md and workspace/log.md are append-only. They accumulate
across all files and sessions. Do not overwrite them — always append.

Each session writes its own numbered golem-session-report-N.md (as required
by the kernel).
