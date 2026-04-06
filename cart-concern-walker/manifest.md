# concern-walker

Iterates over a list of concerns — abstract items like style rules, check
categories, review topics. This cartridge provides the `concern` tool which
works exactly like `walk` but for concerns instead of files.

## Protocol

The cartridge that depends on this one provides a concerns file using
pipe-separated fields:

```
<name> | <description> [<source>] | <verify command>
```

The third field (verify command) is optional. If present, `concern next <file>`
runs it automatically with `{file}` replaced by the file path, and prints the
output. The model does not need to run verify commands manually — the tool
does it.

Lines starting with `#` are comments. Blank lines are ignored.
Do not use `|` (pipe) inside verify commands — it is the field separator.

### Logging

When starting a concern, run `date +%s` and append to workspace/log.md:

```
<timestamp> [concern-walker] concern-start <concern text>
```

When finishing a concern, run `date +%s` and append to workspace/log.md:

```
<timestamp> [concern-walker] concern-end <concern text> interventions=<N>
```

Where `<N>` is the number of changes made for that concern on the current file
(0 if no violations found).

### Verification

When a concern can be verified mechanically (e.g. "no alloca", "no include",
"no Natural"), use grep or other unix tools to check instead of guessing from
memory. Read the concern text — if it says "do not use X", grep for X. Trust
tool output over your own judgment.

### Tool use logging

Every shell command you run while processing a concern MUST be logged. After
running any command, run `date +%s` and append to workspace/log.md:

```
<timestamp> [concern-walker] tool <concern-name> $ <full command line> output=<N>
```

Where `<N>` is the total number of characters in stdout+stderr from that
command. This helps spot commands that produced unexpectedly large or empty
output.

Example:
```
1712412346 [concern-walker] tool "No include" $ grep -n "^include " workspace/logos-delivery/waku/common/base64.nim output=0
1712412348 [concern-walker] tool "Import grouping" $ grep -n "^import" workspace/logos-delivery/waku/common/base64.nim output=142
```

### File modification logging

Every time you modify a file while processing a concern, you MUST immediately
log the change to workspace/log.md. Use the timestamp from the last tool
output. Format:

```
<timestamp> [concern-walker] edit <concern-name> <file> <changelog>
```

The changelog must be specific enough for a reviewer AI to trace the change
without reading the diff. Include what was changed, where (line or symbol),
and how.

Examples:
```
1712412350 [concern-walker] edit "No inline pragma" workspace/logos-delivery/waku/common/base64.nim removed {.inline.} from proc `$`* (line 32) and proc `==`* (line 35)
1712412360 [concern-walker] edit "Import grouping" workspace/logos-delivery/waku/common/enr.nim reordered imports: moved std/options before ./typed_record
1712412370 [concern-walker] edit "Raises push" workspace/logos-delivery/waku/common/callbacks.nim changed {.push raises: [].} to {.push raises: [], gcsafe.} (line 1)
```

If you made no changes for a concern, do not write an edit line.

### Resuming

When `concern init` prints RESUMING, a previous session was interrupted
mid-file. The concern cursor tells you which concern you were on. Do not
reset — just call `concern next` and continue from where you left off.
The partially-processed file may have some concerns already applied.
That's fine — pick up at the current concern and keep going.

## Rules

- Never call `concern next` twice without `concern done` or `concern skip`.
- Process one concern at a time. Do not batch.
- The concern text is the model's instruction for what to check. Read it
  carefully each time — do not rely on memory of previous concerns.
