extends SubViewportContainer

signal model_ready(stats: Dictionary)
signal load_failed(message: String)
signal loading(message: String)
signal animation_ready(names: PackedStringArray)

var viewport := SubViewport.new()
var world := Node3D.new()
var holder := Node3D.new()
var camera := Camera3D.new()
var environment := Environment.new()
var floor_mesh := MeshInstance3D.new()
var key := DirectionalLight3D.new()
var model: Node3D
var meshes: Array[MeshInstance3D] = []
var player: AnimationPlayer
var bounds := AABB()
var target := Vector3.ZERO
var yaw := 0.55
var pitch := 0.18
var distance := 4.0
var radius := 1.0
var display_mode := 0
var orthographic := false
var turntable := false
var thread: Thread
var job: Dictionary = {}
var pending: Dictionary = {}
var active_record: Dictionary = {}
var cache: Dictionary = {}
var cache_order: Array[String] = []
var wire_meshes: Array[MeshInstance3D] = []
var stats: Dictionary = {}
var dragging := 0
var warm_frames := 0
var clay := StandardMaterial3D.new()
var normals := ShaderMaterial.new()
var wires := ShaderMaterial.new()
var mode_materials: Dictionary = {}
var external_clips: Dictionary = {}
var skinned_boxes: Dictionary = {}

func _ready() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	viewport.size = Vector2i(960, 800)
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	viewport.add_child(world)
	world.add_child(holder)
	world.add_child(camera)
	camera.fov = 38
	camera.current = true
	var env_node := WorldEnvironment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("202833")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("d5dfeb")
	environment.ambient_light_energy = 0.5
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_node.environment = environment
	world.add_child(env_node)
	key.rotation_degrees = Vector3(-40, -35, 0)
	key.light_energy = 1.3
	key.shadow_enabled = true
	world.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20, 135, 0)
	fill.light_color = Color("b7d4ff")
	fill.light_energy = 0.65
	world.add_child(fill)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-55, 175, 0)
	rim.light_energy = 0.8
	world.add_child(rim)
	var plane := PlaneMesh.new()
	plane.size = Vector2(200, 200)
	floor_mesh.mesh = plane
	var grid := ShaderMaterial.new()
	grid.shader = Shader.new()
	grid.shader.code = "shader_type spatial; render_mode unshaded; uniform float cell = 0.25; varying vec3 pos; void vertex(){pos=VERTEX;} void fragment(){ vec2 p=pos.xz/cell; vec2 a=abs(fract(p-0.5)-0.5)/max(fwidth(p),vec2(0.001)); float line=1.0-min(min(a.x,a.y),1.0); float fade=1.0-smoothstep(4.0,22.0,length(pos.xz)/cell); ALBEDO=mix(vec3(0.105,0.133,0.168),vec3(0.21,0.26,0.31),line*fade*0.6); }"
	floor_mesh.material_override = grid
	floor_mesh.position.y = -0.002
	world.add_child(floor_mesh)
	clay.albedo_color = Color("c4ccd5")
	clay.roughness = 0.7
	normals.shader = Shader.new()
	normals.shader.code = "shader_type spatial; render_mode unshaded; void fragment(){ALBEDO=NORMAL*0.5+0.5;}"
	wires.shader = Shader.new()
	wires.shader.code = "shader_type spatial; render_mode unshaded,cull_disabled; varying vec3 bary; void vertex(){bary=COLOR.rgb;} void fragment(){vec3 d=fwidth(bary);vec3 a=smoothstep(vec3(0.0),d*1.15,bary);float edge=1.0-min(min(a.x,a.y),a.z); ALBEDO=mix(vec3(0.12,0.16,0.20),vec3(0.49,0.87,0.75),edge);}"
	gui_input.connect(_gesture)
	resized.connect(redraw)
	_update_camera()

func invalidate_cache() -> void:
	cache.clear()
	cache_order.clear()

func request_model(record: Dictionary) -> void:
	pending = {"record": record, "path": record._path, "kind": "model"}
	loading.emit("Loading " + record.name + "…")
	if thread == null:
		_start_pending()

