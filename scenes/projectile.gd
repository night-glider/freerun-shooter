extends Spatial

var start_pos:Vector3
var acceleration:Vector3
var velocity:Vector3
var start_time:int
var damage:float
var scale_modifier:float


func init(start_trans:Transform, accel:Vector3, vel:Vector3, scale_modifier:float, dam:float, color:Color, time:int):
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
	var diff = OS.get_system_time_msecs() - start_time
	diff /= 16.66667
	global_transform.origin = start_pos + velocity * diff + acceleration * (diff * diff)
	
	velocity -= acceleration * diff
	#print("created")
	

func _physics_process(delta):
	look_at(global_transform.origin + velocity, Vector3.UP)
	$RayCast.cast_to = Vector3(0,0,-1) * velocity.length()
	$RayCast.force_update_transform()
	$RayCast.force_raycast_update()
	var test = $RayCast.get_collider()
	
	if test is PhysicsBody:
		#print("collided with" + test.name)
		_on_Area_body_entered(test)
	if test is Area:
		#print("collided with" + test.name)
		_on_Area_area_entered(test)
	if test == null:
		pass
		
		#print("null")
	
	global_transform.origin += velocity
	velocity-=acceleration


func _on_Area_body_entered(body):
	if body.is_in_group("friend"):
		return
	
	#get_node("/root/world").projectile_destroy_effect(global_transform)
	queue_free()
	#print("collided with " + body.name)

func _on_Area_area_entered(area):
	if area.is_in_group("enemy"):
		get_parent().damage(damage)
		queue_free()
	#get_node("/root/world").projectile_destroy_effect(global_transform)
	#print("collided with area")


func _on_Timer_timeout():
	queue_free()
