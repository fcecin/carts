# cart-splicer

depends: cart-code-processor

Splits a large file-processing task into scopes (directory segments). Each
run processes one scope. The splicer tracks which scopes are done so that
subsequent runs pick up at the next scope automatically.

## Protocol

The cartridge that depends on this one provides a splice plan — a text file
with one directory path per line. Each line is a scope to process.

### Startup

Run `splice init <plan-file>`. If resuming, it prints RESUMING with the
current scope. Then run `splice current` to get the active scope.

If `splice current` prints `ALL SCOPES DONE`, the entire task is finished.
Print a clear banner to the user:

```
=== ALL SCOPES COMPLETE ===
The splicer has determined there is no more work to do.
Final results are in workspace/report.md
```

Write the session report and stop. Do not process anything.

### Per-scope

For each scope:
1. `splice current` — get the directory to process.
2. `walk init <scope-directory> --maxdepth 1 --exclude '*/vendor/*' --exclude '*/nimcache/*' --force`
   Use `--maxdepth 1` so the walker only picks up files directly in this
   scope directory, not in subdirectories (those are separate scopes).
   Use `--force` because each scope needs a fresh walker initialization.
3. Process all files in this scope using the walker protocol.
4. When `walk next` prints DONE, this scope is finished.
5. `splice done` — advance to the next scope.
6. Stop the session. The next `golem run` will pick up at the next scope.

### One scope per session

Process ONE scope per run, then stop. This keeps sessions manageable and
ensures the context window stays fresh. The splicer cursor persists between
sessions so no work is repeated.

### Output across sessions

workspace/report.md and workspace/log.md are append-only. They accumulate
across all scopes and sessions. Do not overwrite them — always append.

Each session writes its own numbered golem-session-report-N.md (as required
by the kernel). So after 5 scopes you'll have 5 session reports plus one
continuously-growing report.md and log.md.

If the session must end mid-scope (timeout, interruption), the walker cursor
preserves progress within the scope. The next run resumes both the splice
(same scope) and the walk (same file within that scope).

## Logging

The splice tool logs to workspace/log.md with `[splice-script]` prefix.
