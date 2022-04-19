extends Spatial

var start_pos:Vector3
var acceleration:Vector3
var velocity:Vector3
var start_time:int
var damage:float
var scale_modifier:float
var owner_id:int = 0


func init(start_trans:Transform, accel:Vector3, vel:Vector3, scale_modifier:float, dam:float, color:Color, time:int, own:int):
	global_transform = start_trans
	start_pos = start_trans.origin
	acceleration = accel
	velocity = vel
	damage = dam
	$MeshInstance.get("material/0").albedo_color = color
	scale.x = damage/15
	scale.y = damage/15
	scale.z = damage/15
	scale *= scale_modifier
	start_time = time
	owner_id = own
#	var diff = OS.get_system_time_msecs() - start_time
#	diff = 0
#	print(diff)
#	diff /= 16.66667
#	diff*=-1 #TODO Разобраться почему нужно умножать на -1
#	global_transform.origin = start_pos + velocity * diff + acceleration * (diff * diff)
#
#	velocity -= acceleration * diff
	
	

func _physics_process(delta):
	look_at(global_transform.origin + velocity, Vector3.UP)
	$RayCast.cast_to = Vector3(0,0,-1) * velocity.length()
	$RayCast.force_update_transform()
	$RayCast.force_raycast_update()
	var test = $RayCast.get_collider()
	
	if test is PhysicsBody:
		if $RayCast.get_collision_point().distance_squared_to(global_transform.origin) < 5:
			_on_Area_body_entered(test)
	if test is Area:
		_on_Area_area_entered(test)
	
	global_transform.origin += velocity
	velocity-=acceleration


func _on_Area_body_entered(body):
	if body.is_in_group("friend"):
		return
	queue_free()

func _on_Area_area_entered(area):
	if owner_id != get_tree().get_network_unique_id():
		return
	if area.is_in_group("enemy"):
		Multiplayer.damage(damage)
		Multiplayer.player.hit_marker()
		queue_free()


func _on_Timer_timeout():
	queue_free()
