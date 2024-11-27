extends Node2D

# Timer to spawn enemies every 10 minutes
@onready var spawn_timer = Timer.new()  # Create a new Timer node

# Array to store multiple enemy scenes
var enemy_scenes = [
	preload("res://Scene/Goblin.tscn"),
	preload("res://Scene/slime.tscn")
	# Add more enemy scenes as needed
]

# Define the boundaries of the area where enemies can spawn
var min_spawn_x = 100
var max_spawn_x = 1000
var min_spawn_y = 100
var max_spawn_y = 800

func _ready():
	# Add the Timer node to the scene tree and set it to autostart
	add_child(spawn_timer)
	spawn_timer.wait_time = 600  # 10 minutes (600 seconds)
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	spawn_timer.start()

	# Optionally, you can immediately call the spawn function to spawn enemies at the start
	spawn_enemies()

func _on_spawn_timer_timeout():
	spawn_enemies()

func spawn_enemies():
	# Number of enemies to spawn (you can adjust this as needed)
	var num_enemies = 3  # For example, spawn 3 enemies at a time

	for i in range(num_enemies):
		# Generate random spawn positions within the defined boundaries
		var spawn_x = randi() % (max_spawn_x - min_spawn_x) + min_spawn_x
		var spawn_y = randi() % (max_spawn_y - min_spawn_y) + min_spawn_y

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
