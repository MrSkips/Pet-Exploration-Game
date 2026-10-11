# Blender rebuild of the Common / Rare / Epic mockups: blocked, the mockups aren't in the copy

**Summary**

1. **The Common, Rare and Epic mockups are not in this cloud copy.** I searched `game-outline.md`, both scripts, `output-log.txt` and the whole git history for "Common", "Rare", "Epic", "Mockup", "Design" and image files, and found nothing. The only rarity-free pet art in the game is the code-built Frog/Mole in `PetExpeditionServer.server.lua`. So I could not build the designs or check their scale, and I did not invent stand-ins.
2. **Blender does work in cloud sessions.** Blender 5.2.2 LTS installs here as the `bpy` Python module (headless, so there's no GUI). It can build meshes from a script, measure them, and export FBX.
3. **I tested the stud-scale pipeline on the existing frog pet.** I rebuilt the baby and evolved Frog from the server script at 1 Blender unit = 1 stud and exported FBX. The measured sizes match the Lua part sizes exactly (table below). The same script is the starting point for the mockups once they are available.
4. **To unblock this, get the mockups into the copy** (see "What I need" below). Then a rerun of this task can build all three at the right scale.

---

## 1. Where I looked for the mockups

| Source | Result |
|---|---|
| `game-outline.md` (1,831 lines), case-insensitive search for `common`, `rare`, `epic`, `mockup` | No matches |
| `Workspace` children (outline lines 166–170) | `Camera`, `Baseplate`, `Terrain`, `SpawnLocation`, `PetExpeditionDemo` only |
| `Workspace.PetExpeditionDemo` (outline ~481–504) | Meadow, Island, River, Camp, Bug1–3, eggs/cache, trees. No pet models |
| `StudioDesign-4 [Folder]` (outline line 463) | This is Studio's own UI style data (plugin StyleSheets), not your art |
| `ReplicatedStorage` / `ServerStorage` | No children listed |
| Git history (all commits) | Only scripts, outline, log, snapshot and task files. No images, `.fbx`, `.obj` or `.blend` |

Most likely the mockups exist only as image files on your computer, or they sit somewhere in Studio that Conductor doesn't export (for example, an image in an uploaded asset, or a model deeper than the outline's depth limit). Conductor copies scripts and a depth-limited instance tree, but no image or mesh data. So even if the mockups are in Studio as Decals or ImageLabels, I would see only the instance names, not the pictures.

## 2. Blender in cloud sessions: verified

```
uv venv -p 3.13 venv
uv pip install bpy            # downloads Blender 5.2.2 LTS (~400 MB)
venv/bin/python -c "import bpy; print(bpy.app.version_string)"   # -> 5.2.2 LTS
```

Limits: there's no window, so I can't open a `.blend` interactively the way you would. I can open, edit, render and export `.blend` / `.fbx` / `.obj` / `.glb` from scripts. Per `CLOUD.md`, only this report gets committed, so finished models have to come back as a script in a report (below), or you can allow a later task to commit the model files.

## 3. Scale reference: the current in-game pet, rebuilt in Blender

These are the sizes the new pets have to "fit with". They come from `creature()` in `scripts/ServerScriptService/PetExpeditionServer.server.lua` (lines 21–43). The pet follows the player at `root.CFrame * CFrame.new(3,-1.8,3)` (line 116).

| Model | Bounding box in studs (X × Y × Z), measured in Blender | Expected from Lua |
|---|---|---|
| Baby Frog / Mole body block | 2.4 × 2.15 × 2.18 | body 2.4 × 1.6 × 2; eyes reach Y +1.35; legs reach Y −0.8 ✔ |
| Evolved Frog (`scale = 1.5` + crown) | 3.6 × 3.7 × 3.26 | ✔ |
| Default R15 character, for comparison | ≈ 4 wide × 5 tall | — |

That gives a good default size ladder, if the mockups don't state their own sizes:

