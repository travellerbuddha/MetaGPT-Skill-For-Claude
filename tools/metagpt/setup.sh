#!/usr/bin/env bash
# Install MetaGPT (pinned + patched for Claude) and point it at Claude.
# Idempotent: re-running only re-renders the config when already installed.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"
METAGPT_REF="11cdf466d042aece04fc6cfd13b28e1a70341b1f"
METAGPT_HOME="${METAGPT_HOME:-$REPO_ROOT/vendor/MetaGPT}"
MODEL="${METAGPT_CLAUDE_MODEL:-claude-opus-5-5}"
VENV="$METAGPT_HOME/.venv"
STAMP="$VENV/.texvector-installed-$METAGPT_REF-$(cat "$HERE/overrides.txt" "$HERE"/patches/*.patch 2>/dev/null | sha1sum | cut -c1-12)"

if [ ! -f "$STAMP" ]; then
  if [ ! -d "$METAGPT_HOME/.git" ]; then
    git clone --filter=blob:none https://github.com/FoundationAgents/MetaGPT.git "$METAGPT_HOME"
  fi
  git -C "$METAGPT_HOME" fetch --quiet origin "$METAGPT_REF" 2>/dev/null || true
  git -C "$METAGPT_HOME" checkout --quiet --force "$METAGPT_REF"
  git -C "$METAGPT_HOME" clean -fdq -e .venv -e workspace
  for p in "$HERE"/patches/*.patch; do
    [ -e "$p" ] && git -C "$METAGPT_HOME" apply --whitespace=nowarn "$p"
  done
  command -v uv >/dev/null || pip install --quiet uv
  [ -x "$VENV/bin/python" ] || uv venv --quiet --python 3.11 "$VENV"
  uv pip install --quiet --python "$VENV/bin/python" -e "$METAGPT_HOME" --override "$HERE/overrides.txt"
  rm -f "$VENV"/.texvector-installed-*
  touch "$STAMP"
fi

# Render ~/.metagpt/config2.yaml (outside the repo, so the key is never committed).
mkdir -p "$HOME/.metagpt"
KEY="${ANTHROPIC_API_KEY:-YOUR_API_KEY}"
sed -e "s|__ANTHROPIC_API_KEY__|$KEY|" -e "s|__METAGPT_CLAUDE_MODEL__|$MODEL|" \
  "$HERE/config2.claude.yaml" > "$HOME/.metagpt/config2.yaml"
chmod 600 "$HOME/.metagpt/config2.yaml"

echo "MetaGPT ready: $VENV/bin/metagpt (model: $MODEL)"
[ -n "${ANTHROPIC_API_KEY:-}" ] || echo "WARNING: ANTHROPIC_API_KEY is not set; add it to the environment, then re-run $0" >&2
