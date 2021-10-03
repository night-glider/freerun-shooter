extends KinematicBody

#состояния
enum {IDLE, RUN, WALL_RUN, FALLING}
var state = IDLE

var start_spd = 10 #стартовая скорость
var max_spd = 35 #максимальная скорость
var spd = 10 # текущая скорость
var mouse_sensitivity = 0.1 #чувствительность мыши
var vel = Vector3(0,0,0) #вектор движения
var mouse_delta = Vector2() #хранит в себе перемещение мышки
var hp = 100 #хп игрока
var score = 0 #очки
var enemy_score = 0 #очки оппонента
var can_doublejump = 1 #заполняется постепенно до 1
var doublejump_spd = 0.01

var current_weapon

#анимация камеры
var shake_intensity = 0
var shake_diff = 0

#ноды
var cam_id


func _ready():
	cam_id = $Camera
	current_weapon = $Camera/revolver
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	randomize()


func _physics_process(delta):
	var forward = transform.basis.z #базисный вектор по z относительно игрока
	var right = transform.basis.x #базисный вектор по x относительно игрока
	var is_on_floor = $RayCast.is_colliding() or is_on_floor()
	var input_vel := Vector3() #направление нашего движения, исходя из input'ов
	
	#обработка состояний
	if is_on_floor and not Input.is_action_pressed("move_forward"):
		state = IDLE
	if is_on_floor and vel.length() > 0:
		state = RUN
	if not is_on_floor():
		state = FALLING
	if is_on_wall() and not is_on_floor and Input.is_action_pressed("move_forward"):
		state = WALL_RUN
	
	
	if is_on_floor: 
		spd = lerp(spd, start_spd, 0.1)
		vel.x = 0
		vel.z = 0
	
	if state == FALLING:
		vel.y -= 20 * delta
	
	if state == WALL_RUN:
		if vel.y < 0:
			vel.y = -1 * delta
		else:
			vel.y -= 7 * delta
	
	
	#управление
	if Input.is_action_pressed("move_forward"):
		input_vel += forward
	
	if Input.is_action_pressed("move_backward"):
		input_vel += -forward
	
	if Input.is_action_pressed("move_left"):
		input_vel += right
	
	if Input.is_action_pressed("move_right"):
		input_vel += -right
	
	input_vel = input_vel.normalized()
	
	if is_on_floor:
		vel+=input_vel * -spd
	
	if state == FALLING:
		var test_var = Vector2(vel.x, vel.z)
		#vel.x = lerp(vel.x, input_vel.x * -test_var.length(), 0.1)
		#vel.z = lerp(vel.z, input_vel.z * -test_var.length(), 0.1)
		vel.x = lerp(vel.x, input_vel.x * -spd, 0.1)
		vel.z = lerp(vel.z, input_vel.z * -spd, 0.1)
	
	#прыжок от пола
	if (state == IDLE or state == RUN) and Input.is_action_pressed("jump"):
		vel.y = 9
	
	#двойной прыжок
	if state == FALLING and can_doublejump==1 and Input.is_action_just_pressed("jump"):
		vel.y = 12
		#spd*=1.2
		spd += 4
		can_doublejump = 0
		shake_camera(0.02, 20)
	
	#толкание в стену
	#if state == WALL_RUN:
		#pass
		#vel += get_slide_collision(0).normal * -(2)
		#move_and_slide(get_slide_collision(0).normal * -(vel.length()), Vector3(0,1,0))
	
	#прыжок от стены
	if state == WALL_RUN and Input.is_action_just_pressed("jump"):
		#spd*=1.2
		spd += 4
		vel = forward * -spd
		vel.y = 9
		state = FALLING
		vel+=get_slide_collision(0).normal * 20
	
	#анимация бега по стенам
	if state == WALL_RUN:
		var vec1 = Vector2(get_slide_collision(0).normal.x, get_slide_collision(0).normal.z)
		var vec2 = Vector2(forward.x, forward.z)
		if vec1.angle_to(vec2) <= 0:
			cam_id.rotation_degrees.z = lerp(cam_id.rotation_degrees.z, 15, 0.1)
		else:
			cam_id.rotation_degrees.z = lerp(cam_id.rotation_degrees.z, -15, 0.1)
	else:
		cam_id.rotation_degrees.z = lerp(cam_id.rotation_degrees.z, 0, 0.1)
	
	#анимация наклона камеры при стрейфе
	if state == FALLING or state == RUN:
		if Input.is_action_pressed("move_left"):
			cam_id.rotation_degrees.z = lerp(cam_id.rotation_degrees.z, 15, 0.02)
		if Input.is_action_pressed("move_right"):
			cam_id.rotation_degrees.z = lerp(cam_id.rotation_degrees.z, -15, 0.02)
	
	#анимация пушки при беге по стенам
	if state == WALL_RUN:
		current_weapon.rotation_degrees.z = lerp(current_weapon.rotation_degrees.z, $Camera/slide_position.rotation_degrees.z, 0.1)
	else:
		current_weapon.rotation_degrees.z = lerp(current_weapon.rotation_degrees.z, $Camera/default_position.rotation_degrees.z, 0.1)
	
	var test = move_and_slide(vel, Vector3.UP, true)
	if state == WALL_RUN:
		spd = clamp(test.length(), start_spd, 999)
	
	#поворот камеры мышкой
	cam_id.rotation_degrees.x -= mouse_delta.y * mouse_sensitivity
	rotation_degrees.y -= mouse_delta.x * mouse_sensitivity
	
	cam_id.rotation_degrees.x = clamp(cam_id.rotation_degrees.x,-80,80)
	
	mouse_delta.y = 0
	mouse_delta.x = 0
	
	spd = clamp(spd, 0, max_spd)
	can_doublejump = clamp(can_doublejump+doublejump_spd, 0, 1)
	
