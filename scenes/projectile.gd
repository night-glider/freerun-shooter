extends Spatial

var start_pos:Vector3
var acceleration:Vector3
var velocity:Vector3
var start_time:int
var damage:float
var scale_modifier:float


func init(start_trans:Transform, accel:Vector3, vel:Vector3, dam:float, time:int):
	global_transform = start_trans
	start_pos = start_trans.origin
	acceleration = accel
	velocity = vel
	damage = dam
	scale.x = 1 + damage/50
	scale.y = 1 + damage/50
	scale.z = 1 + damage/50
	start_time = time
	var diff = OS.get_system_time_msecs() - start_time
	diff /= 16.66667
	global_transform.origin = start_pos + velocity * diff + acceleration * (diff * diff)
	
	velocity -= acceleration * diff
	print("created")
	

func _process(delta):
	global_transform.origin += velocity
	velocity-=acceleration

func _on_Area_body_entered(body):
	queue_free()
	print("collided with " + body.name)

func _on_Area_area_entered(area):
	if area.is_in_group("projectile"):
		return
	
	if area.name == "enemy":
		get_parent().damage(damage)
	queue_free()
	print("collided with area")
