class_name CharacterRig
## Finishes a rigged Meshy character: clips shared between rigs, and a rigid pack on its back.

const FPS := 30.0
const PACK_BONE := "Spine"
const PACK_HEIGHT := 0.45


# Meshy rigs share bone names but not bone orientations, and their rest poses can't be trusted
# to match. Every rig does come with the same Walking clip, though, so frame 0 of each rig's walk
# is one physical pose: it gives each bone's fixed offset from one rig to the other.
static func retarget(clip: Animation, from: Skeleton3D, from_walk: Animation, to: Skeleton3D, to_walk: Animation) -> Animation:
	var from_calibration := _world_pose(from_walk, from, 0.0, _tracks(from_walk, from))
	var to_calibration := _world_pose(to_walk, to, 0.0, _tracks(to_walk, to))
	var tracks := _tracks(clip, from)
	var offsets := []
	var sources := []
	for bone in to.get_bone_count():
		var source := from.find_bone(to.get_bone_name(bone))
		sources.append(source)
		offsets.append(from_calibration.rotations[source].inverse() * to_calibration.rotations[bone])
	var hips_scale: float = to_calibration.hips.y / from_calibration.hips.y

	var out := Animation.new()
	out.length = clip.length
	var prefix := str(clip.track_get_path(0)).get_slice(":", 0)
	for bone in to.get_bone_count():
		out.track_set_path(out.add_track(Animation.TYPE_ROTATION_3D), "%s:%s" % [prefix, to.get_bone_name(bone)])
	var hips_track := out.add_track(Animation.TYPE_POSITION_3D)
	out.track_set_path(hips_track, prefix + ":Hips")
	for frame in ceili(clip.length * FPS) + 1:
		var time := minf(frame / FPS, clip.length)
		var pose := _world_pose(clip, from, time, tracks)
		var world := []
		for bone in to.get_bone_count():
			world.append(pose.rotations[sources[bone]] * offsets[bone])
			var parent := to.get_bone_parent(bone)
			out.rotation_track_insert_key(bone, time, world[parent].inverse() * world[bone] if parent >= 0 else world[bone])
		out.position_track_insert_key(hips_track, time, to_calibration.hips + (pose.hips - from_calibration.hips) * hips_scale)
	return out


# Track paths stay fixed while sampling a clip; resolve them once instead of for every frame.
static func _tracks(clip: Animation, skeleton: Skeleton3D) -> Dictionary:
	var prefix := str(clip.track_get_path(0)).get_slice(":", 0)
	var rotations := PackedInt32Array()
	for bone in skeleton.get_bone_count():
		rotations.append(clip.find_track("%s:%s" % [prefix, skeleton.get_bone_name(bone)], Animation.TYPE_ROTATION_3D))
	return {"rotations": rotations, "hips": clip.find_track(prefix + ":Hips", Animation.TYPE_POSITION_3D)}


# Each bone's world rotation, and the hips position, at one moment of a clip.
static func _world_pose(clip: Animation, skeleton: Skeleton3D, time: float, tracks: Dictionary) -> Dictionary:
	var rotations := []
	for bone in skeleton.get_bone_count():
		var track: int = tracks.rotations[bone]
		var local := clip.rotation_track_interpolate(track, time) if track >= 0 else skeleton.get_bone_rest(bone).basis.get_rotation_quaternion()
		var parent := skeleton.get_bone_parent(bone)
		rotations.append(rotations[parent] * local if parent >= 0 else local)
	var hips: int = tracks.hips
	return {"rotations": rotations, "hips": clip.position_track_interpolate(hips, time) if hips >= 0 else skeleton.get_bone_rest(skeleton.find_bone("Hips")).origin}


# Hangs the pack on the chest bone with its back panel against the body and its top at the
# shoulders. Pack models face +Z like the characters, so the pack turns to face away. The
# character must not be turned yet; it can stand anywhere.
static func attach_pack(skeleton: Skeleton3D, body: MeshInstance3D, pack: Node3D) -> void:
	var attachment := BoneAttachment3D.new()
	attachment.bone_name = PACK_BONE
	skeleton.add_child(attachment)
	var box: AABB = pack.find_children("*", "MeshInstance3D", true, false)[0].get_aabb()
	var turned := Transform3D(Basis(Vector3.UP, PI).scaled(Vector3.ONE * PACK_HEIGHT / box.size.y), Vector3.ZERO)
	box = turned * box
	var bone := skeleton.global_transform * skeleton.get_bone_global_rest(skeleton.find_bone(PACK_BONE))
	var top := (skeleton.global_transform * skeleton.get_bone_global_rest(skeleton.find_bone("LeftShoulder"))).origin.y + 0.04
	var centre := skeleton.global_position.x
	var back := _back_of(body, bone * _bind_pose(body, PACK_BONE), top - PACK_HEIGHT, top, centre)
	turned.origin = Vector3(centre - box.get_center().x, top - box.end.y, back - box.end.z)
	pack.transform = bone.affine_inverse() * turned
	attachment.add_child(pack)


# A skinned body's vertices live in the skin's space, not the node's, so reaching the world goes
# through a bone and its bind pose.
static func _bind_pose(body: MeshInstance3D, bone_name: String) -> Transform3D:
	for bind in body.skin.get_bind_count():
		if body.skin.get_bind_name(bind) == bone_name:
			return body.skin.get_bind_pose(bind)
	return Transform3D.IDENTITY


# The rearmost point of the centre strip of the torso between two heights, in world space.
static func _back_of(body: MeshInstance3D, to_world: Transform3D, low: float, high: float, centre: float) -> float:
	var back := INF
	for surface in body.mesh.get_surface_count():
		for vertex: Vector3 in body.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
			var point := to_world * vertex
			if point.y > low and point.y < high and absf(point.x - centre) < 0.12:
				back = minf(back, point.z)
	return back
