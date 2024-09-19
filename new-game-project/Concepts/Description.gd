extends Area3D

@onready var desc: Label3D = $Description

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	desc.hide()

func _on_body_entered(body: Node3D) -> void:
	print("Body entered")
	$Description.show()


func _on_body_exited(body: Node3D) -> void:
	print("Body exited")
	$Description.hide()
