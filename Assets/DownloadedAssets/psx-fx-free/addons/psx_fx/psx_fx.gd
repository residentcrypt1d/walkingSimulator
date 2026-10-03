class_name PSXFX
extends AnimatedSprite3D
## One PSX FX sheet as an AnimatedSprite3D, read from sheets/effects.json: sharp pixels, cutout
## alpha, sized in metres.
##
##     PSXFX.spawn(self, "impact_concrete", hit.position)                      # plays once, frees itself
##     PSXFX.spawn(self, "decal_hole_concrete", hit.position, hit.normal)      # stays on the wall
##     PSXFX.spawn(gun, "muzzle_side", muzzle.global_position, -gun.global_basis.z)
##     var fire := PSXFX.spawn(self, "fire_barrel", barrel.global_position)    # loops
##     fire.finish()                                                           # fades out and frees
##
## An effect's `facing` in effects.json says how it stands: "camera" turns to the camera,
## "upright" turns about its vertical axis only (fire, smoke, drips), "floor" and "wall" lie on the
## surface whose normal is `dir`, "barrel" is two crossed quads pointing along `dir`. Its `anchor`
## sits on the node's position and `metres` is its cell's height in the world. One-shots free
## themselves when done, bar those on a floor or wall, whose last frame stays (a pool of blood).
## `sheet_set` is "128" or "64"; PSXFX.default_set picks it for every spawn.

## Where sheets/ is: found in this folder, or at res://sheets/ as the zip has it. Set it if the
## sheets are elsewhere.
static var sheets_dir := ""
static var default_set := "128"
static var _data: Dictionary = {}
static var _frames: Dictionary = {}

var effect := ""
var sheet_set := ""
var _twin: AnimatedSprite3D  # a barrel's second quad


## The effect names in the installed sheets, e.g. "impact_concrete".
static func effects() -> PackedStringArray:
	return PackedStringArray(_effects().keys())


static func info(fx_name: String) -> Dictionary:
	return _effects()[fx_name]


## Adds `fx_name` to `parent` at the global position `at`, facing by `dir` (see above), and plays it.
static func spawn(parent: Node, fx_name: String, at: Vector3, dir := Vector3.ZERO, set_name := "") -> PSXFX:
	var fx := PSXFX.new()
	fx.setup(fx_name, set_name)
	parent.add_child(fx)
	fx.global_position = at
	fx.face(dir)
	fx.play()
	return fx


## The effect's frames, made once per sheet set and shared.
static func frames_for(fx_name: String, set_name := "") -> SpriteFrames:
	set_name = set_name if set_name else default_set
	var key := set_name + "/" + fx_name
	if key in _frames:
		return _frames[key]
	var e: Dictionary = _effects()[fx_name]
	var sheet: Texture2D = load(sheets_dir.path_join(set_name).path_join(e.file))
	var cell := Vector2(e.cell[set_name][0], e.cell[set_name][1])
	var cols: int = e.columns
	var sf := SpriteFrames.new()
	sf.set_animation_loop(&"default", e.loop)
	sf.set_animation_speed(&"default", e.fps)
	for i in int(e.frames):
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(Vector2(i % cols, floorf(i / float(cols))) * cell, cell)
		sf.add_frame(&"default", atlas)
	_frames[key] = sf
	return sf


static func _effects() -> Dictionary:
	if _data.is_empty():
		if sheets_dir.is_empty():
			var here := "res://addons/psx_fx/sheets/"
			sheets_dir = here if ResourceLoader.exists(here + "effects.json") else "res://sheets/"
		var json: JSON = load(sheets_dir.path_join("effects.json"))
		for e: Dictionary in json.data.effects:
			_data[e.name] = e
	return _data


func setup(fx_name: String, set_name := "") -> void:
	if fx_name not in _effects():
		push_error("PSXFX: no effect %s in %s" % [fx_name, sheets_dir])
		return
	effect = fx_name
	sheet_set = set_name if set_name else default_set
	var e: Dictionary = _effects()[fx_name]
	var cell := Vector2(e.cell[sheet_set][0], e.cell[sheet_set][1])
	sprite_frames = frames_for(fx_name, sheet_set)
	centered = true
	offset = Vector2(0.5 - e.anchor[0], e.anchor[1] - 0.5) * cell  # a Sprite3D's offset runs y up
	pixel_size = e.metres / cell.y
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	billboard = {"camera": BaseMaterial3D.BILLBOARD_ENABLED, "upright": BaseMaterial3D.BILLBOARD_FIXED_Y}.get(
			e.facing, BaseMaterial3D.BILLBOARD_DISABLED)
	if e.facing == "barrel" and not _twin:
		_twin = AnimatedSprite3D.new()
		for p in ["sprite_frames", "offset", "pixel_size", "texture_filter", "alpha_cut"]:
			_twin.set(p, get(p))
		_twin.rotation.x = PI / 2
		add_child(_twin)
		frame_changed.connect(func() -> void: _twin.frame = frame)
	if not e.loop and e.facing not in ["floor", "wall"] and not animation_finished.is_connected(queue_free):
		animation_finished.connect(queue_free)


## Turns the effect by `dir`: a floor or wall effect lies on the surface with that normal (by
## default the floor, or a wall facing +Z), a hair off it and turned at random; a barrel's points
## along it (by default +X). The rest face the camera and ignore it.
func face(dir := Vector3.ZERO) -> void:
	var facing: String = info(effect).facing
	if facing == "barrel":
		var x := dir.normalized() if dir else Vector3.RIGHT
		var z := x.cross(Vector3.UP if absf(x.y) < 0.99 else Vector3.BACK).normalized()
		global_basis = Basis(x, z.cross(x), z)
	elif facing in ["floor", "wall"]:
		var n := dir.normalized() if dir else (Vector3.UP if facing == "floor" else Vector3.BACK)
		var x := (Vector3.UP if absf(n.y) < 0.99 else Vector3.FORWARD).cross(n).normalized()
		global_basis = Basis(x, n.cross(x), n).rotated(n, randf() * TAU)
		global_position += n * 0.01


## Fades the effect out over `fade` seconds and frees it: how a loop ends, or a decal goes.
func finish(fade := 0.3) -> void:
	var tw := create_tween().set_parallel()
	for s: SpriteBase3D in ([self, _twin] if _twin else [self]):
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED  # cutout can't fade
		tw.tween_property(s, "modulate:a", 0.0, fade)
	tw.chain().tween_callback(queue_free)
