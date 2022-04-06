extends Spatial
var trail = preload("res://scenes/weapons/bullet_trail.tscn")
var max_ammo = 6
var ammo = 6
var damage = 50
var bullet_spd = 1
var bullet_gravity = 0.001
var bullet_scale_modifier = 1


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
		
		var trans:Transform = $shoot_here/projectile_pos.global_transform
		var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * bullet_spd
		var accel = Vector3.UP*bullet_gravity
		var color = get_parent().get_parent().color
		var time = OS.get_system_time_msecs()
		get_node("/root/world").rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time)
		
		
		
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
