extends StaticBody3D

class_name WallpaperChangeWall

@onready var mesh: MeshInstance3D = $MeshInstance3D
@export var clean: Material
@export var finished: Material
@export var tentacle: bool = false
@onready var activeText: Label3D = $Unfinished
var mode: int = 0

func update(player: Player, item: String) -> void:
	print("Mode ", mode, "; used ", item)
	if mode == 0 and item == "scraper":
		mesh.material_override = clean
		activeText.hide()
		activeText = null
		mode += 1
		if tentacle:
			player.think("Oh jeeze, that's going to need some work.")
	elif !tentacle and mode == 1 and item == "wallpaper":
		mesh.material_override = finished
		activeText = $Finished
		activeText.show()
		mode += 1
	elif mode == 2:
		player.think("All done with this one.")
	else:
		if tentacle and mode == 1:
			player.think("I don't have the tools for this.")
		else:
			player.think("I need to scrape off the old wallpaper, then apply new wallpaper")

func activeFor(body: PhysicsBody3D) -> bool:
	print("Do I overlap ", body, "?")
	print($Area3D.overlaps_body(body))
	return $Area3D.overlaps_body(body)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if activeText:
		activeText.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if activeText:
		activeText.hide()
