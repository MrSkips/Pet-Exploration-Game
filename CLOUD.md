# Cloud copy of a Roblox game

This repository is a **read-only copy** of a Roblox game, exported from Roblox Studio by Conductor.
The real game lives in Studio. Nothing here is copied back into the game automatically.

- `scripts/` mirrors the game's scripts: `*.server.lua` = Script, `*.client.lua` = LocalScript, `*.lua` = ModuleScript.
  The first line of each file is its class and full path in the game (e.g. `game.ServerScriptService.Shop`).
- `game-outline.md` is the instance tree (folders, models, parts, UI), depth-limited.
- `output-log.txt` is the recent Studio Output log (errors and warnings are useful for bug hunting).
- `snapshot.json` says when the copy was made.
- `tasks/` holds task files written by Conductor. Each one names the report file to write.

## Rules for cloud sessions

1. Do the task in the task file you were pointed at. Read `CLOUD.md` (this file) first.
2. **Never edit anything under `scripts/`** and never change the game. Suggest fixes inside the report instead,
   as exact code with the file and line they belong to.
3. Write the report as Markdown at exactly the path the task file names (under `reports/`).
4. Commit only the report file and push your branch. That's how the report gets back to the developer.
5. Be concrete: file paths, line numbers, why it matters, and how to fix it. Lead with the most important findings.
