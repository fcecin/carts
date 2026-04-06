# walk plan

Walk the codebase in this order. Complete each scope before moving to the next.
Use `walk init` for each scope. After each scope completes, record it in
workspace/progress.md with a timestamp.

If resuming a previous run, check workspace/progress.md to see which scopes
are already done. Skip completed scopes.

## Scopes (in order)

1. workspace/target-repo/waku/waku_api/
2. workspace/target-repo/waku/waku_core/
3. workspace/target-repo/waku/node/
4. workspace/target-repo/waku/waku_relay/
5. workspace/target-repo/waku/waku_store/
6. workspace/target-repo/waku/waku_archive/
7. workspace/target-repo/waku/waku_filter_v2/
8. workspace/target-repo/waku/waku_lightpush/
9. workspace/target-repo/waku/waku_rln_relay/
10. workspace/target-repo/waku/rest_api/
11. workspace/target-repo/waku/
12. workspace/target-repo/apps/
13. workspace/target-repo/tests/
14. workspace/target-repo/library/
15. workspace/target-repo/tools/
16. workspace/target-repo/

Scope 11 (waku/) catches any files in waku/ not covered by earlier sub-scopes.
Scope 16 (root) catches anything remaining at the top level.

## Exclude patterns (all scopes)

--exclude '*/vendor/*'
--exclude '*/nimcache/*'
--exclude '*/build/*'

## Progress tracking

After completing a scope, append to workspace/progress.md:

```
DONE: <scope path> | <files processed> | <files skipped> | <timestamp>
```
