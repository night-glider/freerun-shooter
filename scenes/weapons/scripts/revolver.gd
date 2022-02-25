extends Spatial
var trail = preload("res://scenes/weapons/bullet_trail.tscn")
var max_ammo = 6
var ammo = 6
var damage = 80
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
		
		for i in 3:
			$shoot_here/projectile_pos.rotation_degrees.y = (i+1) * 5
			var trans:Transform = $shoot_here/projectile_pos.global_transform
			var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * 1
			var accel = Vector3.ZERO
			var time = OS.get_system_time_msecs()
			get_node("/root/world").rpc("create_projectile",trans, accel, velocity, 25, time)
		for i in 3:
			$shoot_here/projectile_pos.rotation_degrees.y = (i+1) * -5
			var trans:Transform = $shoot_here/projectile_pos.global_transform
			var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * 1
			var accel = Vector3.ZERO
			var time = OS.get_system_time_msecs()
			get_node("/root/world").rpc("create_projectile",trans, accel, velocity, 25, time)
		
		$shoot_here/projectile_pos.rotation_degrees.y = 0
		var trans:Transform = $shoot_here/projectile_pos.global_transform
		var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * 1
		var accel = Vector3.ZERO
		var time = OS.get_system_time_msecs()
		get_node("/root/world").rpc("create_projectile",trans, accel, velocity, 25, time)
		
		
		
		translation.z = -0.1
		rotation_degrees.x = 45

func zoom():
	pass

func unzoom():
	pass

func reload():
	baraban_spd = 10
	ammo = max_ammo
	$AnimationPlayer.play("reload")

func _process(delta):
	$revolverA/Spatial.rotation_degrees.x+=baraban_spd
	baraban_spd = lerp(baraban_spd, 0, 0.015)


func _on_cooldown_timeout():
	can_shoot = true
