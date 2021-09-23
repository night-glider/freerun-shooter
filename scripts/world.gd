extends Spatial
var trail = preload("res://scenes/bullet_trail.tscn")
var network_active = false

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

remote func _set_pos(trans:Transform):
	$enemy.set_pos(trans)

remote func _take_hit(damage:int):
	$player.hp-=damage
	
remote func _trail(end_point : Vector3):
	var new_gun_trail = trail.instance()
	add_child(new_gun_trail)
	new_gun_trail.global_transform.origin = $enemy/shoot_pos.global_transform.origin
	new_gun_trail.look_at(end_point, Vector3.UP)
	new_gun_trail.scale.z = new_gun_trail.global_transform.origin.distance_to(end_point)
	new_gun_trail.get_node("MeshInstance").get_surface_material(0).albedo_color = Color.red


func damage(damage:int):
	rpc("_take_hit", damage)

func create_trail(end_point : Vector3):
	rpc_unreliable("_trail", end_point)

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
	pass
