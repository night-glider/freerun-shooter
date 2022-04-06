extends Area

var target_trans = Transform()

func change_color(new_col:Color):
	$MeshInstance.mesh.material.albedo_color = new_col

func set_pos(trans:Transform):
	target_trans = trans

func _process(delta):
	transform = transform.interpolate_with(target_trans, 0.1)

func get_hit(damage:int):
	get_parent().damage(damage)
