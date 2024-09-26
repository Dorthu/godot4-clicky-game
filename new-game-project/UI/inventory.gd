extends Control

class_name Inventory
signal item_changed

@onready var selectedItem: InventoryItem = $VBoxContainer/InventoryItem
var camCopier: Node3D

func _on_inventory_item_clicked(clicked: InventoryItem) -> void:
	for c in $VBoxContainer.get_children():
		c.select(false)
	
	$CameraFeed.hide()
	clicked.select(true)
	selectedItem = clicked
	if selectedItem.itemName == "camera":
		$CameraFeed.show()
	emit_signal("item_changed", clicked)

func registerCamera(cam: Node3D) -> void:
	camCopier = cam

func _process(delta: float) -> void:
	if camCopier:
		$CameraFeed/ViewportContainer/SubViewport/Camera3D.global_transform = camCopier.global_transform
