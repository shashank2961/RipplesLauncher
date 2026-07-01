extends Node3D

# Configuration
var RADIUS:      float = 10.0  # How far out the consoles sit from the center
var totalConsoles: int = 5
var currentIndex:  int = 0    # The console currently in focus

# Array of spawned console models
var consoleNodes: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnPlaceholderConsoles()
	arrangeCarousel(0.0)

# Creates the placeholder Console objects, and Adds them to carousel.
func spawnPlaceholderConsoles():
	for i in range(totalConsoles):
		# 1. Make the object
		var meshInstance = MeshInstance3D.new()
		meshInstance.mesh = BoxMesh.new()
		
		# 2. Add to the Carousel
		add_child(meshInstance)
		consoleNodes.append(meshInstance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If a user clicks left, move the carousel to the left
	if Input.is_action_just_pressed("ui_left"):
		currentIndex = max(0, currentIndex - 1)
		animateCarousel()
	# If a user clicks right, move carousel to the right
	if Input.is_action_just_pressed("ui_right"):
		currentIndex = min(totalConsoles - 1, currentIndex + 1)
		animateCarousel()

func arrangeCarousel(targetIndexOffset: float):
	var angleStep = PI / 4
	
	for i in range(totalConsoles):
		# Find the relative position of this console compared to the selected one
		var relativeIndex = i - targetIndexOffset
		var angle = relativeIndex * angleStep

		# Calculate X (left/right) and Z (depth) using trig
		var x = RADIUS * sin(angle)
		var z = RADIUS * (cos(angle) - 1.0) # Curves it away from the camera

		consoleNodes[i].position = Vector3(x, 0, z)
	
	
	
func animateCarousel():
	print("Focusing on console: ", currentIndex)
	# For right now, it will snap instantly.
	arrangeCarousel(currentIndex)
