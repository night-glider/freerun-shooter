extends Spatial

#generic gun properties
export var max_ammo = 6
export var damage = 50 #damage of 1 bullet
export var bullet_spd = 1.25
var bullet_gravity = 0.0005
export var bullet_scale_modifier = 1
export var spread = 0 #spread in grades
export var multiple_bullet_count = 0
export var multiple_bullet_angle:float = 5 #angle between bullets in grades
export var multiple_bullet_spread_type = 0 # 0 - horizontal, 1 - random
export var recoil_factor_x = 10
export var recoil_factor_y = 0
export var cooldown_timer = 0.5
export var reload_timer_modif = 1


var ammo = max_ammo
var can_shoot = true

#unique gun properties
var baraban_spd = 0

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
		var color = Multiplayer.color
		var time = OS.get_system_time_msecs()
		var owner_id = get_tree().get_network_unique_id()
		Multiplayer.rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time, owner_id)
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
				color = Multiplayer.color
				time = OS.get_system_time_msecs()
				Multiplayer.rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time, owner_id)
		if multiple_bullet_spread_type == 1:
			for i in bullet_count:
				$shoot_here/projectile_pos.rotation_degrees.x = rand_range(-multiple_bullet_angle, multiple_bullet_angle)
				$shoot_here/projectile_pos.rotation_degrees.y = rand_range(-multiple_bullet_angle, multiple_bullet_angle)
				$shoot_here/projectile_pos.rotation_degrees.z = rand_range(-multiple_bullet_angle, multiple_bullet_angle)
				trans = $shoot_here/projectile_pos.global_transform
				velocity = -$shoot_here/projectile_pos.global_transform.basis.z * bullet_spd
				accel = Vector3.UP*bullet_gravity
				color = Multiplayer.color
				time = OS.get_system_time_msecs()
				Multiplayer.rpc("create_projectile",trans, accel, velocity, bullet_scale_modifier, damage, color, time, owner_id)
		
		get_parent().get_parent().recoil_offset_target += Vector3(recoil_factor_x, rand_range(-recoil_factor_y, recoil_factor_y), 0)
		
		#unique shoot code
		$model.translation.z = 0.2
		$model.rotation_degrees.x = 45
		baraban_spd = 5

func reload():
	can_shoot = false
	ammo = max_ammo
	$AnimationPlayer.playback_speed = reload_timer_modif
	$AnimationPlayer.play("reload")
	$cooldown.stop()
	
	baraban_spd = 10

func _process(delta):
	$model.translation = lerp($model.translation,Vector3.ZERO,0.1)
	$model.rotation_degrees = lerp($model.rotation_degrees, Vector3.ZERO, 0.1)
	
	$model/revolverA/Spatial.rotation_degrees.x+=baraban_spd
	baraban_spd = lerp(baraban_spd, 0, 0.015)

func _on_cooldown_timeout():
	can_shoot = true

func _on_AnimationPlayer_animation_finished(anim_name:String):
	can_shoot = true
