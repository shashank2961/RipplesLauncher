extends Node3D

# Configuration
var RADIUS:        float = 3  # How far out the consoles sit from the center
var totalConsoles: int = 5
var currentIndex:  int = 0    # The console currently in focus

# Transparancy and Hover settings
var activeAlpha:   float = 1.0     # Fully solid when selected
var inactiveAlpha: float = 0.15   # 85% transparent when in the background

# Mesh and Anchor
var consoleNodes: Array = []
var objectTimers: Array = []   
var activeTween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_consoles()
	arrange_carousel()
	update_transparency()



# Methods ------------------------------------------------------------------------------------------
# Creates the placeholder Console objects, and Adds them to carousel.
func spawn_consoles():
	var model_paths = [
		"res://assets/models/PS1/ps1.glb", # Index 0
		"res://assets/models/PS1/ps1.glb", # Index 1
		"res://assets/models/PS1/ps1.glb", # Index 2
		"res://assets/models/PS1/ps1.glb", # Index 3
		"res://assets/models/PS1/ps1.glb"  # Index 4
	]
	
	for i in range(totalConsoles):
		# 1. Load the specific scene from our list
		var console_scene = load(model_paths[i])
		var console_instance = console_scene.instantiate()
		
		# 2. Prepare its internal meshes for transparency right away
		initialize_mesh_materials(console_instance)
		
		# 3. Add to the Carousel and track it
		add_child(console_instance)
		consoleNodes.append(console_instance)
		
		# 4. Initialize our personal tracking arrays
		objectTimers.append(0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	# Counterspin for all child objects under Carousel
	for box in consoleNodes:
		box.rotation.y = -self.rotation.y
	if activeTween and activeTween.is_running():
		return
		
	# Hover Logic
	for i in range(consoleNodes.size()):
		var box = consoleNodes[i]
		
		if i == currentIndex:
			objectTimers[i] += delta * 2.0
		else:
			objectTimers[i] += delta * 1.2
		# Frequency parameter is INSIDE the bubble, while the float value outside is the Amplitude
		box.position.y = sin(objectTimers[i]) * 0.05
	
	# Keyboard Logic
	if Input.is_action_just_pressed("ui_left"):
		currentIndex = (currentIndex - 1 + totalConsoles) % totalConsoles # Mod helps us loop when we move past the range
		rotateToCurrent()
	if Input.is_action_just_pressed("ui_right"):
		currentIndex = (currentIndex + 1) % totalConsoles # Mod helps us loop when we move past the range
		rotateToCurrent()


func arrange_carousel():
	var angleStep = (2*PI) / totalConsoles # Split 360 degrees into even slices (for console)
	
	for i in range(totalConsoles):
		var angle = i * angleStep
		var x = RADIUS * sin(angle)
		var z = RADIUS * cos(angle)
		consoleNodes[i].position = Vector3(x, 0, z)
		
		
func update_transparency():
	for i in range(totalConsoles):
		var model = consoleNodes[i]
		var targetAlpha = activeAlpha if i == currentIndex else inactiveAlpha
		
		set_model_alpha_recursive(model, targetAlpha)
	
	
func rotateToCurrent():
	print("swapping to console index: ", currentIndex)
	
	# Calculate our exact destination angle based on the new target index
	var angleStep = (2 * PI) / totalConsoles
	var targetAngle = -currentIndex * angleStep
	
	# If an old animation is still lingering, kill it cleanly before starting a new one
	if activeTween:
		activeTween.kill()
		
	# Create a fresh Tween runner
	activeTween = create_tween()
	activeTween.set_parallel(true)
	activeTween.set_trans(Tween.TRANS_CUBIC)
	activeTween.set_ease(Tween.EASE_OUT)
	
	# Animate the 'rotation:y' property of THIS node (the Carousel parent) 
	# to our target angle over a duration of 0.35 seconds
	activeTween.tween_property(self, "rotation:y", targetAngle, 0.35)
	
	#Loop through all boxes and animate their transparency
	for i in range(totalConsoles):
		var model = consoleNodes[i]
		var targetAlpha = activeAlpha if i == currentIndex else inactiveAlpha
		tween_model_alpha_recursive(model, targetAlpha)
		
		
# Recursive Helper Functions ----------------------------------------------------------------------

# Recursively finds every mesh (no matter how deep) and ensures they have override materials
func initialize_mesh_materials(node: Node):
	if node is MeshInstance3D:
		if not node.material_override:
			node.material_override = StandardMaterial3D.new()
			node.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
	for child in node.get_children():
		initialize_mesh_materials(child)


# Recursively sets the transparency on every child mesh, disabling transparency entirely when alpha is 1.0
func set_model_alpha_recursive(node: Node, alpha: float):
	if node is MeshInstance3D and node.material_override:
		var mat = node.material_override as StandardMaterial3D
		# Fixes the X-ray look: if alpha is 1.0 (active item), turn off transparency!
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if alpha < 1.0 else BaseMaterial3D.TRANSPARENCY_DISABLED
		mat.albedo_color.a = alpha
		
	for child in node.get_children():
		set_model_alpha_recursive(child, alpha)


# Recursively tweens transparency, toggling transparency mode on and off at the right moments
func tween_model_alpha_recursive(node: Node, alpha: float):
	if node is MeshInstance3D and node.material_override:
		var mat = node.material_override as StandardMaterial3D
		
		if alpha >= 1.0:
			# If transitioning to solid, slide alpha first, then disable transparency mode when done
			activeTween.tween_property(mat, "albedo_color:a", alpha, 0.45)
			# Disable transparency
			activeTween.tween_callback(func(): mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED)
		else:
			# If transitioning to transparent, enable transparency immediately so it can fade cleanly
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			#change its transparenct
			activeTween.tween_property(mat, "albedo_color:a", alpha, 0.45)
			
	for child in node.get_children():
		tween_model_alpha_recursive(child, alpha)
