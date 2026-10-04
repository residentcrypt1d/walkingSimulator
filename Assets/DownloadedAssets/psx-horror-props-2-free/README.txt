PSX Horror Props II Free
========================

12 PS1-style horror props, taken from PSX Horror Props II (57 props, 20 animations):
https://heyheythere.itch.io/psx-horror-props-2
Low-poly, one 512x512 point-filtered texture atlas, the shading baked into vertex colours,
real-world scale (1 unit = 1 metre).

What's in the zip
-----------------
glb/        one file per prop, with its animations (the best format for Godot, Blender, three.js)
fbx/        one file per prop, with its animations as takes (Unreal, Unity, most 3D apps)
obj/        one file per prop, still (any 3D app)
textures/   atlas.png, the one texture every prop uses
icons/      an inventory icon per prop, 256x256 PNG with transparency
props.json  every prop: title, group, size, triangles, parts and animations
blender/    every prop in one .blend, the atlas packed in
addons/     the Godot addon, psx_horror_props_2/: this folder is a Godot 4.3+ project that opens
            on its gallery (.gdignore keeps Godot out of the other folders)

Godot 4.3 and later
-------------------
Copy addons/psx_horror_props_2/ into your project's addons/ folder. Each prop is a scene in
props/: drag it into your level. It has a box collider (StaticBody3D) on each of its parts, and
the moving parts' colliders move with them. A prop with animations has an AnimationPlayer:

    doll.get_node("AnimationPlayer").play("look")   # doll: the porcelain doll in your level

icons/ has the inventory icons. demo/gallery.tscn shows every prop: drag to turn, arrows to
browse, A for all of them at once.
The props use one material, props.tres: the atlas times the vertex colours, lit, so your lights
and flashlights fall on them. For the full PS1 look (vertex snap, affine textures, 240p, dither),
our PSX Look shaders turn them over in one line: https://heyheythere.itch.io/psx-look
With PSX Look in res://addons/psx_look/, the gallery shows the props through it (P toggles it).
PSX Horror Props II uses the same addon folder: it installs over this one.

Other engines and apps
----------------------
Use fbx/, glb/ or obj/ with textures/atlas.png. Set the texture's filtering to nearest/point and
turn off mipmaps for the crisp PS1 texels, and multiply it by the vertex colours (the baked
shading) in your material. Pivots sit on the floor, or on the wall for wall-mounted props.

Animations
----------
porcelain doll (look), grimoire (open) and gibbet (swing).

License: CC BY 4.0, see LICENSE.txt for the credit line. Made by heyheythere:
https://heyheythere.itch.io
