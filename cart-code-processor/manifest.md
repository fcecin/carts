# code-processor

This cartridge processes a codebase file by file. It provides a tool (`walk`)
that controls which file the model works on. The model does not choose files.
The model does not skip ahead. The model does not decide the order. The tool
decides. The model processes what the tool gives it.

## Protocol

You MUST follow this loop exactly. Do not deviate.

### 1. Initialize

Run `walk init` with the root and excludes specified in task.md:

```
walk init <root> --exclude '*/vendor/*' --exclude '*/nimcache/*'
```

If the walk was already initialized from a previous session, the tool will
print RESUMING and tell you how many files remain. Do not pass `--force`.
Just proceed to the loop — `walk next` will pick up where you left off.

The file you were processing when the previous session ended may be partially
modified. Re-read it and re-process it from the beginning of the concern list
to ensure it is fully handled.

### 2. Loop

Repeat until the walk is done:

```
file=$(walk next)
```

If the output is `DONE`, stop. The run is complete.

Otherwise:

  a. Log walk-enter: run `date +%s`, append to workspace/log.md:
     `<timestamp> [code-processor] walk-enter <file>`
  b. Read the file at the path returned by `walk next`.
  c. Process it according to the instructions from other loaded cartridges.
  d. If you made changes, write the modified file.
  e. Log walk-exit: run `date +%s`, append to workspace/log.md:
     `<timestamp> [code-processor] walk-exit <file>`
  f. Run `walk done` to advance to the next file.
  g. If the file needs no changes, run `walk done` anyway.
  h. If the file should not be processed (generated code, etc.), run `walk skip`.

### 3. Report

After the walk prints `DONE`, run `walk status` and report the summary.

## Rules

- Never call `walk next` twice without calling `walk done` or `walk skip`
  in between. The cursor does not advance until you tell it to.
- Never process a file that `walk next` did not give you.
- Never process multiple files at once. One file per iteration.
- If you encounter an error processing a file, `walk skip` it and note the
  error. Do not stop the walk.
- You may read other files for context (e.g. to understand imports), but you
  only MODIFY the file that `walk next` gave you. All changes resulting from
  analyzing that file are resolved and written before calling `walk done`.
  Do not defer a fix to "when you get to that file later." If the current file
  reveals a problem elsewhere, note it in workspace/deferred.md — do not write
  to files you were not given.

## Index pass (optional)

Some processing tasks need cross-file context (e.g. who imports what, what
types exist). Before starting the main loop, you may run an index pass:

```
walk index
```

This prints the full file list. You may then read each file and build a
summary (e.g. exports, public symbols, types) into `workspace/index.md`.
This index is then available as context during the main processing loop.

To run an index pass, re-initialize the walk after building the index:

```
walk reset
```

Then proceed with the main loop as described above.
