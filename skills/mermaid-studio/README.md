# mermaid-studio (modified copy)

This skill is a modified copy of `mermaid-studio` by **Felipe Rodrigues** (`github.com/felipfr`),
from [tech-leads-club/agent-skills](https://github.com/tech-leads-club/agent-skills)
(`packages/skills-catalog/skills/(tooling)/mermaid-studio`, version 1.0.1).

**Licence:** [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), as declared in the
upstream `SKILL.md`. The modifications listed below are also offered under CC BY 4.0.

## Changes from upstream

Only `SKILL.md` and this README differ from upstream; `references/`, `scripts/` and `assets/`
are unchanged.

| Change | Why |
|---|---|
| Added an "Am I the right skill?" section near the top of `SKILL.md` | Points the agent at the sibling skills in this plugin when they fit better. |
| Narrowed the auto-invoke description to multi-format output, batch rendering, C4, AWS architecture-beta, non-flowchart types and theming | The upstream description fires on every "mermaid" or "diagram" mention. |
| Added a scope note above "Modes of Operation" | Same reason: the mode table describes behaviour after routing, not auto-invoke triggers. |
| Setup keeps npm dependencies in `${CLAUDE_PLUGIN_DATA}` via `MERMAID_STUDIO_DIR` | The skill folder is replaced on every plugin update. |
