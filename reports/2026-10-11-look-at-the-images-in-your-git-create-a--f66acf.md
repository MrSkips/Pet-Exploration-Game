# Blender masterprompt for the mockup images: blocked because no images are in the repo yet. The prompt and the scene script are ready.

**Summary**

1. **There are no images in this git repo.** Not on `main`, not on any of the 6 remote branches, and not anywhere in the commit history. I checked every file ever committed for `.png/.jpg/.jpeg/.webp/.gif/.bmp/.svg/.blend` and found none. So I can't look at the images or describe them 1:1 yet, and I didn't invent any.
2. **The likely cause:** the upload didn't reach GitHub `main` (`mrskips/pet-exploration-game`). Either it wasn't pushed, it went to a different repo or branch, or it was added after this copy was made (2026-10-11 18:58 UTC). Section 1 below has the fix.
3. **The masterprompt is ready to use (section 2).** It's a fill-in template. Once the images are committed, a rerun fills it in per image with exact proportions, colors, parts and sizes in studs.
4. **The "new folder in Blender for the renders" is ready as a script (section 3).** It's tested here with Blender 5.2.2 LTS. It creates a `Mockup_Renders` collection (with `References`, `Models` and `Cameras` sub-folders), loads each image as a to-scale tracing reference, adds an orthographic camera that frames it 1:1, and sets a `renders/` output folder next to the `.blend`.
5. **One limit:** I can't create anything inside *your* Blender install. Cloud sessions run Blender headless in a throwaway container, and per `CLOUD.md` only this report gets committed. You run the script once on your PC (1 command, section 3), and it builds the folder structure for you.

---

## 1. Where I looked, and how to get the images in

| Checked | Result |
|---|---|
| Working tree on `claude/task-f66acf-sb3eqx` (= `main` at `c41c9fd`) | `CLOUD.md`, `game-outline.md`, `output-log.txt`, `snapshot.json`, `scripts/`, `tasks/`. No images |
| All remote branches (`main` + 5 earlier `claude/*` branches) | Only reports and copy files. No images |
| Every file in every commit (`git log --all`) | No image or `.blend` files ever committed |
| `game-outline.md` | Only Roblox `Decal` / `Texture` / `ImageLabel` instances (lines 480, 481, 588), with asset IDs and no pixels |

**To fix it** (same as the earlier report for task 3e3c49):

1. On github.com → `mrskips/pet-exploration-game` → **Add file → Upload files**, drop the images into a folder like `images/mockups/` (type `images/mockups/` in front of the file names, or upload into that folder). Commit to **`main`**.
2. Name the files clearly, one view per file if you can: `common-front.png`, `common-side.png`, `rare-front.png`, …
3. **Give the real sizes.** "To scale" needs at least one known measurement per image, e.g. "Common pet is 2.2 studs tall". If you don't have one, the scale ladder from task 3012a9 works as a default: Common ≈ 2.2, Rare ≈ 2.8, Epic ≈ 3.7 studs tall (the current baby Frog is 2.4 × 2.15 × 2.18 studs, from `creature()` in `scripts/ServerScriptService/PetExpeditionServer.server.lua` lines 21–43).
4. Start a **new** Conductor task *after* the push, e.g. "Use the masterprompt from report f66acf on `images/mockups/*.png`". Each task copies the repo at the moment it starts.

## 2. The masterprompt

Copy this into a task (Conductor/Claude) or use it yourself as a checklist. The `{…}` fields are what I (or you) fill in from each image.

```text
ROLE: You are a 3D modeler rebuilding a 2D game mockup in Blender as an exact,
to-scale, low-poly Roblox-ready model.

INPUT
- Reference image(s): {images/mockups/NAME-front.png, NAME-side.png, NAME-top.png}
- Pet / object name: {NAME}            Rarity tier: {Common | Rare | Epic}
- Real size: {HEIGHT} studs tall (1 Blender unit = 1 Roblox stud, Z-up)
  If only one view exists, assume depth = {DEPTH_RULE, e.g. 0.9 × width}.

STEP 1: MEASURE (write these down before modeling)
- Pixel bounding box of the subject in each view -> px-per-stud = px_height / HEIGHT.
- For every visible part (body, head, eyes, pupils, ears, legs, tail, wings,
  horns, accessories): shape (box / sphere / cylinder / wedge / custom),
  centre position and size in studs, rotation in degrees.
- Colours: sample each flat colour as hex + RGB; note gradients, outlines,
  emissive/glow parts and transparency.
- Style: {blocky Roblox parts | smooth stylised | voxel}; outline thickness;
  bevel radius in studs.

STEP 2: BUILD
- Run setup_mockup_scene.py first so the references sit at true size.
- Model every part inside collection Mockup_Renders/Models/{NAME}, named
  {NAME}_{Part}. Origin at the bottom centre of the model, feet on Z = 0,
  facing -Y (toward the front camera).
- Use the measured sizes exactly; match the silhouette against the reference in
  each orthographic camera until the outline overlaps within 1 px at 100 %.
- One material per flat colour, named {NAME}_{hex}; Principled BSDF, roughness
  0.6, no textures unless the image clearly shows one.
- Keep it under {POLY_BUDGET, e.g. 2 000} triangles; apply scale (Ctrl+A).

STEP 3: VERIFY
- Print the bounding box (X × Y × Z studs) and compare with the target height;
  difference must be < 0.05 studs.
- Render each CAM_ camera at the reference image's resolution with transparent
  background into //renders/{NAME}/{view}.png and compare side by side.

STEP 4: OUTPUT
- Save {NAME}.blend; export {NAME}.fbx (scale 1.0, +Y up, apply transforms)
  for Roblox import (Avatar/3D Importer, it keeps 1 unit = 1 stud).
- Report: part list with sizes, colour table, bounding box, any guesses made
  where the image was ambiguous.
```