func _start_pending() -> void:
	job = pending
	pending = {}
	var path: String = job.path
	var cached_file := FileAccess.open(path, FileAccess.READ) if cache.has(path) else null
	var stamp := str(FileAccess.get_modified_time(path)) + ":" + str(cached_file.get_length() if cached_file else 0)
	if cache.has(path) and cache[path].stamp == stamp:
		_finish({"state": cache[path].state, "document": cache[path].document, "error": OK})
		return
	thread = Thread.new()
	thread.start(_parse.bind(path))

func _parse(path: String) -> Dictionary:
	var state := GLTFState.new()
	var document := GLTFDocument.new()
	var error := document.append_from_file(path, state, GLTFDocument.IMPORT_FLAG_USE_NAMED_SKIN_BINDS | GLTFDocument.IMPORT_FLAG_GENERATE_TANGENT_ARRAYS)
	return {"state": state, "document": document, "error": error}

func _process(delta: float) -> void:
	if thread != null and not thread.is_alive():
		var result: Dictionary = thread.wait_to_finish()
		thread = null
		if pending.is_empty():
			_finish(result)
		else:
			_start_pending()
	if turntable and model != null:
		yaw += delta * 0.3
		_update_camera()
	if warm_frames > 0:
		warm_frames -= 1
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	elif (player != null and player.is_playing()) or turntable:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _finish(result: Dictionary) -> void:
	if result.error != OK:
		load_failed.emit("Could not load %s (error %d)." % [job.path.get_file(), result.error])
		return
	var path: String = job.path
	var file := FileAccess.open(path, FileAccess.READ)
	var stamp := str(FileAccess.get_modified_time(path)) + ":" + str(file.get_length() if file else 0)
	cache[path] = {"state": result.state, "document": result.document, "stamp": stamp}
	cache_order.erase(path)
	cache_order.append(path)
	while cache_order.size() > 2:
		cache.erase(cache_order.pop_front())
	var document: GLTFDocument = result.document
	var scene := document.generate_scene(result.state) as Node3D
	if scene == null:
		load_failed.emit("No 3D scene in " + path.get_file())
		return
	if job.kind == "clip":
		_attach_clip(scene, path.get_file().get_basename())
		scene.free()
		return
	active_record = job.record
	if model != null:
		holder.remove_child(model)
		model.queue_free()
	model = scene
	meshes.clear()
	wire_meshes.clear()
	mode_materials.clear()
	external_clips.clear()
	skinned_boxes.clear()
	player = null
	holder.add_child(model)
	_collect(model)
	if meshes.is_empty():
		load_failed.emit("No visible meshes in " + active_record.name)
		return
	bounds = _bounds()
	if active_record.fit_to_height and bounds.size.y > 0.000001:
		model.scale *= float(active_record.height_m) / bounds.size.y
		bounds = _bounds()
		model.position -= Vector3(bounds.get_center().x, bounds.position.y, bounds.get_center().z)
		bounds = _bounds()
	radius = maxf(bounds.size.length() * 0.5, 0.01)
	var grid_material := floor_mesh.material_override as ShaderMaterial
	grid_material.set_shader_parameter("cell", pow(10.0, floor(log(maxf(bounds.size.y / 5.0, 0.001)) / log(10.0))))
	floor_mesh.scale = Vector3.ONE * maxf(radius, 0.1)
	floor_mesh.position.y = minf(bounds.position.y, 0.0) - radius * 0.002

	stats = _statistics()
	_apply_mode()
	frame_model()
	model_ready.emit(stats)
	_emit_animations()
	redraw()

func _collect(node: Node) -> void:
	if node is MeshInstance3D and node.mesh != null:
		meshes.append(node)
	if node is AnimationPlayer and player == null:
		player = node
		player.stop()
	for child in node.get_children():
		_collect(child)

func _bounds() -> AABB:
	var result := AABB()
	var first := true
	for mesh in meshes:
		var box: AABB = holder.global_transform.affine_inverse() * mesh.global_transform * _mesh_box(mesh)
		if first:
			result = box
			first = false
		else:
			result = result.merge(box)
	return result

