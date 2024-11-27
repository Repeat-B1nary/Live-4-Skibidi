extends Node2D

@onready var animplayer = $world2openingcutscene/AnimationPlayer
@onready var camera = $world2openingcutscene/Path2D/PathFollow2D/Camera2D
@onready var narrator = $world2openingcutscene/AudioStreamPlayer2D
@onready var skip_button = $world2openingcutscene/Path2D/PathFollow2D/SKIP

# Preload the world scene
var world_scene = preload("res://Scene/world.tscn")
var world_instance = null  # Will hold the instance of the world scene when created

var is_openingcutscene = false
var has_player_entered_area = false
var player = null
var is_pathfollowing = false
var smoke_has_happened = false
var smoke_is_happening = false

const AUDIO_LENGTH = 100.0  # Length of the audio in seconds

# Enemy spawning variables
@onready var spawn_timer = Timer.new()  # Create a new Timer node
var enemy_scenes = [
	preload("res://Scene/slime.tscn"),
	preload("res://Scene/Goblin.tscn")
]
var min_spawn_x = 100
var max_spawn_x = 1000
var min_spawn_y = 100
var max_spawn_y = 800

func _ready():
	# Add the Timer node to the scene tree for enemy spawning and set it to autostart
	add_child(spawn_timer)
	spawn_timer.wait_time = 600  # 10 minutes (600 seconds)
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	spawn_timer.start()

	# Optionally, you can immediately call the spawn function to spawn enemies at the start
	spawn_enemies()

func _physics_process(delta):
	if is_openingcutscene:
		var pathfollower = $world2openingcutscene/Path2D/PathFollow2D
		
		if is_pathfollowing:
			if !smoke_is_happening:
				# Update progress ratio based on audio playback
				var current_time = narrator.get_playback_position()
				pathfollower.progress_ratio = current_time / AUDIO_LENGTH

				print(pathfollower.progress_ratio)  # Debugging output

				# Check if the cutscene should end
				if pathfollower.progress_ratio >= 0.9:
					print("Ending cutscene...")  # Debugging output
					cutscene_ending()
					
				# Check for smoke effect
				if !smoke_has_happened and pathfollower.progress_ratio >= 0.78 and !smoke_is_happening:
					smoke_is_happening = true
					await get_tree().create_timer(1).timeout
					$world2openingcutscene/TileMapFinished.visible = true	
					
					await get_tree().create_timer(0.3).timeout
					$world2openingcutscene/TileMapFinished.visible = false	
					
					smoke_has_happened = true
					smoke_is_happening = false

func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):  # Check if the body is in the player group
		print("player entered")
		player = body
		if not has_player_entered_area:
			has_player_entered_area = true
			cutscene_opening()  

func cutscene_opening():
	is_openingcutscene = true
	animplayer.play("coverfade")

	# Disable the player's camera if it exists
	if player:
		player.camera.enabled = false

	camera.enabled = true
	is_pathfollowing = true

	# Pause the world during the cutscene
	if world_instance:
		world_instance.set_process(false)  # Stop the _process function of the world node
		world_instance.set_physics_process(false)  # Stop the _physics_process function of the world node

	# Start the narrator's audio
	narrator.play()
	
func cutscene_ending():
	is_pathfollowing = false
	is_openingcutscene = false
	camera.enabled = false
	
	# Enable the player's camera again
	if player:
		player.camera.enabled = true

	# Show the main world after the cutscene
	$world2openingcutscene.visible = false
	
	# If the world scene isn't loaded yet, instance and add it
	if world_instance == null:
		world_instance = world_scene.instantiate()
		add_child(world_instance)  # Add world to the current scene tree

	$World2main.visible = true
	
	# Start enemy spawning after cutscene ends
	spawn_enemies()

func _on_skip_pressed():
	cutscene_ending()
	narrator.stop()

# Enemy spawning functions
func _on_spawn_timer_timeout():
	spawn_enemies()

func spawn_enemies():
	# Number of enemies to spawn (you can adjust this as needed)
	var num_enemies = 3  # For example, spawn 3 enemies at a time

	for i in range(num_enemies):
		# Generate random spawn positions within the defined boundaries
		var spawn_x = randi_range(min_spawn_x, max_spawn_x)
		var spawn_y = randi_range(min_spawn_y, max_spawn_y)
		var spawn_position = Vector2(spawn_x, spawn_y)

		# Randomly select an enemy scene from the array
		var random_enemy_scene = enemy_scenes[randi_range(0, enemy_scenes.size() - 1)]

		# Create an instance of the randomly selected enemy
		var enemy_instance = random_enemy_scene.instantiate()

		# Set the enemy's position to the random spawn point
		enemy_instance.position = spawn_position

		# Add the enemy to the scene (e.g., the current scene or a dedicated enemy parent node)
		add_child(enemy_instance)

		print("Enemy spawned at position: ", spawn_position)
