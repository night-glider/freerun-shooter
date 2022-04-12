extends Spatial

func _ready():
	Multiplayer.world = self
	Multiplayer.player = $player
	Multiplayer.enemy = $enemy
	Multiplayer.spawn_host = $spawnpoints/host
	Multiplayer.spawn_client = $spawnpoints/client
