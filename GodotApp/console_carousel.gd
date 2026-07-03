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
	spawnPlaceholderConsoles()
	arrangeCarousel()
	updateInitalTransparency()



# Methods ------------------------------------------------------------------------------------------

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
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA  # Allows object's transparency settings to change
		meshInstance.material_override = material
		
		# 3. Add to the Carousel
		add_child(meshInstance)
		consoleNodes.append(meshInstance)
		
		#4. Add a timer for each object
		objectTimers.append(0.00)


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


func arrangeCarousel():
	var angleStep = (2*PI) / totalConsoles # Split 360 degrees into even slices (for console)
	
	for i in range(totalConsoles):
		var angle = i * angleStep
		var x = RADIUS * sin(angle)
		var z = RADIUS * cos(angle)
		consoleNodes[i].position = Vector3(x, 0, z)
		
		
func updateInitalTransparency():
	for i in range(totalConsoles):
		var mat = consoleNodes[i].material_override as StandardMaterial3D
		if i == currentIndex:
			mat.albedo_color.a = activeAlpha
		else:
			mat.albedo_color.a = inactiveAlpha
	
	
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
		var mat = consoleNodes[i].material_override as StandardMaterial3D
		var targetAlpha = activeAlpha if i == currentIndex else inactiveAlpha
		
		activeTween.tween_property(mat,"albedo_color:a", targetAlpha, 0.45)
