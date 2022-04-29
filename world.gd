extends Spatial

const classic = preload("res://maps/classic.tscn")
const neocity = preload("res://maps/neocity.tscn")
const concrete_bamboo = preload("res://maps/concrete_bamboo.tscn")
const hexbowl = preload("res://maps/hexbowl.tscn")
const float_debris = preload("res://maps/float_debris.tscn")
const dellusion = preload("res://maps/dellusion.tscn")

func _ready():
	Multiplayer.world = self
	Multiplayer.player = $player
	Multiplayer.enemy = $enemy

func change_map(map_id):
	var new_map = classic
	match map_id:
		0:
			new_map = classic
		1:
			new_map = neocity
		2:
			new_map = concrete_bamboo
		3:
			new_map = hexbowl
		4:
			new_map = float_debris
		5:
			new_map = dellusion
	get_node("map").free()
	var new_map_instance = new_map.instance()
	add_child(new_map_instance)
	new_map_instance.name = "map"
