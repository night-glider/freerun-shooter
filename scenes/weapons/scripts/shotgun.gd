extends Spatial
var trail = preload("res://scenes/weapons/bullet_trail.tscn")
var max_ammo = 2
var ammo = 2
var damage = 10
var bullet_spd = 1
var bullet_gravity = 0.01
var bullet_scale_modifier = 3
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
			var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * bullet_spd
			var accel = Vector3.UP*bullet_gravity
			var color = get_parent().get_parent().color
			var time = OS.get_system_time_msecs()
			get_node("/root/world").rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time)
		for i in 5:
			$shoot_here/projectile_pos.rotation_degrees.y = (i+1) * -4
			var trans:Transform = $shoot_here/projectile_pos.global_transform
			var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * bullet_spd
			var accel = Vector3.UP*bullet_gravity
			var color = get_parent().get_parent().color
			var time = OS.get_system_time_msecs()
			get_node("/root/world").rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time)
		
		$shoot_here/projectile_pos.rotation_degrees.y = 0
		var trans:Transform = $shoot_here/projectile_pos.global_transform
		var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * bullet_spd
		var accel = Vector3.UP*bullet_gravity
		var color = get_parent().get_parent().color
		var time = OS.get_system_time_msecs()
		get_node("/root/world").rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time)
		
		translation.z += 0.5
		rotation_degrees.x = 5
		

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
