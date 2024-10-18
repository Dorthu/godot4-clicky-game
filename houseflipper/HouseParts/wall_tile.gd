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

# returns true if the player is close enough to the wall tile to interact with it
func is_interactable() -> bool:
	var collisions = $ActivationZone.get_overlapping_bodies()
	for c in collisions:
		if c is Player:
			return true
	return false

func set_material(new: BaseMaterial3D) -> void:
	# TODO - probably temporary, as we'll eventually want to track if the state is
	# renovated or unrenovated
	$MeshInstance3D.mesh.material = new
