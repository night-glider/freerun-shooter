extends Spatial

func _ready():
	Multiplayer.world = self
	Multiplayer.player = $player
	Multiplayer.enemy = $enemy
