extends Container
signal ProgressComplete

var filling: bool = false
const DEFAULT_FILL_SPEED: float = 100.0
var fill_speed: float = DEFAULT_FILL_SPEED

func _ready() -> void:
	$ProgressBar.value = 0
	hide()

func _process(delta: float) -> void:
	# follow the mouse
	var mouse_pos = get_global_mouse_position()
	position = mouse_pos + Vector2(-10, 20)
	
	if filling:
		$ProgressBar.value += delta * fill_speed
		if $ProgressBar.value >= 100:
			filling = false
			emit_signal("ProgressComplete")

func start(speed: float = 0) -> void:
	fill_speed = speed if speed > 0 else DEFAULT_FILL_SPEED
	filling = true
	$ProgressBar.value = 0
	show()

func stop() -> void:
	$ProgressBar.value = 0
	hide()
