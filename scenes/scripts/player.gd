extends KinematicBody

#состояния
enum {IDLE, RUN, WALL_RUN, FALLING}
var state = IDLE
var can_control = false

var start_spd = 10 #стартовая скорость
var max_spd = 25 #максимальная скорость
var spd = 10 #текущая скорость
var vel = Vector3(0,0,0) #вектор движения
var mouse_delta = Vector2() #хранит в себе перемещение мышки
var max_hp = 100 #максимальное hp
var hp = 100 #хп игрока
var score = 0 #очки
var enemy_score = 0 #очки оппонента
var can_doublejump = 1 #заполняется постепенно до 1
var doublejump_spd = 0.01
var recoil_offset = Vector3.ZERO #это значение прибавляется к текущей ротации камеры.
var recoil_offset_target = Vector3.ZERO


var notificate_fade = true
var current_weapon

#анимация камеры
var cam_base_rotation = Vector3.ZERO
var shake_intensity = 0
var shake_diff = 0

#ноды
var cam_id

func _ready():
	$multiplayer/nickname.text = Multiplayer.nickname
	$multiplayer/ColorPickerButton.color = Multiplayer.color
	$multiplayer/ip.text = Multiplayer.connect_ip
	$multiplayer/server_settings/rounds_count.value = Multiplayer.max_rounds
	$debug_info/mouse_sens.value = Multiplayer.mouse_sensitivity
	cam_id = $Camera
	current_weapon = $Camera/revolver
	change_weapon(Multiplayer.weapon)
	
	randomize()
	
	$change_weapon.get_popup().connect("id_pressed", self, "change_weapon")
	
	if get_tree().network_peer != null:
		Multiplayer.call_deferred( "_respawn" )
		$change_weapon.visible = false
		$background.queue_free()
		$multiplayer.queue_free()

func _physics_process(delta):
	if not can_control:
		return
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
		vel.x = lerp(vel.x, input_vel.x * -spd, 0.1)
		vel.z = lerp(vel.z, input_vel.z * -spd, 0.1)
	
	#прыжок от пола
	if (state == IDLE or state == RUN) and Input.is_action_pressed("jump"):
		vel.y = 9
	
	#двойной прыжок
	if state == FALLING and can_doublejump==1 and Input.is_action_just_pressed("jump"):
		vel.y = 12
		spd += 4
		can_doublejump = 0
		shake_camera(0.02, 20)
	
	#прыжок от стены
	if state == WALL_RUN and Input.is_action_just_pressed("jump"):
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
			cam_base_rotation.z = lerp(cam_base_rotation.z, 15, 0.1)
		else:
			cam_base_rotation.z = lerp(cam_base_rotation.z, -15, 0.1)
	else:
		cam_base_rotation.z = lerp(cam_base_rotation.z, 0, 0.1)
	
	#анимация наклона камеры при стрейфе
	if state == FALLING or state == RUN:
		if Input.is_action_pressed("move_left"):
			cam_base_rotation.z = lerp(cam_base_rotation.z, 15, 0.02)
		if Input.is_action_pressed("move_right"):
			cam_base_rotation.z = lerp(cam_base_rotation.z, -15, 0.02)
	
	#анимация пушки при беге по стенам
	if state == WALL_RUN:
		current_weapon.rotation_degrees.z = lerp(current_weapon.rotation_degrees.z, $Camera/slide_position.rotation_degrees.z, 0.1)
	else:
		current_weapon.rotation_degrees.z = lerp(current_weapon.rotation_degrees.z, $Camera/default_position.rotation_degrees.z, 0.1)
	
	var test = move_and_slide(vel, Vector3.UP, true)
	if state == WALL_RUN:
		spd = clamp(test.length(), start_spd, 999)
	
	#поворот камеры мышкой
	cam_base_rotation.x -= mouse_delta.y * Multiplayer.mouse_sensitivity
	rotation_degrees.y -= mouse_delta.x * Multiplayer.mouse_sensitivity
	
	#компенсация отдачи
	cam_id.rotation_degrees = cam_base_rotation + recoil_offset
	
	recoil_offset = lerp(recoil_offset, recoil_offset_target, 0.1)
	recoil_offset_target = lerp(recoil_offset_target, Vector3.ZERO, 0.1)
	
	cam_id.rotation_degrees.x = clamp(cam_id.rotation_degrees.x,-89,89)
	
	mouse_delta.y = 0
	mouse_delta.x = 0
	
	spd = clamp(spd, 0, max_spd)
	can_doublejump = clamp(can_doublejump+doublejump_spd, 0, 1)
	