func _mesh_box(mesh: MeshInstance3D) -> AABB:
	if mesh.skin == null:
		return mesh.get_aabb()
	if skinned_boxes.has(mesh):
		return skinned_boxes[mesh]
	var skeleton := mesh.get_node_or_null(mesh.skeleton) as Skeleton3D
	if skeleton == null:
		return mesh.get_aabb()
	# A skinned mesh's raw bounds omit the bind transforms used when it is drawn.
	var transforms: Array[Transform3D] = []
	for bind in mesh.skin.get_bind_count():
		var bone := skeleton.find_bone(mesh.skin.get_bind_name(bind)) if not mesh.skin.get_bind_name(bind).is_empty() else mesh.skin.get_bind_bone(bind)
		transforms.append(skeleton.get_bone_global_rest(bone) * mesh.skin.get_bind_pose(bind) if bone >= 0 else Transform3D.IDENTITY)
	var result := AABB()
	var first := true
	for surface in mesh.mesh.get_surface_count():
		var arrays := mesh.mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
		var stride := bones.size() / maxi(vertices.size(), 1)
		for i in vertices.size():
			var point := Vector3.ZERO
			if stride == 0:
				point = vertices[i]
			else:
				for influence in stride:
					var offset: int = i * stride + influence
					if weights[offset] > 0:
						point += (transforms[bones[offset]] * vertices[i]) * weights[offset]
			if first:
				result = AABB(point, Vector3.ZERO)
				first = false
			else:
				result = result.expand(point)
	skinned_boxes[mesh] = result
	return result

func _statistics() -> Dictionary:
	var triangles := 0
	var vertices := 0
	var surfaces := 0
	var materials: Array[Dictionary] = []
	var seen: Dictionary = {}
	for instance in meshes:
		var mesh := instance.mesh
		for surface in mesh.get_surface_count():
			surfaces += 1
			var arrays := mesh.surface_get_arrays(surface)
			vertices += arrays[Mesh.ARRAY_VERTEX].size()
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			var count: int = indices.size() if not indices.is_empty() else arrays[Mesh.ARRAY_VERTEX].size()
			if mesh.surface_get_primitive_type(surface) == Mesh.PRIMITIVE_TRIANGLES:
				triangles += count / 3
			var material := instance.get_active_material(surface)
			if material != null and not seen.has(material):
				seen[material] = true
				var entry := {"name": material.resource_name if not material.resource_name.is_empty() else "Material %d" % (materials.size() + 1), "maps": []}
				if material is BaseMaterial3D:
					var slots := {"Albedo": BaseMaterial3D.TEXTURE_ALBEDO, "Normal": BaseMaterial3D.TEXTURE_NORMAL, "Roughness": BaseMaterial3D.TEXTURE_ROUGHNESS, "Metallic": BaseMaterial3D.TEXTURE_METALLIC, "AO": BaseMaterial3D.TEXTURE_AMBIENT_OCCLUSION, "Emission": BaseMaterial3D.TEXTURE_EMISSION}
					for slot in slots:
						var texture: Texture2D = material.get_texture(slots[slot])
						if texture != null:
							entry.maps.append("%s  ·  %d × %d" % [slot, texture.get_width(), texture.get_height()])
				materials.append(entry)
	return {"triangles": triangles, "vertices": vertices, "meshes": meshes.size(), "surfaces": surfaces, "materials": materials, "bounds": bounds, "bytes": FileAccess.open(active_record._path, FileAccess.READ).get_length()}

func frame_model() -> void:
	target = bounds.get_center()
	var aspect := maxf(size.x / maxf(size.y, 1), 0.1)
	var half_angle := atan(tan(deg_to_rad(camera.fov / 2.0)) * minf(aspect, 1.0))
	distance = radius / sin(half_angle) * 1.12
	yaw = 0.55
	pitch = 0.18
	_update_camera()

