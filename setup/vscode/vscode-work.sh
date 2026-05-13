#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Vs Code Work
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🏢
# @raycast.packageName Custom Scripts

# Launch VS Code with Work profile
# This allows running a separate VS Code instance for work projects
# with its own GitHub login and settings sync

# passes in all arguments to the script so it can open folders from the command line.
"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
  --user-data-dir "$HOME/.vscode-work" \
  --extensions-dir "$HOME/.vscode-work/extensions" \
  "$@"