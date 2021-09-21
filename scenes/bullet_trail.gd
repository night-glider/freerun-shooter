extends Spatial

func _ready():
	pass # Replace with function body.

func _process(delta):
	$MeshInstance.get_surface_material(0).albedo_color.a-=0.01
	if $MeshInstance.get_surface_material(0).albedo_color.a < 0:
		queue_free()
