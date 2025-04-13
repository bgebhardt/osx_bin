
# Claude Desktop

My notes on Claude Desktop and the MCP servers that you can use.


# MCP info and servers

[Introduction - Model Context Protocol](https://modelcontextprotocol.io/introduction)
[Example Servers - Model Context Protocol](https://modelcontextprotocol.io/examples)

Look for servers at

- [Smithery - Model Context Protocol Registry](https://smithery.ai/)
- [modelcontextprotocol/servers: Model Context Protocol Servers](https://github.com/modelcontextprotocol/servers)
- [punkpeye/awesome-mcp-servers: A collection of MCP servers.](https://github.com/punkpeye/awesome-mcp-servers)

## Top servers to try

[Fetch web pages... servers/src/fetch/README.md at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/blob/main/src/fetch/README.md)
[servers/src/brave-search at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/brave-search)

[servers/src/google-maps/README.md at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/blob/main/src/google-maps/README.md)
[smithery-ai/mcp-obsidian: A connector for Claude Desktop to read and search an Obsidian vault.](https://github.com/smithery-ai/mcp-obsidian)
[servers/src/memory at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)
[Timezone conversion services - servers/src/time at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/time)

[servers/src/everart at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/everart)
[servers/src/slack at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/slack)


## More servers to check out.. maybe
[basicmachines-co/basic-memory: Basic Memory is a knowledge management system that allows you to build a persistent semantic graph from conversations with AI assistants. All knowledge is stored in standard Markdown files on your computer, giving you full control and ownership of your data. Integrates directly with Obsidan.md](https://github.com/basicmachines-co/basic-memory)

[servers/src/gdrive at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/gdrive)

[GongRzhe/Gmail-MCP-Server: A Model Context Protocol (MCP) server for Gmail integration in Claude Desktop with auto authentication support. This server enables AI assistants to manage Gmail through natural language interactions.](https://github.com/GongRzhe/Gmail-MCP-Server)


# My Set up

Set up my DnD Obsidian vault to be seen by Claude App

{
  "mcpServers": {
    "mcp-obsidian": {
      "command": "npx",
      "args": [
        "-y",
        "@smithery/cli@latest",
        "run",
        "mcp-obsidian",
        "--config",
        "\"{\\\"vaultPath\\\":\\\"/Users/bryan/OneDrive/Obsidian/DnD\\\"}\""
      ]
    }
  }
}

# Current MCP config for Claud Desktop App

{
    "mcpServers": {
      "filesystem": {
        "command": "npx",
        "args": [
          "-y",
          "@modelcontextprotocol/server-filesystem",
          "/Users/bryan/Desktop",
          "/Users/bryan/Downloads",
          "/Users/bryan/Library/CloudStorage/OneDrive-Personal/Obsidian/DnD",
          "/Users/bryan/Library/CloudStorage/OneDrive-Personal/Obsidian/Personal"
        ]
      },
      "memory": {
        "command": "npx",
        "args": [
          "-y",
          "@modelcontextprotocol/server-memory"
        ]
      },
      "mcp-obsidian": {
        "command": "npx",
        "args": [
            "-y",
            "@smithery/cli@latest",
            "run",
            "mcp-obsidian",
            "--config",
            "\"{\\\"vaultPath\\\":\\\"/Users/bryan/Library/CloudStorage/OneDrive-Personal/Obsidian/DnD\\\"}\""
        ]
      }
    }
}

# Other AI tools to check out

[Claude Code overview - Anthropic](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview)

