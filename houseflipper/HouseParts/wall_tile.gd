#@tool
extends StaticBody3D
class_name WallTile

## The material this wall tile will render with initally, before renovation
@export var initialMaterial: StandardMaterial3D :
	set(value):
		$MeshInstance3D.mesh.material = value
		initialMaterial = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if initialMaterial:
		$MeshInstance3D.mesh.material = initialMaterial
	else:
		push_warning("No material set for ", self, ", using no material.")
