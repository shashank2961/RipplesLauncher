extends Node3D

# Configuration
var RADIUS:      float = 1.5  # How far out the consoles sit from the center
var totalConsoles: int = 5
var currentIndex:  int = 0    # The console currently in focus

# Array of spawned console models
var consoleNodes: Array = []
var activeTween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnPlaceholderConsoles()
	arrangeCarousel()

# Creates the placeholder Console objects, and Adds them to carousel.
func spawnPlaceholderConsoles():
	var colors = [Color.MEDIUM_PURPLE, Color.INDIAN_RED, Color.SEA_GREEN, Color.GOLDENROD, Color.DEEP_SKY_BLUE]
	
	for i in range(totalConsoles):
		# 1. Make the object
		var meshInstance = MeshInstance3D.new()
		meshInstance.mesh = BoxMesh.new()
		
		#2. Add colour
		var material = StandardMaterial3D.new()
		material.albedo_color = colors[i % colors.size()]
		meshInstance.material_override = material
		
		# 3. Add to the Carousel
		add_child(meshInstance)
		consoleNodes.append(meshInstance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for box in consoleNodes:
		box.rotation.y = -self.rotation.y
		
	if activeTween and activeTween.is_running():
		return
	
	# If a user clicks left, move the carousel to the left
	if Input.is_action_just_pressed("ui_left"):
		currentIndex = (currentIndex - 1 + totalConsoles) % totalConsoles
		rotateToCurrent()
	# If a user clicks right, move carousel to the right
	if Input.is_action_just_pressed("ui_right"):
		currentIndex = (currentIndex + 1) % totalConsoles
		rotateToCurrent()


func arrangeCarousel():
	var angleStep = (2*PI) / totalConsoles # Split 360 degrees into even slices (for console)
	
	for i in range(totalConsoles):
		var angle = i * angleStep
		
		# Calculating X and Z coordinates to form a ring on the floor
		var x = RADIUS * sin(angle)
		var z = RADIUS * cos(angle)
		
		# set the posiition for each consoleNode to the new x and z
		consoleNodes[i].position = Vector3(x, 0, z)
	
	
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
	
	# Configure it to use a premium, snappy "Cubic" deceleration curve
	activeTween.set_trans(Tween.TRANS_CUBIC)
	activeTween.set_ease(Tween.EASE_OUT)
	
	# Animate the 'rotation:y' property of THIS node (the Carousel parent) 
	# to our target angle over a duration of 0.45 seconds
	activeTween.tween_property(self, "rotation:y", targetAngle, 0.45)
