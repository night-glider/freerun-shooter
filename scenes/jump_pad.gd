extends Spatial

export(int, 10, 40, 2) var force = 24

func _on_Area_body_entered(body):
	if body.name == "player":
		body.vel.y = force
		body.shake_camera(0.02, 60)
