extends Node
## A dim PS1 room to try the effects in, drawn at 240 lines and scaled up in sharp pixels. Click to
## shoot the concrete, the crates, the steel door, the window or the dummy; pick an effect in the
## list to play it in the middle of the room. Until the first click it shoots by itself.

## What a shot leaves on each kind of surface: the impact and the decal.
const HITS := {
	"concrete": ["impact_concrete", "decal_hole_concrete"], "metal": ["impact_metal", "decal_hole_metal"],
	"wood": ["impact_wood", "decal_hole_wood"], "glass": ["impact_glass", "decal_glass_crack"],
	"flesh": ["impact_flesh", "decal_blood_splat"],
}
## Where the demo aims until the first click.
const AIMS := [Vector3(-1.2, 1.5, -9.9), Vector3(2.0, 0.55, -6.0), Vector3(3.95, 1.4, -6.3), Vector3(0.6, 1.3, -7.0),
	Vector3(-3.95, 1.7, -6.0), Vector3(-0.5, 0.0, -4.5), Vector3(1.3, 2.1, -9.9), Vector3(-2.0, 0.0, -3.8)]

## Hides the list, for the store captures.
@export var no_ui := false

var cam := Camera3D.new()
var world := Node3D.new()
var boxes: Array = []  # [AABB, kind] the shots can hit
var shown: PSXFX
var lights: Array[OmniLight3D] = []
var _t := 0.0
var _auto := true
var _next := 0.6
var _aim := 0
var _yaw := 0.0
var _pitch := -0.08
var _tex := {}
var _decals: Array[PSXFX] = []


func _ready() -> void:
	var view := SubViewportContainer.new()
	view.stretch = true
	view.stretch_shrink = 3
	view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(view)
	var port := SubViewport.new()
	port.own_world_3d = true
	view.add_child(port)
	port.add_child(world)
	_room()
	_props()
	world.add_child(cam)
	cam.position = Vector3(0, 1.6, -1.5)
	cam.fov = 68
	cam.current = true
	if not no_ui:
		_ui()


func _room() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.02, 0.03)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.28, 0.27, 0.32)
	env.fog_enabled = true
	env.fog_light_color = Color(0.03, 0.03, 0.04)
	env.fog_density = 0.06
	var we := WorldEnvironment.new()
	we.environment = env
	world.add_child(we)
	# floor, ceiling, back, left and right walls: 8 m across, 3.2 high, 10 deep
	_solid(AABB(Vector3(-4, -0.2, -10), Vector3(8, 0.2, 11.5)), "concrete", "floor", Vector2(4, 6))
	_solid(AABB(Vector3(-4, 3.2, -10), Vector3(8, 0.2, 11.5)), "concrete", "ceiling", Vector2(4, 6))
	_solid(AABB(Vector3(-4, 0, -10.2), Vector3(8, 3.2, 0.2)), "concrete", "wall", Vector2(4, 2))
	_solid(AABB(Vector3(-4.2, 0, -10), Vector3(0.2, 3.2, 11.5)), "concrete", "wall", Vector2(6, 2))
	_solid(AABB(Vector3(4, 0, -10), Vector3(0.2, 3.2, 11.5)), "concrete", "wall", Vector2(6, 2))
	_solid(AABB(Vector3(3.9, 0, -7.2), Vector3(0.12, 2.2, 1.6)), "metal", "door", Vector2.ONE)
	_solid(AABB(Vector3(-4.02, 1.1, -6.8), Vector3(0.05, 1.2, 1.6)), "glass", "glass", Vector2.ONE)
	for c in [[Vector3(1.4, 0, -6.6), 1.1], [Vector3(2.6, 0, -6.2), 0.9], [Vector3(1.9, 1.1, -6.5), 0.8]]:
		_solid(AABB(c[0], Vector3.ONE * c[1]), "wood", "crate", Vector2.ONE)
	_solid(AABB(Vector3(0.35, 0, -7.25), Vector3(0.5, 1.8, 0.5)), "flesh", "dummy", Vector2.ONE)
	_solid(AABB(Vector3(-3.1, 0, -7.5), Vector3(0.9, 1.0, 0.9)), "metal", "barrel", Vector2.ONE)
	_light(Vector3(0, 2.9, -6.5), Color(1.0, 0.85, 0.6), 7.0)


