# Do you have access to Roblox MCP? — No

**Summary:** No. This cloud session has no Roblox MCP server (Roblox Studio MCP or any other Roblox tool) connected. I can't read or change the live game in Studio, run Luau in Studio, or play-test. All I can work from is the read-only snapshot Conductor exported to this repo. That's enough for code review, bug hunting and suggesting exact fixes, but someone has to apply changes in Studio by hand (or with a Studio-side tool).

## What I checked

- **Connected tools:** I searched the session's tool registry for anything Roblox- or Studio-related and found nothing. The only MCP servers connected are GitHub (scoped to `mrskips/pet-exploration-game`) and the Claude Code cloud-session tools.
- **Repo MCP config:** The repo has no `.mcp.json` and no project MCP settings, so nothing here would start a Roblox MCP server.
- **Environment:** This is an ephemeral Linux container in the cloud. Roblox Studio isn't installed and can't run here. The official Roblox Studio MCP server talks to a Studio instance running on the same machine, so it couldn't reach your Studio from here even if it were set up.

## What I *can* use in this session

| Source | Contents |
|---|---|
| `scripts/ServerScriptService/PetExpeditionServer.server.lua` | Server Script (snapshot) |
| `scripts/StarterPlayer/StarterPlayerScripts/ExpeditionVisuals.client.lua` | LocalScript (snapshot) |
| `game-outline.md` | Instance tree of `Place1`, depth-limited (1,831 lines) |
| `output-log.txt` | Recent Studio Output (5 lines) |
| `snapshot.json` | Copy taken 2026-10-11T18:38:38Z: 2 scripts, 157 lines |

Per `CLOUD.md`, this copy is read-only and nothing flows back into the game automatically. Any fix I suggest goes in a report as exact code with its file and line.

## Side note from the Output log

`output-log.txt` shows that the **Roblox Studio AI Assistant** is active in your Studio session:

```
[RobloxAI] Plugin loaded.  Click 'AI Assistant' in the Plugins toolbar to connect.
[Roblox][...AssistantUI.Actions.ExecuteLuauActions] The execute_luau changed camera type. Resetting from Enum.CameraType.Scriptable back to Enum.CameraType.Fixed
```

`execute_luau` is a Studio-side tool, so a Studio-connected assistant (the built-in Assistant, or a local Claude/MCP setup on your machine) *can* run code against your place. That access lives on your computer, not in this cloud session. These lines are informational, not errors in your game scripts.

## If you want live Studio access

1. **Run Claude Code locally**, on the machine where Studio runs, with the Roblox Studio MCP server set up (Roblox's official `studio-rust-mcp-server`, or the MCP option in Studio's Assistant settings), and add it with `claude mcp add`. A local session can then read and edit the place directly.
2. **Keep using cloud tasks like this one** for review and planning. Ask for a concrete job (for example "review PetExpeditionServer for exploits" or "why does the camera reset") and I'll return exact patches for you to apply in Studio.
