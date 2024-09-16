extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if(body.name=="ExpBody"):
		var center_position = global_transform.origin
		var direction_to_center = (center_position - body.global_transform.origin).normalized()
		body.apply_impulse(Vector3.ZERO, direction_to_center * 1000)
