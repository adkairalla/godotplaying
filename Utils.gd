extends Resource
class_name Utils

static func get_direction(node: Node3D) -> Vector3:
	var direction = node.rotation.y
#	print(direction)
#	print(rad_to_deg(direction))
	var angle_shift = PI/8
#	print(snapped(direction, PI/8))
	if abs(direction) < angle_shift:
#		print("n")
		return Vector3.MODEL_FRONT
	elif direction < -angle_shift && direction >= -3 * angle_shift:
#		print("ne")
		return (Vector3.MODEL_FRONT + Vector3.MODEL_RIGHT).normalized()
	elif direction < -3 * angle_shift && direction >= -5 * angle_shift:
#		print("e")
		return Vector3.MODEL_RIGHT
	elif direction < -5 * angle_shift && direction >= -7 * angle_shift:
#		print("se")
		return (Vector3.MODEL_REAR + Vector3.MODEL_RIGHT).normalized()
	elif direction < -7 * angle_shift || direction > 7 * angle_shift:
#		print("s")
		return Vector3.MODEL_REAR
	elif direction > angle_shift && direction <= 3 * angle_shift:
#		print("nw")
		return (Vector3.MODEL_FRONT + Vector3.MODEL_LEFT).normalized()
	elif direction > 3 * angle_shift && direction <= 5 * angle_shift:
#		print("w")
		return Vector3.MODEL_LEFT
	elif direction > 5 * angle_shift && direction <= 7 * angle_shift:
#		print("sw")
		return (Vector3.MODEL_REAR + Vector3.MODEL_LEFT).normalized()
	return Vector3.ZERO
	
static func rotate_points(points: PackedVector3Array, rotation: float) -> PackedVector3Array:
	var adjust = false
	rotation = snapped(rotation, PI / 4)
	if rotation == PI/4 || rotation == 3*PI/4 || rotation == -PI/4 || rotation == -3*PI/4:
		adjust = true
	var rotated_points = PackedVector3Array()
	var cos_theta = snapped(cos(rotation), .12)
	var sin_theta = snapped(sin(rotation), .12)
	for point in points:
		if adjust:
			point.z += 1
		rotated_points.append(Vector3(cos_theta * point.x - sin_theta * point.z, 0, sin_theta * point.x + cos_theta * point.z))
	return rotated_points