| Rarity | Suggested max height | Notes |
|---|---|---|
| Common | ~2.2 studs | Same as today's baby pet |
| Rare | ~2.8 studs | |
| Epic | ~3.7 studs | Same as today's evolved frog. Any bigger and it clips the player at the 3,-1.8,3 follow offset |

If the mockups come with their own dimensions or a reference object (like a character silhouette), I'll scale to those instead.

## 4. Build script (works now; mockup shapes go in `build()`)

Run with `venv/bin/python build_pet.py -- out.fbx`. It's tested here: it produced the measurements in section 3.

```python
# 1 Blender unit = 1 Roblox stud. Roblox (X, Y up, Z back) -> Blender (X, -Z, Y up).
import bpy, sys
from mathutils import Vector
bpy.ops.wm.read_factory_settings(use_empty=True)
def rgb(r,g,b): return (r/255,g/255,b/255,1)
def part(name,size,off,col):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(off[0],-off[2],off[1]))
    o=bpy.context.object; o.name=name; o.scale=(size[0],size[2],size[1])
    m=bpy.data.materials.new(name+'Mat'); m.diffuse_color=col; o.data.materials.append(m)
    return o
def frog(evolved, x0):            # replace with build_common / build_rare / build_epic
    s=1.5 if evolved else 1; c=rgb(93,195,98); o=Vector((x0,0,0))
    part('Body',(2.4*s,1.6*s,2*s),o,c)
    for x in (-.8,.8):
        part('Eye',(.7*s,)*3,o+Vector((x,1,-.7))*s,rgb(233,243,212))
        part('Pupil',(.3*s,.35*s,.15*s),o+Vector((x,1,-1.1))*s,rgb(22,33,28))
        part('Leg',(.8*s,.4*s,1.3*s),o+Vector((x,-.6,.2))*s,c)
    if evolved:
        part('Crown',(2.7,.5,1),o+Vector((0,1.5,.4)),rgb(252,205,87))
        part('Spike',(.5,1,.5),o+Vector((0,2,.4)),rgb(252,205,87))
frog(False,0); frog(True,6)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
def bounds(objs):
    pts=[o.matrix_world@Vector(c) for o in objs for c in o.bound_box]
    lo=Vector(map(min,*pts)); hi=Vector(map(max,*pts)); d=hi-lo
    return (round(d.x,2),round(d.z,2),round(d.y,2))  # reported as Roblox X,Y,Z
print('baby studs', bounds([o for o in bpy.data.objects if o.location.x<3]))
print('evolved studs', bounds([o for o in bpy.data.objects if o.location.x>3]))
bpy.ops.export_scene.fbx(filepath=sys.argv[-1], apply_unit_scale=True, axis_forward='-Z', axis_up='Y')
```

**Importing into Studio at the right size:** in the 3D Importer, check the file's unit/scale setting. Because the model is authored at 1 unit = 1 stud, the imported MeshPart's `Size` should read exactly the bounding box above (e.g. 2.4 × 2.15 × 2.18). If it comes in about 3.57× too big or too small, the importer has applied a metres↔studs conversion. Change the importer's unit setting (or the FBX export scale) and don't resize by hand, so all three rarities stay consistent.

## 5. What I need to finish the task

Any one of these works:

1. **Images in the repo (best option).** Add the three mockups as `mockups/common.png`, `mockups/rare.png`, `mockups/epic.png`, or put them in the task file, and rerun the task. If you can, show front and side views, and note intended sizes (or include a character next to the pet for scale).
2. **Models in Studio.** Put the mockup models directly under `Workspace` (or a shallow `Workspace.Mockups` folder) and give each part a descriptive name, so the outline shows them. Note that the outline won't include colours or shapes in detail, so images are still much better.
3. **Text description.** Tell me in the task the shape, colours, features and target height in studs for each rarity.

Once I have them, the next run will build all three in Blender with the script above, check each bounding box against the size ladder in section 3, and put the exact build script and measured sizes in the report.

## 6. Unrelated observations

None that need action. `output-log.txt` shows only the "Pet expedition demo ready" print and AI-Assistant camera-type notices, with no script errors.
