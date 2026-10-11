# How to get images in front of Claude in a cloud session

**Short answer: yes.** Put the image files (PNG/JPG) into a folder in this GitHub repo, such as `images/`, commit and push them to `main`, and then name the paths in your task, e.g. "look at `images/mockups/common.png`". Each cloud session starts from a fresh clone of the repo, so I can open any image that is in the repo at that point and actually look at it.

Top points:
- **Commit the files to the repo before you start the task.** I only see what's in the clone. Files on your PC or in Roblox Studio don't reach me unless they're in git.
- **Name the exact files in the task text.** Then I don't have to guess which image you mean.
- **Roblox asset IDs (`rbxassetid://...`) don't work for me.** I see the ID text in scripts and `game-outline.md`, but I can't render it. Export or screenshot the image and commit the file.
- **Attaching an image straight to a chat message** in the Claude app also works when that option is available, but repo files are more reliable for Conductor tasks.

## Step by step

1. Make a folder at the repo root, outside `scripts/` (Conductor overwrites `scripts/` with every copy), e.g.:
   ```
   images/
     mockups/
       common.png
       rare.png
       epic.png
   ```
2. Commit and push to `main`, either with GitHub's web upload ("Add file → Upload files") or with git:
   ```bash
   git add images/
   git commit -m "Add pet mockup images"
   git push origin main
   ```
3. Create the Conductor task and name the files, e.g.:
   > Look at `images/mockups/common.png`, `rare.png` and `epic.png` and describe the differences between the tiers.

## What works best

| Topic | Recommendation |
|---|---|
| Formats | PNG or JPG (GIF/WebP usually work too). PDFs work. **Not** `.psd`, `.blend`, `.fbx` or `.rbxm`. I can't view those as pictures. |
| Size | Under about 5 MB and about 2000 px on the long side. Very large images get downscaled, so small details can get lost. |
| Naming | Use descriptive names with no spaces: `epic-dragon-front.png`, not `Screenshot 2026-10-11 at 3.12.png`. |
| Scale/measurements | If size matters (as in task 3012a9, "ensure they are to scale"), **write the real dimensions** in the task or in the image itself (e.g. "pet is 4×4×4 studs"). I can estimate proportions from a picture but can't reliably measure absolute size. |
| Multiple views | For 3D models, add front, side and top screenshots. One angle leaves me guessing about depth. |
| Studio screenshots | Fine to use. Crop to the relevant part and hide UI clutter if you can. |

## Things I can't do

- **See Roblox assets directly.** The outline lists `Decal`, `Texture` and `ImageLabel` instances (e.g. `game-outline.md` lines 480, 481, 588), but the copy only has their properties/IDs, not the pixels.
- **Look at your screen or Studio live.** I only see what's committed.
- **Get images back into Studio.** Anything I make (renders, edited images) goes into the repo/report, and you import it into Studio yourself (Asset Manager → Bulk Import).

## Relevant to your earlier mockup task (3012a9)

That task asked me to look at "Common, Rare and Epic Mockups", but no images were in the repo, so there was nothing to look at. To redo it, commit the mockups as above, e.g. `images/mockups/common.png`, `rare.png`, `epic.png`, plus the target size in studs, and point the new task at those paths.
