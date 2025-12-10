extends Object
class_name AreaCollision

static func is_point_in_area(area: Area2D, point: Vector2) -> bool:
	var collision_shape := area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		push_error("Area2D has no CollisionShape2D child!")
		return false
	
	var shape: Shape2D = collision_shape.shape
	if shape is CircleShape2D:
		var radius: float = shape.radius
		var local_point := area.to_local(point)
		return local_point.length() <= radius
	
	push_error("Unsupported shape: %s" % shape)
	return false
