extends CharacterBody3D

var movement_speed: float = 2.0
var movement_target_position: Vector3 = Vector3(0.0,0.0,20.0)

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var flashlight: SpotLight3D = $HoldPoint/Flashlight

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# for mouse motion events, point the flashlight where the mouse is looking
		var eventPos = event.position
		var worldOrigin = get_viewport().get_camera_3d().project_ray_origin(eventPos)
		var worldNormal = get_viewport().get_camera_3d().project_ray_normal(eventPos)
		var collision = get_world_3d().direct_space_state.intersect_ray(
			PhysicsRayQueryParameters3D.create(worldOrigin, worldOrigin + worldNormal * 100, 0b0001)
		)
		if not collision:
			print("No collision detected")
			return
		
		var worldPos = collision["position"]
		flashlight.look_at(worldPos)
	
	if event is InputEventMouseButton and event.is_pressed():
		# for clicks, walk thereqq
		var eventPos = event.position
		var worldOrigin = get_viewport().get_camera_3d().project_ray_origin(eventPos)
		var worldNormal = get_viewport().get_camera_3d().project_ray_normal(eventPos)
		var collision = get_world_3d().direct_space_state.intersect_ray(
			PhysicsRayQueryParameters3D.create(worldOrigin, worldOrigin + worldNormal * 100, 0b0001)
		)
		if not collision:
			print("No collision detected")
			return
		
		var worldPos = collision["position"]
		print("Got event at ", eventPos.x, ", ", eventPos.y)
		print("Got click at ", worldPos.x, ", ", worldPos.y, ", ", worldPos.z)
		set_movement_target(worldPos)

func set_movement_target(movement_target: Vector3):
	# var bestPos = navigation_agent.get_closest_point_to_position(movement_target)
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()
