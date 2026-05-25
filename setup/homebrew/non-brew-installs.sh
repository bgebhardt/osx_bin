#!/usr/bin/env bash


# A file for colleccting apps that are not available via brew or the app store, but I want to install. This is more of a scratch pad for now, and will likely be moved to a more permanent location later.

# ai coding tools
#npm install -g @anthropic-ai/claude-code # Command-line interface for Claude AI
# use the official Claude Code installer
echo "Installing the official Claude AI desktop app..."
curl -fsSL https://claude.ai/install.sh | bash
echo "Claude AI desktop app installation complete."


# AI model serving and interactions

# [LLM: A CLI utility and Python library for interacting with Large Language Models](https://llm.datasette.io/en/stable/index.html)
pipx install llm
pipx install mlx-lm # MLX-LM is a Python library for running LLMs on macOS using the MLX framework; it provides a Python interface to the MLX framework, allowing you to run LLMs on macOS with ease.
# [Run LLMs on macOS using llm-mlx and Apple’s MLX framework](https://simonwillison.net/2025/Feb/15/llm-mlx/)
llm install llm-mlx # Install the llm-mlx model for use with the llm CLI utility; this workes with mlx-lm and llm
llm install llm-gpt4all # providing 17 models from the GPT4All project [Other models - LLM](https://llm.datasette.io/en/stable/other-models.html)

# [mlx-lm·PyPI](https://pypi.org/project/mlx-lm/)


# disabled
# brew install fabric-ai # Command-line tool for managing and deploying AI prompts [danielmiessler/Fabric: Fabric is an open-source framework for augmenting humans using AI. It provides a modular system for solving specific problems using a crowdsourced set of AI prompts that can be used anywhere.](https://github.com/danielmiessler/Fabric/tree/main)

# # install Fabric helper apps for fabric-ai
# go install github.com/danielmiessler/fabric/cmd/to_pdf@latest # to_pdf - Convert text files to PDF using AI formatting
# go install github.com/danielmiessler/fabric/cmd/code2context@latest # code2context - Generate context for code snippets using AI
# go install github.com/danielmiessler/fabric/cmd/generate_changelog@latest # generate_changelog - Generate changelogs for git repositories using AI
