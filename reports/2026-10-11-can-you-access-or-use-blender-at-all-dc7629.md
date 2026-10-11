# Can you access or use Blender at all? Yes, headless, but not inside your Studio

**Short answer:** Yes. Blender isn't preinstalled in the cloud session, but Blender's official Python build (`bpy` 5.2.2 LTS, from PyPI) installed in about a minute. I used it with no screen to build a test pet mesh, export it to **FBX, OBJ and GLB**, and render a preview PNG with Cycles on the CPU. All of these worked.

**Limits:**
- I can't open Blender's GUI.
- I can't reach your Roblox Studio or upload assets to Roblox. There's no Open Cloud API key here, and CLOUD.md says this repo is a read-only copy.
- The cloud container is temporary. Anything I make only survives if it's committed, and the rules for this task allow committing only this report.

So in practice I can **write Blender scripts and generate model files**. You then import them into Studio (Avatar/3D Importer, or `File > Import 3D`).

## What I verified (2026-10-11, this session)

| Check | Result |
|---|---|
| `blender` binary on PATH | Not installed |
| `pip install bpy` (Python 3.13 venv) | Works. `bpy.app.version_string` → `5.2.2 LTS` |
| Build mesh by script (sphere body + cone ears, material, join) | Works |
| `bpy.ops.export_scene.fbx` | Works, `pet.fbx` 36 KB |
| `bpy.ops.wm.obj_export` | Works, `pet.obj` + `.mtl` |
| `bpy.ops.export_scene.gltf` (GLB) | Works. Draco/meshopt compression libs are missing, but plain GLB is fine |
| Cycles render (CPU, 256×256, 8 samples) | Works in ~1.4 s, so I can look at a preview of what I model |
| GPU / Eevee / interactive viewport | Not available (no display or GPU) |

## Where Blender would actually help this game

Right now every pet is built from plain blocks at runtime:

- `scripts/ServerScriptService/PetExpeditionServer.server.lua:21-43`: `creature()` builds the Frog and Mole from 7 to 10 anchored `Part`s each (body, eyes, pupils, feet, a snout for the mole, and a crown for the evolved frog).
- `scripts/StarterPlayer/StarterPlayerScripts/ExpeditionVisuals.client.lua:24`: the carried mole egg is a `Ball` Part.

These are the natural candidates for Blender-made `MeshPart`s: a rounded frog, a mole, an evolved-frog variant, and an egg. One MeshPart per pet would also replace 7 to 10 Parts that `PivotTo` moves every 0.05 s (`PetExpeditionServer.server.lua:110`).

## Suggested workflow

1. In a future task, ask me for something like "make a low-poly frog, evolved frog and mole in Blender." I'll write the `bpy` script, render previews to check them, and (if you allow committing beyond the report) commit the `.fbx` files plus the script under e.g. `assets/models/`.
2. Import the FBX in Studio with the 3D Importer. It creates a `MeshPart` with a `MeshId`. Store it as a template, e.g. `ServerStorage.PetModels.Frog`.
3. Change `creature()` to clone the template instead of building Parts. Fit this to your template names. It would replace lines 24-41 of `PetExpeditionServer.server.lua`:

```lua
local templates = game:GetService('ServerStorage'):WaitForChild('PetModels')
local function creature(player, kind)
 local s = states[player]
 if s.pet then s.pet:Destroy() end
 local name = (kind == 'Frog' and s.evolved) and 'FrogEvolved' or kind
 local m = templates[name]:Clone(); m.Name = player.Name..'_'..kind
 for _, p in ipairs(m:GetDescendants()) do
  if p:IsA('BasePart') then p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false end
 end
 m.Parent=world; s.pet=m
end
```

(Each template needs `PrimaryPart` set, because line 110 uses `PivotTo`.)

### Running it yourself instead

The same script runs in your own desktop Blender with `blender --background --python make_pet.py`. Here is the minimal script I tested:

```python
import bpy
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.mesh.primitive_uv_sphere_add(radius=1, location=(0,0,1)); body = bpy.context.object
bpy.ops.object.shade_smooth()
for x in (-0.4, 0.4):
    bpy.ops.mesh.primitive_cone_add(radius1=0.25, depth=0.5, location=(x,0,2))
bpy.ops.object.select_all(action='SELECT'); bpy.context.view_layer.objects.active = body
bpy.ops.object.join()
bpy.ops.export_scene.fbx(filepath="pet.fbx", apply_scale_options='FBX_SCALE_UNITS')
```

## Caveats

- **Roblox mesh limits:** each MeshPart is capped at 20,000 triangles, and a low-poly look suits this game anyway. Roblox uses Y-up and Blender uses Z-up; the FBX exporter handles the axis change, but check the orientation after import.
- **Colors:** use one vertex-colour or texture setup per mesh. If several plain Blender materials are combined into one MeshPart, the separate colours don't carry over, so either bake a texture or keep separate parts for the eyes.
- **Rigs:** skinned or animated meshes can be exported (FBX with an armature), but setting up rigs and animations is better tested in Studio by you.
- **Can't do from here:** upload to Roblox, get asset IDs, or place anything in the live game.
