PSX Textures Free
=================

16 PS1-style textures for retro 3D levels, taken from PSX Textures (138 textures):
https://heyheythere.itch.io/psx-textures
Each is a 16-colour indexed PNG, ordered-dithered like the PS1's 4-bit textures, at 128 pixels to
the metre, and again at 64 for the crunchier look. Walls, floors and ceilings tile seamlessly both
ways, the wainscot sideways; the door, sign and blood splatter don't tile, and the splatter has
on-or-off transparency.

What's in the zip
-----------------
textures/128/  every texture by category, 128 px a metre: most are 128x128, the door 128x256,
               the sign 128x32
textures/64/   the same at half the size
addons/        the Godot addon, psx_textures/: this folder is a Godot 4.3+ project that opens on
               its demo room (.gdignore keeps Godot out of the other folders)

Godot 4.3 and later
-------------------
Copy addons/psx_textures/ into your project's addons/ folder. materials/ has a
StandardMaterial3D per texture: point filtered, repeating, lit by your lights, the splatter an
alpha-scissor cutout. Drag one onto a mesh. To tile a texture once a metre, give your mesh UVs in
metres, or set the material's UV1 scale (or Triplanar) to fit.
demo/room.tscn is a room to try them in: pick a surface with up / down, its texture with left /
right, Space for the next set of them.
For the full PS1 look (vertex snap, affine textures, 240p, dither), our PSX Look shaders turn the
materials over in one line: https://heyheythere.itch.io/psx-look
With PSX Look in res://addons/psx_look/, the room shows through it (P toggles it).
PSX Textures uses the same addon folder: it installs over this one.

Other engines and apps
----------------------
Use textures/128/ or textures/64/. Set the filtering to nearest/point, turn mipmaps and
compression off for the crisp PS1 texels, and repeat (wrap) on. For the splatter, use alpha test
/ cutout (alpha clip at 0.5).

License: CC BY 4.0, see LICENSE.txt for the credit line. Made by heyheythere:
https://heyheythere.itch.io
