extends Spatial

func _on_Area_body_entered(body):
	if body.name == "player":
		body.vel.y = 30
		body.shake_camera(0.02, 60)
