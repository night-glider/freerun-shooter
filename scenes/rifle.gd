extends Spatial
var trail = preload("res://scenes/bullet_trail.tscn")
var max_ammo = 30
var damage = 15
var ammo = max_ammo
var can_shoot = true

func shoot():
	if can_shoot and ammo > 0 and not $AnimationPlayer.is_playing():
		$shoot_here/RayCast.rotation_degrees.x = rand_range(-1,1)
		$shoot_here/RayCast.rotation_degrees.y = rand_range(-1,1)
		$shoot_here/RayCast.rotation_degrees.z = rand_range(-1,1)
		
		ammo-=1
		can_shoot = false
		$cooldown.start()
		$shoot_here/Particles.restart()
		$shoot_here/Particles.emitting = true
		var new_trail = trail.instance()
		new_trail.scale.z = 10
		get_tree().get_root().add_child(new_trail)
		new_trail.global_transform.basis = $shoot_here/RayCast.global_transform.basis
		new_trail.global_transform.origin = $shoot_here/RayCast.global_transform.origin
		if $shoot_here/RayCast.is_colliding():
			new_trail.scale.z = $shoot_here/RayCast.get_collision_point().distance_to(global_transform.origin)
			get_parent().get_parent().get_parent().create_trail($shoot_here/RayCast.get_collision_point())
		else:
			new_trail.scale.z = $shoot_here/RayCast.cast_to.length()
			get_parent().get_parent().get_parent().create_trail($shoot_here/RayCast.global_transform.origin + $shoot_here/RayCast.global_transform.basis.z * -300)
		translation.z += 0.1
		rotation_degrees.x += 0
		rotation_degrees.z = +rand_range(-5,5)
		get_parent().rotation_degrees.x+=0.1
		get_parent().rotation_degrees.y += rand_range(-0.2,0.2)
		
		if $shoot_here/RayCast.is_colliding():
			var body = $shoot_here/RayCast.get_collider()
			if body.is_in_group("can_be_hit"):
				get_parent().get_parent().hit_marker()
				body.get_hit(damage)
		

func reload():
	ammo = max_ammo
	$AnimationPlayer.play("reload")

func _process(delta):
	pass


func _on_cooldown_timeout():
	can_shoot = true
