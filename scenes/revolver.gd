extends Spatial
var trail = preload("res://scenes/bullet_trail.tscn")
var max_ammo = 6
var ammo = 6
var can_shoot = true
var baraban_spd = 0

func shoot():
	if can_shoot and ammo > 0:
		ammo-=1
		can_shoot = false
		$cooldown.start()
		$shoot_here/Particles.restart()
		$shoot_here/Particles.emitting = true
		baraban_spd = 5
		var new_trail = trail.instance()
		new_trail.scale.z = 10
		get_tree().get_root().add_child(new_trail)
		new_trail.global_transform.basis = $shoot_here.global_transform.basis
		new_trail.global_transform.origin = $shoot_here.global_transform.origin
		new_trail.scale.z = $shoot_here/RayCast.get_collision_point().distance_to(global_transform.origin)
		translation.z = -0.1
		rotation_degrees.x = 45
		
		if $shoot_here/RayCast.is_colliding():
			var body = $shoot_here/RayCast.get_collider()
			if body.is_in_group("can_be_hit"):
				body.get_hit()
		

func reload():
	baraban_spd = 10
	ammo = max_ammo
	$AnimationPlayer.play("reload")

func _process(delta):
	$revolverA/Spatial.rotation_degrees.x+=baraban_spd
	baraban_spd = lerp(baraban_spd, 0, 0.015)
	
	#if Input.is_action_just_released("MMB"):
	#	$revolverA/Spatial.spd += 10


func _on_cooldown_timeout():
	can_shoot = true
