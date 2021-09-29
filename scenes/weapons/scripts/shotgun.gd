extends Spatial
var trail = preload("res://scenes/weapons/bullet_trail.tscn")
var max_ammo = 1
var ammo = 1
var damage = 10
var can_shoot = true

func shoot():
	if can_shoot and ammo > 0:
		ammo-=1
		can_shoot = false
		$shoot_here/Particles.restart()
		$shoot_here/Particles.emitting = true
		for i in 10:
			$shoot_here/RayCast.rotation_degrees.x = rand_range(-5,5)
			$shoot_here/RayCast.rotation_degrees.y = rand_range(-5,5)
			$shoot_here/RayCast.rotation_degrees.z = rand_range(-5,5)
			$shoot_here/RayCast.force_raycast_update()
			var new_trail = trail.instance()
			get_tree().get_root().add_child(new_trail)
			new_trail.global_transform.basis = $shoot_here/RayCast.global_transform.basis
			new_trail.global_transform.origin = $shoot_here/RayCast.global_transform.origin
			if $shoot_here/RayCast.is_colliding():
				new_trail.scale.z = $shoot_here/RayCast.get_collision_point().distance_to(global_transform.origin)
				get_parent().get_parent().get_parent().create_trail($shoot_here/RayCast.get_collision_point())
			else:
				new_trail.scale.z = $shoot_here/RayCast.cast_to.length()
				get_parent().get_parent().get_parent().create_trail($shoot_here/RayCast.global_transform.origin + $shoot_here/RayCast.global_transform.basis.z * -300)
			
			if $shoot_here/RayCast.is_colliding():
				var body = $shoot_here/RayCast.get_collider()
				if body.is_in_group("can_be_hit"):
					get_parent().get_parent().hit_marker()
					body.get_hit(damage)
		
		translation.z += 0.5
		rotation_degrees.x = 5
		get_parent().get_parent().shake_camera(0.05, 10)

func reload():
	$cooldown.start()
	can_shoot = false
	ammo = max_ammo
	$AnimationPlayer.play("reload")

func zoom():
	pass

func unzoom():
	pass

func _process(delta):
	pass


func _on_cooldown_timeout():
	can_shoot = true
