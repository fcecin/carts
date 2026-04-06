# walk plan

Walk the codebase in this order. Complete each scope before moving to the next.
Use `walk init` for each scope. After each scope completes, record it in
workspace/progress.md with a timestamp.

If resuming a previous run, check workspace/progress.md to see which scopes
are already done. Skip completed scopes.

## Scopes (in order)

1. material/target-repo/waku/waku_api/
2. material/target-repo/waku/waku_core/
3. material/target-repo/waku/node/
4. material/target-repo/waku/waku_relay/
5. material/target-repo/waku/waku_store/
6. material/target-repo/waku/waku_archive/
7. material/target-repo/waku/waku_filter_v2/
8. material/target-repo/waku/waku_lightpush/
9. material/target-repo/waku/waku_rln_relay/
10. material/target-repo/waku/rest_api/
11. material/target-repo/waku/
12. material/target-repo/apps/
13. material/target-repo/tests/
14. material/target-repo/library/
15. material/target-repo/tools/
16. material/target-repo/

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
