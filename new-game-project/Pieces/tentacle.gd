extends RigidBody3D

@onready var nav = $NavigationAgent3D

var lurch_speed = 3
var lurch_rate = 1
var counter = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	# lurch toward the player if there is one
	counter += delta
	if	counter > lurch_rate:
		counter = 0
		var player = get_node("/root/CompositeRoom/Player")
		if player:
			nav.set_target_position(player.position)
			var next_path_position: Vector3 = nav.get_next_path_position()
			var current_agent_position: Vector3 = global_position
			#velocity = current_agent_position.direction_to(next_path_position) * lurch_speed
			var lurch = (next_path_position - current_agent_position).normalized() * lurch_speed
			apply_central_impulse(lurch)
				
	#move_and_slide()
