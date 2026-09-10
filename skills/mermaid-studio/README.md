# mermaid-studio (local vendored fork)

This is John Randall's local fork of the `mermaid-studio` Claude Code skill originally authored by **Felipe Rodrigues** (`github.com/felipfr`), licensed under **CC-BY-4.0**.

## Upstream

The skill's `SKILL.md` frontmatter credits Felipe Rodrigues, but the original distribution source is not currently known — it was vendored into `~/.claude/skills/mermaid-studio/` at an earlier date with the version metadata `1.0.1`. If the canonical upstream repo is later identified, this fork can be re-baselined against it; until then this directory is the working copy.

If you (or anyone reading this) know the upstream repo, please open an issue / message John to update the provenance.

## Local modifications

| Date | Change | Rationale |
|---|---|---|
| 2026-05-14 | Added "Am I the right skill?" section near the top of `SKILL.md` | Diagram cluster reorganization (`diagram-meta` router pattern). Helps the agent re-route when a more specific skill applies. |
| 2026-05-14 | Narrowed the auto-invoke description to mermaid-studio's unique value (PNG/ASCII output, batch render, C4 / AWS architecture-beta, non-flowchart Mermaid types, theming) | The upstream description fires on every "mermaid" / "diagram" / "flowchart" mention, which over-loads context when more specific skills (`diagram-workflow-authoring`, `mermaid-syntax`, `mermaid-architecture-iconify`) handle the case better. |

The skill body (Golden Rules, references, scripts) is unchanged from the vendored copy.

## How it's wired in

```
~/.claude/skills/mermaid-studio  →  symlink  →  ~/dev/_vendored/mermaid-studio
```

The symlink means: edits to this directory are immediately reflected in the Claude Code skills loader, and commits live in this standalone git repo (not `~/.claude`).

## License

CC-BY-4.0 (inherited from the original). See `SKILL.md` frontmatter for the license declaration. Local modifications are also under CC-BY-4.0.

Attribution: **Felipe Rodrigues** (`github.com/felipfr`) — original author of `mermaid-studio`.