func _props() -> void:
	_fx(world, "fire_barrel", Vector3(-2.65, 1.0, -7.05))
	lights.append(_light(Vector3(-2.65, 1.8, -7.05), Color(1.0, 0.55, 0.2), 6.0))
	_fx(world, "smoke_column", Vector3(-2.65, 1.9, -7.2))
	_fx(world, "decal_scorch", Vector3(-2.65, 0.0, -6.3))
	_fx(world, "fire_torch", Vector3(-3.85, 1.3, -4.5))
	lights.append(_light(Vector3(-3.4, 1.9, -4.5), Color(1.0, 0.6, 0.25), 4.0))
	_fx(world, "fire_candle", Vector3(2.3, 1.9, -6.1))
	_fx(world, "light_halo", Vector3(0, 2.95, -6.5))
	_fx(world, "sparks_shower", Vector3(-1.4, 3.2, -8.2))
	_fx(world, "steam_vent", Vector3(1.2, 0.0, -9.4))
	_fx(world, "water_drip", Vector3(-1.4, 3.2, -4.0))
	_fx(world, "blood_pool", Vector3(0.6, 0.0, -6.4))
	_fx(world, "flies", Vector3(0.6, 0.9, -6.3))
	_fx(world, "decal_blood_smear", Vector3(-0.4, 1.3, -10.0), Vector3.BACK)
	_fx(world, "decal_blood_spatter", Vector3(1.5, 1.6, -10.0), Vector3.BACK)
	_fx(world, "electric_arc", Vector3(2.6, 2.6, -9.8))
	_fx(world, "gas_cloud", Vector3(-0.9, 0.0, -8.8))
	_fx(world, "dust_motes", Vector3(-0.8, 1.8, -5.0))
	_fx(world, "ghost_wisp", Vector3(-1.9, 1.5, -9.3))
	_fx(world, "item_glint", Vector3(-1.2, 0.35, -4.4))
	_solid(AABB(Vector3(-1.32, 0, -4.52), Vector3(0.24, 0.12, 0.24)), "metal", "pickup", Vector2.ONE)


func _process(delta: float) -> void:
	_t += delta
	for i in lights.size():
		lights[i].light_energy = 1.4 + 0.35 * sin(_t * 13.0 + i) * sin(_t * 7.3 + 2.0 * i)
	if _auto:
		_yaw = 0.12 * sin(_t * 0.4)
		_next -= delta
		if _next <= 0.0:
			_next = 0.45
			var to: Vector3 = AIMS[_aim % AIMS.size()]
			_aim += 1
			_shoot(cam.global_position, (to - cam.global_position).normalized())
			if _aim % 6 == 0:
				_fx(world, "explosion_small", Vector3(-1.0, 0.0, -9.0))
	cam.rotation = Vector3(_pitch, _yaw, 0)


func _unhandled_input(event: InputEvent) -> void:
	var b := event as InputEventMouseButton
	if b and b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
		_auto = false
		var port_pos := b.position / 3.0
		_shoot(cam.project_ray_origin(port_pos), cam.project_ray_normal(port_pos))
		get_viewport().set_input_as_handled()
	var m := event as InputEventMouseMotion
	if m and m.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		_auto = false
		_yaw = clampf(_yaw - m.relative.x * 0.004, -1.2, 1.2)
		_pitch = clampf(_pitch - m.relative.y * 0.004, -1.0, 1.0)


## Fires along `dir`: a flash at the muzzle, and an impact and decal where it lands.
func _shoot(from: Vector3, dir: Vector3) -> void:
	var flash := _fx(cam, "muzzle_front", cam.to_global(Vector3(0.17, -0.14, -0.62)))
	if flash:
		flash.scale = Vector3.ONE * 0.4
	var best := INF
	var hit: Array = []
	for b: Array in boxes:
		var r := _ray_box(from, dir, b[0])
		if r and r[0] < best:
			best = r[0]
			hit = [from + dir * r[0], r[1], b[1]]
	if hit.is_empty():
		return
	var kind: String = hit[2]
	var at: Vector3 = hit[0]
	var normal: Vector3 = hit[1]
	var have := PSXFX.effects()
	var impact: String = HITS[kind][0] if HITS[kind][0] in have else "impact_concrete"
	var decal: String = HITS[kind][1] if HITS[kind][1] in have else "decal_hole_concrete"
	_fx(world, impact, at + normal * 0.05)
	if kind == "flesh":
		_fx(world, "blood_spurt", at + normal * 0.05)
		_decal(_fx(world, "decal_blood_splat", Vector3(at.x, 0.0, at.z) + normal * 0.6))
	else:
		_decal(_fx(world, decal, at, normal))



## Keeps the last 40 decals.
func _decal(d: PSXFX) -> void:
	if not d:
		return
	_decals.append(d)
	if _decals.size() > 40:
		_decals.pop_front().finish()


## The distance along the ray to `box` and the face's normal, or [] if it misses.
func _ray_box(from: Vector3, dir: Vector3, box: AABB) -> Array:
	var near := -INF
	var far := INF
	var normal := Vector3.ZERO
	for axis in 3:
		if absf(dir[axis]) < 1e-6:
			if from[axis] < box.position[axis] or from[axis] > box.end[axis]:
				return []
			continue
		var a := (box.position[axis] - from[axis]) / dir[axis]
		var b := (box.end[axis] - from[axis]) / dir[axis]
		if a > b:
			var s := a
			a = b
			b = s
		if a > near:
			near = a
			normal = Vector3.ZERO
			normal[axis] = -signf(dir[axis])
		far = minf(far, b)
	return [near, normal] if near <= far and near > 0.0 else []


