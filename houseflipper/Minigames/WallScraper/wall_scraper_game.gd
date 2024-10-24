extends Node2D
class_name WallScraperGame

@onready var brushScene: PackedScene = preload("res://Minigames/WallScraper/ScraperBrush.tscn")
var scraping: bool = false
var lastPos: Vector2 = Vector2(0,0)
var scared: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DrawingZone.size = get_viewport_rect().size
	$Jumpscare.hide()

func _process(delta: float) -> void:
	if scared:
		return
	
	# TODO - count as these are revealed instead of doing this stupid setup; also
	# count how many markers are revealed to show progress towards minigame completion
	var revealCount: int = 0
	revealCount += max(min(1, len($Eyeball/A.get_overlapping_areas())), 0)
	revealCount += max(min(1, len($Eyeball/B.get_overlapping_areas())), 0)
	revealCount += max(min(1, len($Eyeball/C.get_overlapping_areas())), 0)
	revealCount += max(min(1, len($Eyeball/D.get_overlapping_areas())), 0)
	revealCount += max(min(1, len($Eyeball/E.get_overlapping_areas())), 0)
	
	if revealCount > 3:
		print("OH NO! ", revealCount)
		scared = true
		$JumpScareAnim.play("jumpscare")

func _unhandled_input(event: InputEvent) -> void:
	if scared:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			scraping = true
		else:
			scraping = false
	
	if event is InputEventMouseMotion:
		if scraping:
			var b = brushScene.instantiate()
			b.position = event["position"] - Vector2(get_viewport().size/2)
			b.rotation += lastPos.angle_to_point(event["position"])
			$DrawingZone.add_child(b)
			var sb = brushScene.instantiate()
			sb.position = event["position"]
			sb.rotation += lastPos.angle_to_point(event["position"])
			sb.get_child(1).hide() # no graphic for this one
			add_child(sb)
		lastPos = event["position"]
