extends CenterContainer

class_name InventoryItem
signal clicked

@export var tex: Texture2D
@export var itemName: String
@export var selected: bool = false

func _ready() -> void:
	$TextureButton.texture_normal = tex
	if not selected:
		$Selected.hide()

func select(on :bool) -> void:
	selected = on
	if selected:
		$Selected.show()
	else:
		$Selected.hide()


func _on_texture_button_button_down() -> void:
	emit_signal("clicked", self)
