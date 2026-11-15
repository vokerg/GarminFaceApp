# Superseded May experiments

Repository closeout found two May 2026 branches beyond the original main-branch audit. Their history is incorporated through an explicit **ours-strategy merge**: the current owner-approved implementation remains the active source, and these earlier alternatives are preserved as historical material rather than reintroduced into the build.

| Former branch | Tip | Preserved tag |
| --- | --- | --- |
| `agentic-segment-week-face` | `cf6a5dc` | `archive/may-agentic-segment-week-face` |
| `serious-fenix-layout-v7` | `cd231ad` | `archive/may-serious-fenix-layout-v7` |

The serious-layout branch is an ancestor of the segment-face branch; incorporating the latter's history incorporates both. The tags preserve the exact original tips after branch cleanup.

Each adjacent `.tar.gz` contains that tip's `source/`, `resources/`, manifest and build configuration. Full commit history, including generated artifacts, remains accessible through the tags. The archives deliberately omit historical compiler output from these snapshots.

These are older alternative designs, not missing pieces of the accepted November face. The segment view still falls back to aggregate ActivityMonitor distance for running and uses calendar-week complication values; that behavior must not replace the current sport-specific trailing-168-hour implementation. Do not compile these snapshots as active source.