func _process(delta):
	#встряска камеры
	$Camera.h_offset = rand_range(-shake_intensity,shake_intensity)
	$Camera.v_offset = rand_range(-shake_intensity,shake_intensity)
	shake_intensity = clamp(shake_intensity-shake_diff, 0, 1)
	
	sync_stats()
	$crosshair/Control/hit_marker.modulate.a-=0.1
	$GUI/damage_indicator.modulate.a = lerp($GUI/damage_indicator.modulate.a, 0, 0.05)
	$GUI/score_indicator.color.a = lerp($GUI/score_indicator.color.a, 0, 0.1)
	mouse_sensitivity = $debug_info/mouse_sens.value
	
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if Input.is_action_just_pressed("grab_revolver"):
		current_weapon.visible = false
		current_weapon = $Camera/revolver
		current_weapon.transform = $Camera/grab_position.transform
		current_weapon.visible = true
	
	if Input.is_action_just_pressed("grab_shotgun"):
		current_weapon.visible = false
		current_weapon = $Camera/shotgun
		current_weapon.transform = $Camera/grab_position.transform
		current_weapon.visible = true
	
	if Input.is_action_just_pressed("grab_rifle"):
		current_weapon.visible = false
		current_weapon = $Camera/rifle
		current_weapon.transform = $Camera/grab_position.transform
		current_weapon.visible = true
	
	if Input.is_action_just_pressed("reload") and not Input.is_action_pressed("RMB"):
		current_weapon.reload()
	
	if Input.is_action_pressed("RMB"):
		current_weapon.transform = current_weapon.transform.interpolate_with($Camera/zoom_position.transform, 0.1)
		current_weapon.zoom()
	else:
		current_weapon.transform = current_weapon.transform.interpolate_with($Camera/default_position.transform, 0.1)
		current_weapon.unzoom()
	
	if Input.is_action_pressed("LMB"):
		current_weapon.shoot()
	
	if Input.is_action_just_pressed("debug"):
		$debug_info.visible = not $debug_info.visible
	
	if Input.is_action_just_pressed("mouse_mode"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	"""
	if Input.is_action_just_pressed("ui_up"):
		translation.y += 10
	"""
	
	if hp <= 0:
		restart()
	
	if translation.y < -10:
		restart()
	
	
func _input(event):
	#получаем сдвиг мыши
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func restart():
	enemy_score += 1
	hp = 100
	vel = Vector3(0,0,0)
	get_parent().pass_score()
	current_weapon.ammo = current_weapon.max_ammo
	
	var far_spawnpoint = get_parent().get_node("spawnpoints/spawnpoint1")
	for element in get_parent().get_node("spawnpoints").get_children():
		if element.global_transform.origin.distance_to(get_parent().get_node("enemy").global_transform.origin) > far_spawnpoint.global_transform.origin.distance_to(get_parent().get_node("enemy").global_transform.origin):
			far_spawnpoint = element
	
	global_transform.origin = far_spawnpoint.global_transform.origin
	

func shake_camera(intensity, time):
	shake_intensity+=intensity
	shake_diff = shake_intensity/time

func take_hit(damage):
	hp-=damage
	$GUI/damage_indicator.modulate.a += 0.7

func get_score():
	score+=1
	hp = clamp(hp+50, 0, 100)
	$GUI/score_indicator.color.a = 0.25

func hit_marker():
	$crosshair/Control/hit_marker.modulate.a = 1.5

func sync_stats():
	$debug_info/stats.text = "\nсостояние " + String(state)
	$debug_info/stats.text += "\nHP " + String(hp)
	$debug_info/stats.text += "\nочки " + String(score)
	$debug_info/stats.text += "\nпатроны " + String(current_weapon.ammo)
	$debug_info/stats.text += "\nдвойной прыжок " + String(can_doublejump)
	$debug_info/stats.text += "\nвектор движения " + String(vel.length())
	$debug_info/stats.text += "\nскорость " + String(spd)
	
	$GUI/doublejump_progress.value = can_doublejump
	$GUI/HP.value = lerp($GUI/HP.value, hp, 0.1)
	$GUI/score.text = "ОЧКИ:" + str(score)
	$GUI/enemy_score.text = "ОЧКИ ОППОНЕНТА:" + str(enemy_score)
	$GUI/ammo.text = str(current_weapon.ammo) + "/" + str(current_weapon.max_ammo)
	$GUI/HP/hp_label.text = str(hp)
	


func _on_connect_pressed():
	$multiplayer.queue_free()
	get_parent().server_connect($multiplayer/ip.text)


func _on_create_pressed():
	$multiplayer.queue_free()
	get_parent().server_create()


func _on_reset_score_pressed():
	score = 0
	enemy_score = 0
