# mermaid: a Claude Code plugin

Helps Claude write Mermaid diagrams that parse the first time, render them to SVG, PNG or
ASCII, and use real product icons.

| Part | What it does |
|---|---|
| `mermaid-syntax` skill | Syntax reference: special characters, reserved words, escaping, Mermaid v11 changes, per-diagram-type rules, and the common pitfalls that break parsing. |
| `mermaid-studio` skill | Creates, validates and renders diagrams to SVG, PNG or ASCII; batch rendering; C4, AWS architecture-beta and theming references. |
| `mermaid-architecture-iconify` skill | Real logos in diagrams, through `architecture-beta` or the flowchart `icon` shape with Iconify packs. |
| `PostToolUse` hook | After every write to a `.mermaid`, `.mmd` or `.puml` file: warns about markdown bold that older renderers show literally, blocks bare `%%` lines (an opaque parse error otherwise), and, if the optional `diagram-render` CLI is installed, blocks diagrams that fail to render. |

## Install

```
/plugin marketplace add johntrandall/claude-plugins
/plugin install mermaid@johntrandall-plugins
```

## Requirements

- **Required:** `jq` (the hook reads its input with it; without `jq` the hook does nothing).
- **For mermaid-studio rendering:** Node.js 18 or later. The first render runs
  `scripts/setup.sh`, which installs `@mermaid-js/mermaid-cli`, `mermaid`, `beautiful-mermaid`
  and `puppeteer` (with a Chromium download) into the plugin's data folder.
- **Optional, for render checks in the hook:** [`diagram-render`](https://github.com/johntrandall/diagram-auto-renderer)
  plus `mmdc` (`npm install -g @mermaid-js/mermaid-cli`). Without them the hook still runs its
  text checks. When `diagram-render` runs, it also writes the `.svg` next to the source.

Tested on macOS. The skills are plain text and should work anywhere; the scripts need a POSIX
shell.

## Credits and licence

`mermaid-studio` is by Felipe Rodrigues (CC BY 4.0) and `mermaid-syntax` comes from
awesome-skills/mermaid-syntax-skill (MIT, per its README); both are modified copies. Details
in [THIRD_PARTY.md](THIRD_PARTY.md). Everything else is MIT, see [LICENSE](LICENSE).
