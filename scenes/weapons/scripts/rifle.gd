extends Spatial
var trail = preload("res://scenes/weapons/bullet_trail.tscn")
var max_ammo = 30
var damage = 15
var bullet_spd = 1
var bullet_gravity = 0.0025
var bullet_scale_modifier = 1
var ammo = max_ammo
var can_shoot = true

var spread = 1

func shoot():
	if can_shoot and ammo > 0 and not $AnimationPlayer.is_playing():
		$shoot_here/projectile_pos.rotation_degrees.x = rand_range(-spread,spread)
		$shoot_here/projectile_pos.rotation_degrees.y = rand_range(-spread,spread)
		$shoot_here/projectile_pos.rotation_degrees.z = rand_range(-spread,spread)
		
		$shoot_here/projectile_pos.rotation_degrees.y = 0
		var trans:Transform = $shoot_here/projectile_pos.global_transform
		var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * bullet_spd
		var accel = Vector3.UP*bullet_gravity
		var color = get_parent().get_parent().color
		var time = OS.get_system_time_msecs()
		get_node("/root/world").rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time)
		
		ammo-=1
		can_shoot = false
		$cooldown.start()
		$shoot_here/Particles.restart()
		$shoot_here/Particles.emitting = true
		translation.z += 0.1
		rotation_degrees.x += 0
		rotation_degrees.z = +rand_range(-5,5)
		get_parent().rotation_degrees.x+=0.1
		get_parent().rotation_degrees.y += rand_range(-0.2,0.2)
		

func zoom():
	spread = 0

func unzoom():
	spread = 1

func reload():
	ammo = max_ammo
	$AnimationPlayer.play("reload")

func _process(delta):
	pass


func _on_cooldown_timeout():
	can_shoot = true
