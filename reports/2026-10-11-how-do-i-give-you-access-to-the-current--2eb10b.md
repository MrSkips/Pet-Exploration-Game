# How to give a cloud session access to your Obsidian vault

**Summary:** I can't see your vault right now. This cloud session runs in a temporary container that holds only a fresh clone of `MrSkips/Pet-Exploration-Game`. It contains no `.obsidian` folder and no notes, and no Obsidian connector is attached. An Obsidian vault is a folder of Markdown files on your computer, so a cloud session can only reach it if that folder is on GitHub or exposed through a remote connector. **I recommend syncing the vault to a private GitHub repo with the Obsidian Git plugin, then starting sessions with that repo selected.**

---

## What I checked

- Repo contents: `CLOUD.md`, `game-outline.md`, `output-log.txt`, `scripts/`, `snapshot.json`, `tasks/`. There's no vault and no `.obsidian/` folder.
- Connected tools: there's no Obsidian or notes connector in this session.
- GitHub access for this session covers only `mrskips/pet-exploration-game`.

## Option 1 (recommended): put the vault on GitHub

1. **Create a private GitHub repo** for the vault, for example `MrSkips/obsidian-vault`.
2. **In Obsidian**, install the community plugin **Obsidian Git** (Settings → Community plugins → Browse → "Git"). Then either:
   - use the plugin's commands to set the remote to the new repo, or
   - from a terminal in the vault folder, run:
     ```bash
     git init
     git add .
     git commit -m "Initial vault"
     git branch -M main
     git remote add origin https://github.com/MrSkips/obsidian-vault.git
     git push -u origin main
     ```
   - Turn on the plugin's auto commit-and-sync (for example every 10 minutes) so the repo stays current.
   - Optional: add a `.gitignore` with `.obsidian/workspace*.json` and `.trash/` to skip noisy files.
3. **Give Claude access to the repo.** Go to https://claude.ai/connect-github and make sure the Claude GitHub App is installed on the new repo. If you installed the app for "selected repositories" only, add the vault repo to that list.
4. **Use it.** Start a new cloud session with both `Pet-Exploration-Game` and the vault repo selected. Or, once step 3 is done, ask me in a session to attach the vault repo and I can add it there.
5. **Write-back:** if you want me to edit notes, I'll commit to a branch in the vault repo. Obsidian Git then pulls those changes into your local vault on its next sync.

## Option 2: use a connector

Connectors are managed at https://claude.ai/customize/connectors and are read when a session starts. Most Obsidian MCP servers, such as those using the "Local REST API" plugin, run **on your own computer**. They work with Claude Desktop or Claude Code running locally, but a cloud container can't reach them. To use one here, you'd have to host it as a remote MCP server reachable over the internet, which is more work and more security exposure than Option 1.

## Option 3: run Claude Code locally in the vault

If you only need vault help occasionally, install Claude Code on your PC and run `claude` inside the vault folder. It reads and edits the notes directly, with no syncing.

## Option 4 (quick, one-off): paste or copy notes in

You can paste the relevant notes into the task, or put the files in this repo. Be careful with this repo: Conductor treats it as a read-only export of the Roblox game, and a future export may overwrite or ignore extra folders. Use a separate repo (Option 1) for anything you want to keep.

## Notes

- Keep the vault repo **private** if it holds personal notes.
- Nothing in `scripts/` or the game was touched for this task.
