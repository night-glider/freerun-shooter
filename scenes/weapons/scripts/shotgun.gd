extends Spatial
#generic gun properties
export var max_ammo = 22
export var damage = 10 #damage of 1 bullet
export var bullet_spd = 1
export var bullet_gravity = 0.01
export var bullet_scale_modifier = 3
export var spread = 1 #spread in grades
export var multiple_bullet_count = 10
export var multiple_bullet_angle = 10 #angle between bullets in grades
export var multiple_bullet_spread_type = 0 # 0 - horizontal, 1 - random
export var recoil_factor_x = 20
export var recoil_factor_y = 10
export var cooldown_timer = 0.3


var ammo = max_ammo
var can_shoot = true

#generic shoot function
func shoot():
	if can_shoot and ammo > 0:
		var bullet_count = min(ammo, 1 + multiple_bullet_count)
		ammo-=bullet_count
		can_shoot = false
		$cooldown.start(cooldown_timer)
		$shoot_here/Particles.restart()
		$shoot_here/Particles.emitting = true
		#shoot first bullet always in center
		$shoot_here/projectile_pos.rotation_degrees.x = rand_range(-spread, spread)
		$shoot_here/projectile_pos.rotation_degrees.y = rand_range(-spread, spread)
		$shoot_here/projectile_pos.rotation_degrees.z = rand_range(-spread, spread)
		var trans:Transform = $shoot_here/projectile_pos.global_transform
		var velocity:Vector3 = -$shoot_here/projectile_pos.global_transform.basis.z * bullet_spd
		var accel = Vector3.UP*bullet_gravity
		var color = get_parent().get_parent().color
		var time = OS.get_system_time_msecs()
		get_node("/root/world").rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time)
		bullet_count-=1
		
		#shoot remaining bullets
		if multiple_bullet_spread_type == 0:
			var k = -1
			var angle = multiple_bullet_angle/2
			for i in bullet_count:
				if i % 2 == 0 and i > 0:
					angle+=multiple_bullet_angle
				k*=-1
				$shoot_here/projectile_pos.rotation_degrees.x = rand_range(-spread, spread)
				$shoot_here/projectile_pos.rotation_degrees.y = angle * k + rand_range(-spread, spread)
				$shoot_here/projectile_pos.rotation_degrees.z = rand_range(-spread, spread)
				trans = $shoot_here/projectile_pos.global_transform
				velocity = -$shoot_here/projectile_pos.global_transform.basis.z * bullet_spd
				accel = Vector3.UP*bullet_gravity
				color = get_parent().get_parent().color
				time = OS.get_system_time_msecs()
				get_node("/root/world").rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time)
		if multiple_bullet_spread_type == 1:
			for i in bullet_count:
				$shoot_here/projectile_pos.rotation_degrees.x = rand_range(-multiple_bullet_angle, multiple_bullet_angle)
				$shoot_here/projectile_pos.rotation_degrees.y = rand_range(-multiple_bullet_angle, multiple_bullet_angle)
				$shoot_here/projectile_pos.rotation_degrees.z = rand_range(-multiple_bullet_angle, multiple_bullet_angle)
				trans = $shoot_here/projectile_pos.global_transform
				velocity = -$shoot_here/projectile_pos.global_transform.basis.z * bullet_spd
				accel = Vector3.UP*bullet_gravity
				color = get_parent().get_parent().color
				time = OS.get_system_time_msecs()
				get_node("/root/world").rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time)
		
		get_parent().get_parent().recoil_offset_target += Vector3(recoil_factor_x, rand_range(-recoil_factor_y, recoil_factor_y), 0)
		
		#unique code here
		$model.translation.z += 0.5
		$model.rotation_degrees.x = 5

func reload():
	$cooldown.start()
	can_shoot = false
	ammo = max_ammo
	$AnimationPlayer.play("reload")

func _process(delta):
	$model.translation = lerp($model.translation,Vector3.ZERO,0.1)
	$model.rotation_degrees = lerp($model.rotation_degrees, Vector3.ZERO, 0.1)


func _on_cooldown_timeout():
	can_shoot = true
