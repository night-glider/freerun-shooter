extends Spatial
var trail = preload("res://scenes/weapons/bullet_trail.tscn")
var network_active = false

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

remote func _set_pos(trans:Transform):
	$enemy.set_pos(trans)

remote func _take_hit(damage:int):
	$player.take_hit(damage)
	

###DEPRECATED GAME HAS NO HITSCAN NOW
#remote func _trail(end_point : Vector3):
#	var new_gun_trail = trail.instance()
#	add_child(new_gun_trail)
#	new_gun_trail.global_transform.origin = $enemy/shoot_pos.global_transform.origin
#	new_gun_trail.look_at(end_point, Vector3.UP)
#	new_gun_trail.scale.z = new_gun_trail.global_transform.origin.distance_to(end_point)
#	new_gun_trail.get_node("MeshInstance").get_surface_material(0).albedo_color = Color.red

#func create_trail(end_point : Vector3):
#	rpc_unreliable("_trail", end_point)

remote func _score():
	$player.get_score()

func damage(damage:int):
	rpc("_take_hit", damage)


func pass_score():
	rpc("_score")

func server_create():
	var peer = NetworkedMultiplayerENet.new()
	peer.always_ordered = false
	peer.transfer_mode = NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE
	peer.create_server(6969, 10)
	get_tree().network_peer = peer
	#OS.alert("server_created")


func server_connect(ip:String):
	var peer = NetworkedMultiplayerENet.new()
	peer.always_ordered = false
	peer.transfer_mode = NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE
	peer.create_client(ip, 6969)
	get_tree().network_peer = peer
	#OS.alert("connected")

func _process(delta):
	if network_active:
		rpc_unreliable("_set_pos", $player.transform)

func _player_connected(id):
	network_active = true

func _player_disconnected(id):
	OS.alert("disconected")


remotesync func create_projectile(start:Transform, accel:Vector3, vel:Vector3, damage:float, time:int):
	var proj = preload("res://scenes/projectile.tscn").instance()
	add_child(proj)
	proj.init(start, accel, vel, damage, time)
	