func preset(index: int) -> void:
	target = bounds.get_center()
	match index:
		0: yaw = 0; pitch = 0
		1: yaw = PI; pitch = 0
		2: yaw = PI / 2; pitch = 0
		3: yaw = -PI / 2; pitch = 0
		4: yaw = 0; pitch = PI / 2 - 0.001
		5: yaw = 0; pitch = -PI / 2 + 0.001
	_update_camera()

func _update_camera() -> void:
	camera.position = target + Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
	camera.look_at(target)
	camera.near = maxf(radius * 0.0001, 0.00001)
	camera.far = maxf(distance + radius * 100, 100)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL if orthographic else Camera3D.PROJECTION_PERSPECTIVE
	camera.size = distance * tan(deg_to_rad(camera.fov / 2)) * 2
	redraw()

func _gesture(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			dragging = event.button_index if event.pressed else 0
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			distance = clampf(distance * (0.88 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.14), radius * 0.02, radius * 100)
			_update_camera()
		if event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
			frame_model()
	if event is InputEventMouseMotion and dragging != 0:
		if dragging == MOUSE_BUTTON_RIGHT or (dragging == MOUSE_BUTTON_LEFT and event.alt_pressed):
			yaw -= event.relative.x * 0.008
			pitch = clampf(pitch + event.relative.y * 0.008, -PI / 2 + 0.001, PI / 2 - 0.001)
		else:
			var scale_factor := 2 * distance * tan(deg_to_rad(camera.fov / 2)) / maxf(size.y, 1)
			target += (-camera.global_basis.x * event.relative.x + camera.global_basis.y * event.relative.y) * scale_factor
		_update_camera()
	if event is InputEventMagnifyGesture:
		distance = clampf(distance / event.factor, radius * 0.02, radius * 100)
		_update_camera()
	if event is InputEventPanGesture:
		target += (-camera.global_basis.x * event.delta.x + camera.global_basis.y * event.delta.y) * distance * 0.01
		_update_camera()

func set_mode(index: int) -> void:
	display_mode = index
	_apply_mode()
	redraw()

func _apply_mode() -> void:
	if display_mode == 4 and wire_meshes.is_empty():
		_make_wires()
	for mesh in meshes:
		mesh.visible = display_mode != 4
		mesh.material_override = clay if display_mode == 1 else normals if display_mode == 3 else null
		for surface in mesh.mesh.get_surface_count():
			if display_mode == 2:
				var original := mesh.mesh.surface_get_material(surface)
				if original is BaseMaterial3D:
					if not mode_materials.has(original):
						var unlit: BaseMaterial3D = original.duplicate()
						unlit.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
						mode_materials[original] = unlit
					mesh.set_surface_override_material(surface, mode_materials[original])
			else:
				mesh.set_surface_override_material(surface, null)
	for mesh in wire_meshes:
		mesh.visible = display_mode == 4

func _make_wires() -> void:
	for original in meshes:
		var expanded := ArrayMesh.new()
		for surface in original.mesh.get_surface_count():
			if original.mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
				continue
			var source := original.mesh.surface_get_arrays(surface)
			var indices: PackedInt32Array = source[Mesh.ARRAY_INDEX]
			var count: int = indices.size() if not indices.is_empty() else source[Mesh.ARRAY_VERTEX].size()
			var arrays := []
			arrays.resize(Mesh.ARRAY_MAX)
			for slot in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_TANGENT, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_TEX_UV2, Mesh.ARRAY_BONES, Mesh.ARRAY_WEIGHTS]:
				if source[slot] == null or source[slot].is_empty():
					continue
				arrays[slot] = source[slot].duplicate()
				arrays[slot].clear()
				var stride := 4 if slot in [Mesh.ARRAY_TANGENT, Mesh.ARRAY_BONES, Mesh.ARRAY_WEIGHTS] else 1
				if slot in [Mesh.ARRAY_BONES, Mesh.ARRAY_WEIGHTS] and source[slot].size() == source[Mesh.ARRAY_VERTEX].size() * 8:
					stride = 8
				for i in count:
					var vertex := indices[i] if not indices.is_empty() else i
					for offset in stride:
						arrays[slot].append(source[slot][vertex * stride + offset])
			var colors := PackedColorArray()
			for i in count:
				colors.append([Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1)][i % 3])
			arrays[Mesh.ARRAY_COLOR] = colors
			var flags: int = original.mesh.surface_get_format(surface) & Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS
			expanded.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, flags)
		var wire := MeshInstance3D.new()
		wire.mesh = expanded
		wire.material_override = wires
		wire.skin = original.skin
		wire.skeleton = original.skeleton
		wire.transform = original.transform
		original.get_parent().add_child(wire)
		wire_meshes.append(wire)

