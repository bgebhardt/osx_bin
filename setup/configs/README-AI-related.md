
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

# Links to check out

- [Obsidian knowledgebase + MCP (Claude desktop) : r/ObsidianMD](https://www.reddit.com/r/ObsidianMD/comments/1jwqxeq/obsidian_knowledgebase_mcp_claude_desktop/?%24deep_link=true&correlation_id=d85b4a22-dd0b-4b68-95e5-1c1b2caf4ee1&post_fullname=t3_1jwqxeq&post_index=0&ref=email_digest&ref_campaign=email_digest&ref_source=email&utm_content=post_body&%243p=e_as&_branch_match_id=1401734709184875854&utm_medium=Email%20Amazon%20SES&_branch_referrer=H4sIAAAAAAAAA22Q3U7DMAyFn6a767am7TSQKoQ0uEM8gpXEXheWvyWpOm54dlw2uEJKpJPv%2BMSWT6XE%2FLjZJEI0ZS1jXFvjz5s2PlWia%2BNAIPOKZUhmNF5amJIdTkuqap8r8cpnnuf1Pa%2BDY5D4vqts0Ej%2FduAHY0e%2BZJbNx3y50oVVuFfA2YfZEo6kZCZwOoK2ckICpHwuIS5dWm7Uiw6JIiwDVu2hpIkqsdMhJbKymODBIHPc96qTQtSIW1V3arevH3rq60Y3Smh57IgazsWQCxwna710tHzXwt9sN9N4pCs7WwaJjqzISWMBzUi53CBo6aI0o%2F%2FfzWFKmn49hlNxoIMvvA2mP21UwM%2FVF1dTSsaPoFKYM6XhhTfyDbJCj5ufAQAA)
- [Introduction - Model Context Protocol](https://modelcontextprotocol.io/introduction)

MCP Server directories

- Smithery where you can find MCP servers
  - [Smithery - Model Context Protocol Registry](https://smithery.ai/)
  - [Introduction | Smithery Documentation](https://smithery.ai/docs)
- [MCP Servers](https://mcp.so/servers)
- [punkpeye/awesome-mcp-servers: A collection of MCP servers.](https://github.com/punkpeye/awesome-mcp-servers)
- [modelcontextprotocol/servers: Model Context Protocol Servers](https://github.com/modelcontextprotocol/servers)

MCP models to try out with Claude

- [Obsidian Reader | Smithery](https://smithery.ai/server/mcp-obsidian)
- [Fetch MCP Server | Smithery](https://smithery.ai/server/fetch-mcp)
- [servers/src/brave-search at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/brave-search)
- [servers/src/sqlite at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/sqlite)
- [servers/src/puppeteer at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/puppeteer)
- [servers/src/fetch at main · modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch)
- [browserbase/mcp-server-browserbase: Allow LLMs to control a browser with Browserbase and Stagehand](https://github.com/browserbase/mcp-server-browserbase)
- [g0t4/mcp-server-commands: Model Context Protocol server to run commands](https://github.com/g0t4/mcp-server-commands?tab=readme-ov-file)
- [(3817) Claude is Awesome with MCP Tools - YouTube](https://www.youtube.com/watch?v=0-VPu1Pc18w)
- [(3817) Let Claude Browse the Web with MCP Fetch Server - YouTube](https://www.youtube.com/watch?v=7HhlBuz2VgI)


- [Claude Desktop API Integration via MCP MCP Server](https://mcp.so/server/Claude_Desktop_API_USE_VIA_MCP/mlobo2012)
- [Supercharge Your Claude Desktop Experience: How MCP Servers Create a Claude Code-Like Environment | by Ravi Kiran Vemula | Feb, 2025 | Medium](https://medium.com/@vrknetha/supercharge-your-claude-desktop-experience-how-mcp-servers-create-a-claude-code-like-environment-7e984c802107)

# Set up local Ollama and MCP servers

Use [mark3labs/mcphost: A CLI host application that enables Large Language Models (LLMs) to interact with external tools through the Model Context Protocol (MCP).](https://github.com/mark3labs/mcphost)

Setup
- run `go install github.com/mark3labs/mcphost@latest`

It installs in $USER/go/bin

I run it from `~/go/bin/mcphost -m ollama:llama3.2`
Gets MCP servers from ~/.mcp.json

Setup video: [MCP server using Ollama for local LLMs - YouTube](https://www.youtube.com/watch?v=z0DScLrix48&list=WL&index=2)

[Model Context Protocol (MCP) using Ollama | by Mehul Gupta | Data Science in Your Pocket | Mar, 2025 | Medium](https://medium.com/data-science-in-your-pocket/model-context-protocol-mcp-using-ollama-e719b2d9fd7a)

Ollama set up
[Learn Ollama in 15 Minutes - Run LLM Models Locally for FREE - YouTube](https://www.youtube.com/watch?v=UtSSMs6ObqY&t=5s)
