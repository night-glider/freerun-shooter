extends Spatial
var trail = preload("res://scenes/weapons/bullet_trail.tscn")
var max_ammo = 2
var ammo = 2
var damage = 10
var can_shoot = true

func shoot():
	if can_shoot and ammo > 0:
		ammo-=1
		can_shoot = false
		$cooldown.start()
		$shoot_here/Particles.restart()
		$shoot_here/Particles.emitting = true
		
		for i in 5:
			$shoot_here/projectile_pos.rotation_degrees.y = (i+1) * 4
			var trans:Transform = $shoot_here/projectile_pos.global_transform
			var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * 1
			var accel = Vector3.UP*0.01
			var time = OS.get_system_time_msecs()
			get_node("/root/world").rpc("create_projectile",trans, accel, velocity, 25, time)
		for i in 5:
			$shoot_here/projectile_pos.rotation_degrees.y = (i+1) * -4
			var trans:Transform = $shoot_here/projectile_pos.global_transform
			var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * 1
			var accel = Vector3.UP*0.01
			var time = OS.get_system_time_msecs()
			get_node("/root/world").rpc("create_projectile",trans, accel, velocity, 25, time)
		
		$shoot_here/projectile_pos.rotation_degrees.y = 0
		var trans:Transform = $shoot_here/projectile_pos.global_transform
		var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * 1
		var accel = Vector3.UP*0.01
		var time = OS.get_system_time_msecs()
		get_node("/root/world").rpc("create_projectile",trans, accel, velocity, 25, time)
		
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
