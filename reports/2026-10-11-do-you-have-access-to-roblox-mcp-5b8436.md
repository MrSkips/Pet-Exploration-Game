# No, this cloud session can't reach a Roblox MCP

**Summary:** This cloud session has no Roblox Studio MCP server and no other Roblox tool. It runs in a remote container, and the only MCP servers connected to it are GitHub (scoped to this repository) and Claude Code Remote session management. A tool search for "roblox" and "roblox studio" found nothing, and the repository has no `.mcp.json`. So I can't read the live place, run Luau or change anything in Studio from here. I can only work with the read-only copy that Conductor exported into this repo.

## What I checked

| Check | Result |
|---|---|
| Deferred or MCP tool search for `roblox` and `roblox studio` | No matches |
| Connected MCP servers | `github` (only `mrskips/pet-exploration-game`) and `claude-code-remote`. Neither one talks to Studio. |
| Project MCP config (`.mcp.json`) | Not present |
| Network position | Cloud container behind an egress proxy. A Studio MCP server normally runs on *your* machine next to Studio, so this container couldn't reach it even if one were configured. |

## What I *can* see (the Conductor snapshot)

- `snapshot.json`: place `Place1`, copied 2026-10-11T18:39Z, with 2 scripts and 157 lines.
- `scripts/ServerScriptService/PetExpeditionServer.server.lua` (122 lines) and `scripts/StarterPlayer/StarterPlayerScripts/ExpeditionVisuals.client.lua` (37 lines).
- `game-outline.md`: the instance tree (1,831 lines).
- `output-log.txt`: Studio output. It shows Roblox's built-in **Assistant** plugin running `execute_luau` actions, plus a third-party `[RobloxAI]` plugin waiting for you to click "AI Assistant" to connect. These are Studio-side AI integrations on your machine. They aren't exposed to this cloud session.

## How to get live Studio access, if you want it

1. **Run Claude Code locally**, not in a cloud session, on the same machine as Roblox Studio. Then add a Roblox Studio MCP server, such as Roblox's official `studio-rust-mcp-server` or the plugin you already have. For example:
   `claude mcp add --transport stdio roblox-studio -- <path-to-mcp-server-binary> --stdio`
   Then enable the matching Studio plugin. That local session could read and edit the place directly.
2. **Keep using this cloud workflow** for reviews and bug hunts. Re-export with Conductor before each task so the snapshot is current. I'll keep writing fixes as exact code with file and line numbers in reports. Per `CLOUD.md`, nothing under `scripts/` is edited here.

## Next step

If you want me to review the expedition scripts for bugs, or answer questions about the game, send that as a task. The exported copy has enough for that.
