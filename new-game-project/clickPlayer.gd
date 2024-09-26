extends CharacterBody3D

var movement_speed: float = 2.0
var movement_target_position: Vector3 = Vector3(0.0,0.0,20.0)

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mouseTracker: Node3D = $MouseTracker
@onready var flashlight: SpotLight3D = $MouseTracker/HoldPoint/Flashlight
@onready var cam: Camera3D = $MouseTracker/HoldPoint/Camera3D
@onready var muzzleFlash: OmniLight3D = $MuzzleFlash
@onready var sfxGunshot: AudioStreamPlayer3D = $SfxGunshot
@onready var sfxFootsteps: AudioStreamPlayer3D = $SfxFootsteps

@export var debugClick: bool = false

var debug_ClickPos: MeshInstance3D
var muzzleFlashCountdown: float = 0
var inv: Inventory
var currentItem: String = "gun"

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	
	# find the inventory
	inv = get_node("/root/Room/Inventory")
	if inv:
		print("Found inventory")
		inv.item_changed.connect(_on_item_changed)
		inv.registerCamera(cam)
	else:
		push_warning("No inventory found - all items disabled!")
	
	flashlight.hide()

	if debugClick:
		debug_ClickPos = MeshInstance3D.new()
		var m := SphereMesh.new()
		m.radius = .25
		m.height = .25
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.YELLOW
		m.material = mat
		debug_ClickPos.mesh = m
		add_child(debug_ClickPos)

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func _unhandled_input(event: InputEvent) -> void:
	if not get_viewport().get_camera_3d():
		return
	
	if event is InputEventMouseMotion:
		# for mouse motion events, point the flashlight where the mouse is looking
		var eventPos = event.position
		var worldOrigin = get_viewport().get_camera_3d().project_ray_origin(eventPos)
		var worldNormal = get_viewport().get_camera_3d().project_ray_normal(eventPos)
		var collision = get_world_3d().direct_space_state.intersect_ray(
			PhysicsRayQueryParameters3D.create(worldOrigin, worldOrigin + worldNormal * 100, 0b0001)
		)
		if not collision:
			return
		
		var worldPos = collision["position"]
		
		if currentItem == "flashlight":
			flashlight.look_at(worldPos)
		elif currentItem == "camera":
			cam.look_at(worldPos)
	
	if event is InputEventMouseButton and event.is_pressed():
		# for clicks, walk there
		var eventPos = event.position
		var worldOrigin = get_viewport().get_camera_3d().project_ray_origin(eventPos)
		var worldNormal = get_viewport().get_camera_3d().project_ray_normal(eventPos)
		
		var collisionMask := 0b0001
		if currentItem == "gun":
			collisionMask |= 0b0100
		
		var collision = get_world_3d().direct_space_state.intersect_ray(
			PhysicsRayQueryParameters3D.create(worldOrigin, worldOrigin + worldNormal * 100, collisionMask)
		)
		if not collision:
			print("No collision detected")
			return
		
		var collider: PhysicsBody3D = collision["collider"]
		
		if collider.collision_layer & 0b0100:
			# hit an enemy - shoot it!
			if currentItem == "gun":
				muzzleFlash.show()
				muzzleFlashCountdown = .05
				sfxGunshot.play()
				
				if collider is PhysicsBody3D:
					collider.apply_central_impulse((collision["position"] - position).normalized() * 5)
				if collider is Tentacle:
					collider.take_damage(1)
		else:
			# didn't hit an enemy - move
			var worldPos = collision["position"]
			print("Got event at ", eventPos.x, ", ", eventPos.y)
			print("Got click at ", worldPos.x, ", ", worldPos.y, ", ", worldPos.z)
			set_movement_target(worldPos)

func set_movement_target(movement_target: Vector3):
	if not sfxFootsteps.playing:
		sfxFootsteps.play()
	navigation_agent.set_target_position(movement_target)
	print("Moving to ", movement_target)


func _physics_process(delta):
	if muzzleFlashCountdown > 0:
		muzzleFlashCountdown -= delta
		if muzzleFlashCountdown < 0:
			muzzleFlash.hide()
	
	if navigation_agent.is_navigation_finished():
		sfxFootsteps.stop()
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		
	if debugClick:
		debug_ClickPos.global_position = to_global(navigation_agent.target_position)

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

func _on_item_changed(newItem: InventoryItem) -> void:
	print("Item changed to ", newItem.itemName)
	flashlight.hide()
	currentItem = newItem.itemName
	if currentItem == "flashlight":
		flashlight.show()
