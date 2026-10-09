#!/bin/bash
# Cloud sessions: install MetaGPT (patched for Claude) and render ~/.metagpt/config2.yaml.
set -euo pipefail
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi
"$CLAUDE_PROJECT_DIR/tools/metagpt/setup.sh"
echo "export PATH=\"$CLAUDE_PROJECT_DIR/vendor/MetaGPT/.venv/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