## Spawns `fx_name` if the installed sheets have it (the free sampler has a few), else null.
func _fx(parent: Node, fx_name: String, at: Vector3, dir := Vector3.ZERO) -> PSXFX:
	return PSXFX.spawn(parent, fx_name, at, dir) if fx_name in PSXFX.effects() else null


func _solid(box: AABB, kind: String, look: String, tiles: Vector2) -> void:
	boxes.append([box, kind])
	var mi := MeshInstance3D.new()
	mi.mesh = _box_mesh(box.size)
	mi.position = box.get_center()
	var tint: Color = {"floor": Color(0.5, 0.48, 0.45), "ceiling": Color(0.35, 0.34, 0.33), "wall": Color(0.55, 0.53, 0.5),
		"door": Color(0.36, 0.38, 0.42), "glass": Color(0.35, 0.5, 0.55), "crate": Color(0.6, 0.42, 0.24), "dummy": Color(0.55, 0.42, 0.34),
		"barrel": Color(0.4, 0.22, 0.14), "pickup": Color(0.3, 0.75, 0.4)}[look]
	var m := _mat(look, tint)
	m.uv1_scale = Vector3(tiles.x, tiles.y, 1)
	mi.material_override = m
	world.add_child(mi)


func _box_mesh(size: Vector3) -> BoxMesh:
	var bm := BoxMesh.new()
	bm.size = size
	# vertices enough for per-vertex lighting to fall off across a wall
	bm.subdivide_width = int(size.x * 2.0)
	bm.subdivide_height = int(size.y * 2.0)
	bm.subdivide_depth = int(size.z * 2.0)
	return bm


## A PS1-ish material: a 16-pixel noise texture, nearest-filtered, lit per vertex.
func _mat(look: String, tint: Color) -> StandardMaterial3D:
	if look not in _tex:
		var img := Image.create(16, 16, false, Image.FORMAT_RGB8)
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(look)
		for y in 16:
			for x in 16:
				var v := 0.8 + 0.2 * rng.randf()
				if look in ["wall", "floor"] and (y % 8 == 0 or (x + 8 * int(y / 8 % 2 == 1)) % 16 == 0):
					v *= 0.7  # block joints
				if look == "crate" and (x % 5 == 0):
					v *= 0.75
				img.set_pixel(x, y, Color(v, v, v))
		_tex[look] = ImageTexture.create_from_image(img)
	var m := StandardMaterial3D.new()
	m.albedo_texture = _tex[look]
	m.albedo_color = tint
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return m


func _light(at: Vector3, color: Color, reach: float) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = at
	l.light_color = color
	l.omni_range = reach
	l.light_energy = 1.4
	world.add_child(l)
	return l


func _ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var panel := PanelContainer.new()
	panel.position = Vector2(12, 12)
	ui.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var title := Label.new()
	title.text = "PSX FX"
	box.add_child(title)
	var hint := Label.new()
	hint.text = "click to shoot, drag right to look\npick an effect to play it"
	hint.add_theme_font_size_override("font_size", 13)
	box.add_child(hint)
	var list := ItemList.new()
	list.custom_minimum_size = Vector2(210, 470)
	list.focus_mode = Control.FOCUS_NONE
	for n in PSXFX.effects():
		list.add_item(n.replace("_", " "))
		list.set_item_metadata(list.item_count - 1, n)
	list.item_selected.connect(func(i: int) -> void: _show(list.get_item_metadata(i)))
	box.add_child(list)


## Plays `fx_name` in the middle of the room, where it belongs: on the floor, from the ceiling,
## on the back wall, or in the air.
func _show(fx_name: String) -> void:
	_auto = false
	if is_instance_valid(shown):
		shown.finish(0.1)
	var e := PSXFX.info(fx_name)
	var at := Vector3(0, 1.4, -4.2)
	var dir := Vector3.ZERO
	match e.facing:
		"floor":
			at.y = 0.0
		"wall":
			at = Vector3(-1.0, 1.4, -10.0)
			dir = Vector3.BACK
		"barrel":
			at.x = -0.4
		"upright":
			at.y = 0.0 if e.anchor[1] > 0.6 else 3.2 if e.anchor[1] < 0.2 else 1.0
	shown = PSXFX.spawn(world, fx_name, at, dir)
	if e.loop or e.facing in ["floor", "wall"]:
		return
	shown.animation_finished.disconnect(shown.queue_free)
	shown.animation_finished.connect(func() -> void:
		shown.frame = 0
		shown.play())
