extends CharacterBody3D
class_name Player

var movement_speed: float = 2.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# load in our graphics
@onready var iForward = preload("res://Actors/playerForwardLeft.png")
@onready var iProfile = preload("res://Actors/playerLeft.png")
@onready var iBack = preload("res://Actors/playerBackLeft.png")
var right: bool = false
var back: bool = false

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	
	# Make sure to not await during _ready.
	# call_deferred("actor_setup")

func _unhandled_input(event: InputEvent) -> void:
	if not get_viewport().get_camera_3d():
		return
		
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		# for clicks, walk there
		var eventPos = event.position
		var worldOrigin = get_viewport().get_camera_3d().project_ray_origin(eventPos)
		var worldNormal = get_viewport().get_camera_3d().project_ray_normal(eventPos)
		
		var collisionMask := 0b0001
		
		var collision = get_world_3d().direct_space_state.intersect_ray(
			PhysicsRayQueryParameters3D.create(worldOrigin, worldOrigin + worldNormal * 100, collisionMask)
		)
		if not collision:
			print("No collision detected")
			return
		
		# var collider: PhysicsBody3D = collision["collider"]
		
		# move to where we clicked
		var worldPos = collision["position"]
		print("Got event at ", eventPos.x, ", ", eventPos.y)
		print("Got click at ", worldPos.x, ", ", worldPos.y, ", ", worldPos.z)
		set_movement_target(worldPos)

func set_movement_target(movement_target: Vector3):
	$Footsteps.play()
	navigation_agent.set_target_position(movement_target)
	print("Moving to ", movement_target)


func _physics_process(delta):	
	if not navigation_agent.is_navigation_finished():
		var current_agent_position: Vector3 = global_position
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		
		velocity = current_agent_position.direction_to(next_path_position) * movement_speed
		velocity.y = 0 # TODO - don't jump
	else:
		$Footsteps.stop()
		velocity = Vector3(0,-1,0)
	
	# move and animate
	var prevPos = position
	move_and_slide()
	
	# show correct facing
	if prevPos.x != position.x and prevPos.z != position.z:
		right = position.x > prevPos.x
		back = position.z < prevPos.z
		$Graphic.get_active_material(0).albedo_texture = iBack if back else iForward
		$Graphic.get_active_material(0).uv1_scale.x = -1 if right else 1

func think(text: String) -> void:
	$Think.text = text
	$Think.show()
	await get_tree().create_timer(3).timeout
	$Think.hide()
