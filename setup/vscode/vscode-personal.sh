#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Vs Code Personal
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 😎
# @raycast.packageName Custom Scripts

# Launch VS Code with Personal profile
# This allows running a separate VS Code instance for personal projects
# with its own GitHub login and settings sync

# TODO right now personal is my default. maybe move to these folders in future:
#  --user-data-dir ~/Library/Application\ Support/Code-Personal \
#  --extensions-dir ~/.vscode-personal \

# passes in all arguments to the script so it can open folders from the command line.
"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
  --user-data-dir "$HOME/.vscode" \
  --extensions-dir "$HOME/.vscode/extensions" \
  "$@"