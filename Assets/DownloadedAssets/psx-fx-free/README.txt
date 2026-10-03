The full pack: PSX FX has 45: shotgun blasts, impacts on metal, wood, flesh, water and glass,
blood spurts, drips and pools, barrel fires, steam, gas, arcs, flies, a ghostly wisp and 8
decals. Same sheets, same player.
https://heyheythere.itch.io/psx-fx

sheets/128/    every effect at 128 px (muzzle flashes, spurts and arcs 128x64, fires, smoke and
               drips 64x128, the rest 128x128)
sheets/64/     the same drawn at half size, for a chunkier look or a lower resolution
previews/      an animated GIF of each effect
sheets/effects.json  for each sheet: frame size per set, frame count, columns, fps, whether it
               loops, its group, and how to place it in 3D:
                 anchor   0..1 across and down the frame, the point that goes where it happens
                          (a barrel, a wound, the base of a fire, a drip's ceiling, the centre)
                 metres   the frame's height in the world
                 facing   camera: a billboard; upright: a billboard turning about its vertical
                          axis only; floor or wall: flat on the surface; barrel: two crossed quads
                          along the barrel (the flash points right in the sheet)

Each sheet is a grid of frames, left to right then top to bottom, 8 to a row. The pixels are the
PS1's: 15-bit colour, dithered, and alpha that is fully on or off, so use them with nearest
filtering and alpha clip / cutout, no blending or mipmaps needed. Fires, smoke, drips, sparks,
arcs and the ambient effects loop seamlessly; the rest play once. Decals are a single frame.

Godot 4.3+
    Copy addons/psx_fx/ into your project and sheets/ into addons/psx_fx/, then
        PSXFX.spawn(self, "impact_concrete", hit.position)
        PSXFX.spawn(self, "decal_hole_concrete", hit.position, hit.normal)
        PSXFX.spawn(gun, "muzzle_side", muzzle.global_position, -gun.global_basis.z)
        var fire := PSXFX.spawn(self, "fire_barrel", barrel.global_position)
        fire.finish()   # fades a loop out
    Each effect stands as its `facing` says, at its anchor, sized in metres. One-shots free
    themselves when done; ones on a floor or wall stay. PSXFX.default_set = "64" switches every
    spawn to the 64 set; set PSXFX.sheets_dir if sheets/ is elsewhere. Open
    addons/psx_fx/demo/demo.tscn: a room to shoot and play every effect in.

Unity
    Import a sheet: Texture Type Sprite (2D and UI), Sprite Mode Multiple, Filter Mode Point,
    Compression None, Pixels Per Unit = the frame height divided by `metres`. In the Sprite
    Editor: Slice > Grid By Cell Size with the frame size, and set the pivot to the anchor. Drag
    the sprites in order into the scene to make the animation, at the fps, looping as "loop" says.
    For a billboard, turn the object to the camera each frame; use an alpha-clip material.

Anything else
    Any engine that cuts a grid sheet: use the frame size, count, fps and anchor from
    effects.json, nearest filtering and an alpha test.