func set_lighting(index: int) -> void:
	match index:
		0: environment.background_color = Color("202833"); environment.ambient_light_energy = 0.5; key.light_energy = 1.3
		1: environment.background_color = Color("d9dfe5"); environment.ambient_light_energy = 0.7; key.light_energy = 1.0
		2: environment.background_color = Color("10151c"); environment.ambient_light_energy = 0.12; key.light_energy = 2.0
	redraw()

func redraw() -> void:
	warm_frames = 3

func request_clip(filename: String) -> void:
	if filename == "":
		if player != null:
			player.stop()
			for skeleton in model.find_children("*", "Skeleton3D", true, false):
				skeleton.reset_bone_poses()
		redraw()
		return
	if external_clips.has(filename):
		player.play(external_clips[filename])
		redraw()
		return
	pending = {"path": active_record._path.get_base_dir().path_join(filename), "kind": "clip", "record": active_record}
	loading.emit("Loading animation…")
	if thread == null:
		_start_pending()

func _attach_clip(source: Node3D, label: String) -> void:
	var source_player: AnimationPlayer = source.find_child("*", true, false) as AnimationPlayer
	for node in source.find_children("*", "AnimationPlayer", true, false):
		source_player = node
		break
	if source_player == null:
		load_failed.emit("No animation in " + label)
		return
	if player == null:
		player = AnimationPlayer.new()
		model.add_child(player)
		player.root_node = NodePath("..")
	var library := AnimationLibrary.new()
	var target_root := player.get_node(player.root_node)
	var source_root := source_player.get_node(source_player.root_node)
	var added := 0
	for animation_name in source_player.get_animation_list():
		if animation_name == "RESET":
			continue
		var clip: Animation = source_player.get_animation(animation_name).duplicate(true)
		for i in range(clip.get_track_count() - 1, -1, -1):
			var track := clip.track_get_path(i)
			var from_node := source_root.get_node_or_null(NodePath(track.get_concatenated_names()))
			var to_node: Node
			if from_node is Skeleton3D:
				for skeleton in model.find_children("*", "Skeleton3D", true, false):
					if track.get_subname_count() > 0 and skeleton.find_bone(track.get_subname(0)) >= 0:
						to_node = skeleton
						break
			elif from_node != null:
				to_node = model.find_child(str(from_node.name), true, false)
			if to_node == null:
				clip.remove_track(i)
			else:
				var suffix := ":" + track.get_concatenated_subnames() if track.get_subname_count() > 0 else ""
				clip.track_set_path(i, NodePath(str(target_root.get_path_to(to_node)) + suffix))
		if clip.get_track_count() > 0:
			clip.loop_mode = Animation.LOOP_LINEAR
			library.add_animation("clip_%d" % added, clip)
			added += 1
	if added == 0:
		load_failed.emit("Animation skeleton does not match this model: " + label)
		return
	if player.has_animation_library(label):
		player.remove_animation_library(label)
	player.add_animation_library(label, library)
	external_clips[job.path.get_file()] = label + "/clip_0"
	player.play(label + "/clip_0")
	animation_ready.emit(player.get_animation_list())
	redraw()

func _emit_animations() -> void:
	animation_ready.emit(player.get_animation_list() if player != null else PackedStringArray())

func _exit_tree() -> void:
	if thread != null:
		thread.wait_to_finish()
