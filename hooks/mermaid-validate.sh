#!/usr/bin/env bash
# mermaid-validate.sh — PostToolUse hook for Write/Edit on diagram source files.
# Validates parse by attempting render via diagram-render --strict.
# Render failure → exit 2 → Claude sees the error and fixes the diagram.
#
# Also emits soft warnings (exit 0, message on stderr) for style issues that
# render fine under modern mmdc but break in older Mermaid renderers — e.g.
# Obsidian's bundled Mermaid. These never block the operation.
#
# Scope: *.mermaid, *.mmd, *.puml file writes only.
# Skipped silently if diagram-render is not installed (graceful degradation),
# but soft warnings still run.
#
# Companion: pre-commit lefthook (~/.config/lefthook/diagram-auto-render.sh)
# also renders + auto-stages SVGs at commit time.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath // ""' 2>/dev/null)

# Only fire on diagram source files
case "$FILE_PATH" in
  *.mermaid|*.mmd|*.puml) ;;
  *) exit 0 ;;
esac

# Soft check: markdown bold (**...**) in .mermaid sources.
# Modern mmdc renders this fine, but older renderers (Obsidian's bundled mermaid,
# some IDE plugins) display the asterisks literally. Markdown is also NOT processed
# inside explicit <div> wrappers used for left-alignment, even in modern mermaid.
# Recommend HTML <b>...</b> instead.
#
# - Skip lines starting with %% (comments)
# - Skip frontmatter blocks (between --- markers at the top of the file)
# - Match **non-empty content** (avoid hits on lone ** or *** edge cases)
warn_markdown_bold() {
  local file="$1"
  case "$file" in
    *.mermaid|*.mmd) ;;
    *) return 0 ;;
  esac
  [ -f "$file" ] || return 0

  local hits
  hits=$(awk '
    BEGIN { in_fm = 0; fm_done = 0 }
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/   { in_fm = 0; fm_done = 1; next }
    in_fm                           { next }
    /^[[:space:]]*%%/               { next }
    /\*\*[^*]+\*\*/                 { printf "  line %d: %s\n", NR, $0 }
  ' "$file")

  if [ -n "$hits" ]; then
    cat >&2 <<EOF
Mermaid style warning: markdown bold (\`**...**\`) in $FILE_PATH
$hits
Use \`<b>...</b>\` instead of \`**...**\` for cross-renderer compatibility
(Obsidian's mermaid is older than mmdc's, and markdown isn't processed inside
<div> wrappers even in modern mermaid). See the mermaid-syntax skill (mermaid plugin).
EOF
  fi
}

# Run soft checks first — they never block, just warn.
warn_markdown_bold "$FILE_PATH"

# Hard check: empty `%%` comment lines.
# Mermaid's parser treats a bare `%%` (no comment text) as a zero-length init
# directive and emits an opaque parse error ("Parse error on line 1: %%%%%%...")
# that does NOT point at the offending line. Reject these explicitly so the
# fix is obvious.
#
# Match: a line whose only non-whitespace content is `%%`.
# Do NOT match:
#   - `%% commentary text` (real comment)
#   - `%%{init: {...}}%%` (init directive)
check_empty_comment_lines() {
  local file="$1"
  case "$file" in
    *.mermaid|*.mmd) ;;
    *) return 0 ;;
  esac
  [ -f "$file" ] || return 0

  local hits
  hits=$(grep -nE '^[[:space:]]*%%[[:space:]]*$' "$file" || true)

  if [ -n "$hits" ]; then
    cat >&2 <<EOF
Mermaid validation FAILED for: $FILE_PATH

Empty %% comment line(s) detected:
$hits

A line containing only \`%%\` (with no comment text) is malformed — mermaid
parses these as zero-length init directives and reports an opaque parse error.

Fix: either add comment text after %% (e.g., \`%% section header\`) or delete
the line entirely. If you wanted a blank visual separator, leave it blank
(no %% at all).
EOF
    exit 2
  fi
}

check_empty_comment_lines "$FILE_PATH"

# Skip render-validation silently if diagram-render not installed (e.g., on a fresh machine)
if ! command -v diagram-render &>/dev/null; then
  exit 0
fi

# Validate by rendering. Side effect: SVG gets refreshed alongside source — desired.
if OUTPUT=$(diagram-render --strict "$FILE_PATH" 2>&1); then
  exit 0
fi

# Render failed = parse error. Surface to Claude via exit 2.
cat >&2 <<EOF
Mermaid/diagram validation FAILED for: $FILE_PATH

$OUTPUT

The diagram source has a syntax error. Fix it before continuing.

Common pitfalls (see the mermaid-syntax skill (mermaid plugin) for full list):
- Unquoted special characters: A[Click (here)] → A["Click (here)"]
- Reserved words as IDs: end, default, style, class, click, href
- Subgraph linking from nested to parent
- Comments must use %% (not single %)

Test interactively at: https://mermaid.live/
EOF
exit 2
