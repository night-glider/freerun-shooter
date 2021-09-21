extends Spatial
#hi there
#TODO - notifyj
"""
var player_id = []
var objects_id = []
var main_player

# Called when the node enters the scene tree for the first time.
func _ready():
	main_player = $player
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

remote func _set_pos(pos):
	var id = get_tree().get_rpc_sender_id()
	get_node(str(id))._set_pos(pos)

remote func _damage():
	main_player.hp-=50
	
remote func _trail(trans : Transform):
	var new_gun_trail = preload("res://scenes/gun_trail.tscn").instance()
	add_child(new_gun_trail)
	new_gun_trail.global_transform = trans


func damage_player(id):
	rpc_id(id, "_damage")

func create_trail(trans : Transform):
	rpc_unreliable("_trail", trans)

func server_create():
	var peer = NetworkedMultiplayerENet.new()
	peer.always_ordered = false
	peer.transfer_mode = NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE
	peer.create_server(6969, 10)
	get_tree().network_peer = peer
	#OS.alert("server_created")
	

func server_connect():
	var peer = NetworkedMultiplayerENet.new()
	peer.always_ordered = false
	peer.transfer_mode = NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE
	peer.create_client($player/LineEdit.text, 6969)
	get_tree().network_peer = peer
	#OS.alert("connected")

func _process(delta):
	if player_id.size() > 0:
		rpc_unreliable("_set_pos", main_player.transform)
		

func _player_connected(id):
	player_id.append(id)
	
	var new_player = preload("res://scenes/second_player.tscn").instance()
	new_player.set_name(str(id))
	add_child(new_player)
	objects_id.append(new_player)

func _player_disconnected(id):
	
	for element in objects_id:
		if element.name == str(id):
			element.queue_free()
			objects_id.erase(element)
	
	player_id.erase(id)
	#OS.alert(str(id) + " disconnected")
"""
func _ready():
	pass