func _process(delta):
	#показ выбора оружия при конце матча
	if enemy_score >= Multiplayer.max_rounds or score >= Multiplayer.max_rounds:
		$change_weapon.visible = true
	
	
	#встряска камеры
	$Camera.h_offset = rand_range(-shake_intensity,shake_intensity)
	$Camera.v_offset = rand_range(-shake_intensity,shake_intensity)
	shake_intensity = clamp(shake_intensity-shake_diff, 0, 1)
	
	sync_stats()
	$crosshair/Control/hit_marker.modulate.a-=0.1
	$GUI/damage_indicator.modulate.a = lerp($GUI/damage_indicator.modulate.a, 0, 0.05)
	$GUI/score_indicator.color.a = lerp($GUI/score_indicator.color.a, 0, 0.1)
	Multiplayer.mouse_sensitivity = $debug_info/mouse_sens.value
	
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
#	if Input.is_action_just_pressed("grab_revolver"):
#		current_weapon.visible = false
#		current_weapon = $Camera/revolver
#		current_weapon.transform = $Camera/grab_position.transform
#		current_weapon.visible = true
#
#	if Input.is_action_just_pressed("grab_shotgun"):
#		current_weapon.visible = false
#		current_weapon = $Camera/shotgun
#		current_weapon.transform = $Camera/grab_position.transform
#		current_weapon.visible = true
#
#	if Input.is_action_just_pressed("grab_rifle"):
#		current_weapon.visible = false
#		current_weapon = $Camera/rifle
#		current_weapon.transform = $Camera/grab_position.transform
#		current_weapon.visible = true
	
	if Input.is_action_pressed("RMB"):
		current_weapon.transform = current_weapon.transform.interpolate_with($Camera/zoom_position.transform, 0.1)
	else:
		current_weapon.transform = current_weapon.transform.interpolate_with($Camera/default_position.transform, 0.1)
	
	if Input.is_action_just_pressed("debug"):
		$debug_info.visible = not $debug_info.visible
	
	if Input.is_action_just_pressed("mouse_mode"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$GUI/quit_game.visible = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$GUI/quit_game.visible = false
	"""
	if Input.is_action_just_pressed("ui_up"):
		translation.y += 10
	"""
	
	if hp <= 0:
		restart()
	
	if translation.y < -10:
		restart()
	
	if notificate_fade:
		$GUI/notification.modulate.a -= 0.01
	
	if not can_control:
		return
	
	if Input.is_action_just_pressed("reload") and not Input.is_action_pressed("RMB"):
		current_weapon.reload()
	

	
	if Input.is_action_pressed("LMB"):
		current_weapon.shoot()
	
	
func _input(event):
	#получаем сдвиг мыши
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func restart():
	enemy_score += 1
	global_transform.origin = Vector3(500,1,500)
	can_control = false
	if enemy_score >= Multiplayer.max_rounds:
		hp = max_hp
		vel = Vector3(0,0,0)
		Multiplayer.pass_score()
		$change_weapon.visible = true
		
		var message = Multiplayer.enemy_nickname + " Выиграл!"
		Multiplayer.win(message)
		
		return
	
	$card_choice.show()
	hp = max_hp
	vel = Vector3(0,0,0)
	Multiplayer.pass_score()
	current_weapon.ammo = current_weapon.max_ammo

func notificate(message:String, time:float):
	notificate_fade = false
	$GUI/notification/timer.start(time)
	$GUI/notification/Label.text = message
	$GUI/notification.modulate.a = 1

func shake_camera(intensity, time):
	shake_intensity+=intensity
	shake_diff = shake_intensity/time

func take_hit(damage):
	hp-=damage
	$GUI/damage_indicator.modulate.a += 0.7

func get_score():
	score+=1
	hp = max_hp
	$GUI/score_indicator.color.a = 0.25

func hit_marker():
	$crosshair/Control/hit_marker.modulate.a = 1.5

func sync_stats():
	$debug_info/stats.text = "\nstate " + String(state)
	$debug_info/stats.text += "\nHP " + String(hp)
	$debug_info/stats.text += "\nscore " + String(score)
	$debug_info/stats.text += "\nammo " + String(current_weapon.ammo)
	$debug_info/stats.text += "\ndouble jump " + String(can_doublejump)
	$debug_info/stats.text += "\nvelocity vec " + String(vel.length())
	$debug_info/stats.text += "\nspeed " + String(spd)
	
	$GUI/doublejump_progress.value = can_doublejump
	$GUI/HP.value = lerp($GUI/HP.value, hp, 0.1)
	$GUI/HP2.value = $GUI/HP.value
	$GUI/HP2/score.text = str(score)
	$GUI/HP2/enemy_score.text = str(enemy_score)
	$GUI/HP/ammo_label.text = str(current_weapon.ammo)
	$GUI/HP/hp_label.text = str(hp)
	


func _on_connect_pressed():
	Multiplayer.connect_ip = $multiplayer/ip.text
	Multiplayer.nickname = $multiplayer/nickname.text
	Multiplayer.color = $multiplayer/ColorPickerButton.color
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$background.queue_free()
	$multiplayer.queue_free()
	$change_weapon.visible = false
	Multiplayer.server_connect($multiplayer/ip.text)


func _on_create_pressed():
	Multiplayer.nickname = $multiplayer/nickname.text
	Multiplayer.color = $multiplayer/ColorPickerButton.color
	Multiplayer.max_rounds = $multiplayer/server_settings/rounds_count.value
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$background.queue_free()
	$multiplayer.queue_free()
	$change_weapon.visible = false
	Multiplayer.server_create()


func change_weapon(id):
	Multiplayer.weapon = id
	current_weapon.visible = false
	match id:
		0:
			current_weapon = $Camera/revolver
		1:
			current_weapon = $Camera/shotgun
		2:
			current_weapon = $Camera/rifle
	
	current_weapon.transform = $Camera/grab_position.transform
	current_weapon.visible = true


func _on_notification_timer_timeout():
	notificate_fade = true


func _on_quit_game_pressed():
	Multiplayer.peer.close_connection()
	Multiplayer.peer = null
	get_tree().network_peer = null
	get_tree().reload_current_scene()