## 3. The Blender "folder" for the renders: setup script

Save as `setup_mockup_scene.py` and run it from a terminal (Blender 3.6+, tested on 5.2.2 LTS):

```bash
blender -b -P setup_mockup_scene.py -- MockupRenders/mockups.blend \
  images/mockups/common-front.png:front:2.2 \
  images/mockups/rare-front.png:front:2.8 \
  images/mockups/epic-front.png:front:3.7
```

Each argument is `image:view:height_in_studs` (view = `front`, `side` or `top`). It creates:

```
Scene Collection
└── Mockup_Renders            <- the new folder
    ├── References            REF_<image>: image at true size, bottom on the ground, 50 % opacity
    ├── Models                (empty: model the pets here)
    └── Cameras               CAM_<image>: orthographic, framed 1:1 to that image
MockupRenders/renders/        <- render output folder (scene output = //renders/)
```

```python
# setup_mockup_scene.py: builds a 1:1, to-scale Blender scene from mockup images.
# 1 Blender unit = 1 Roblox stud. Blender is Z-up; the front view looks along +Y.
#
# Run:  blender -b -P setup_mockup_scene.py -- <out.blend> <spec> [<spec> ...]
#   spec = path/to/image.png:VIEW:HEIGHT_STUDS     VIEW = front | side | top
#   e.g. images/mockups/common-front.png:front:2.2
import bpy, os, sys

argv = sys.argv[sys.argv.index("--") + 1:]
out_blend, specs = os.path.abspath(argv[0]), argv[1:]

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.unit_settings.system = 'METRIC'
scene.unit_settings.scale_length = 1.0          # 1 BU = 1 stud
scene.render.engine = 'BLENDER_EEVEE'
scene.render.film_transparent = True

def collection(name, parent):
    c = bpy.data.collections.new(name)
    parent.children.link(c)
    return c

root = collection("Mockup_Renders", scene.collection)    # the new "folder"
refs = collection("References", root)
models = collection("Models", root)
cams = collection("Cameras", root)

# Each view: (image-empty rotation, camera location direction, camera rotation)
VIEWS = {
    "front": ((1.5708, 0, 0),      (0, -1, 0), (1.5708, 0, 0)),
    "side":  ((1.5708, 0, 1.5708), (1, 0, 0),  (1.5708, 0, 1.5708)),
    "top":   ((0, 0, 0),           (0, 0, 1),  (0, 0, 0)),
}

for spec in specs:
    path, view, height = spec.rsplit(":", 2)
    height = float(height)
    name = os.path.splitext(os.path.basename(path))[0]
    img = bpy.data.images.load(os.path.abspath(path))
    w, h = img.size
    width = height * w / h                     # keep the image's aspect ratio

    rot, cam_dir, cam_rot = VIEWS[view]
    ref = bpy.data.objects.new(f"REF_{name}", None)
    ref.empty_display_type = 'IMAGE'
    ref.data = img
    ref.empty_display_size = max(width, height)   # longest side = real size
    ref.empty_image_offset = (-0.5, 0.0)          # bottom edge sits on the ground (Z=0)
    ref.rotation_euler = rot
    ref.show_in_front = False
    ref.color[3] = 0.5                            # 50 % opacity for tracing
    ref.use_empty_image_alpha = True
    refs.objects.link(ref)

    cam_data = bpy.data.cameras.new(f"CAM_{name}")
    cam_data.type = 'ORTHO'
    cam_data.ortho_scale = max(width, height)    # frames the image 1:1
    cam = bpy.data.objects.new(f"CAM_{name}", cam_data)
    d = 20
    cam.location = (cam_dir[0] * d, cam_dir[1] * d, cam_dir[2] * d + (0 if view == "top" else height / 2))
    cam.rotation_euler = cam_rot
    cams.objects.link(cam)
    cam["render_size"] = (w, h)

# Render output goes in a folder next to the .blend file
scene.render.filepath = "//renders/"
os.makedirs(os.path.join(os.path.dirname(out_blend), "renders"), exist_ok=True)
if cams.objects:
    first = cams.objects[0]
    scene.camera = first
    scene.render.resolution_x, scene.render.resolution_y = first["render_size"]
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
print("Saved", out_blend, "with", len(specs), "reference(s)")
```

**Test run here** (two placeholder images, 800×600 front and 600×600 side, both 2.2 studs tall): the `.blend` and `renders/` folder were created, the references landed in `Mockup_Renders/References`, and the cameras in `Mockup_Renders/Cameras` at `(0, −20, 1.1)` and `(20, 0, 1.1)`, centred on the 2.2-stud subject. A test render couldn't run in the container because it has no GPU/EGL (`libEGL.so.1` missing). That's an environment limit only; rendering works in desktop Blender (F12, or `blender -b mockups.blend -f 1`).

To switch which image renders, set the scene camera to that image's `CAM_` object (Scene properties → Camera) and set the output resolution to the image's pixel size.

## 4. Next step

Push the images to `images/mockups/` on `main`, with a height in studs for each (or accept the 2.2 / 2.8 / 3.7 default). Then start a new task like *"Fill in the f66acf masterprompt for every image in `images/mockups/` and build the models in Blender"*. That run can measure the images, fill in every `{…}` field, build the models at 1 stud = 1 unit, and report part sizes and colours. If you also allow it to commit files outside `reports/`, it can push the `.blend`/`.fbx` too.
