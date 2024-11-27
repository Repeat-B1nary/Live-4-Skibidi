extends CharacterBody2D

const SPEED = 100.0

var health = 60
var max_health = 60
var dead = false
var player_in_area = false
var player_in_attack_area = false
var attack_damage = 10
var is_attacking = false
var state = State.IDLE
var player: CharacterBody2D
var direction: Vector2 = Vector2.ZERO 
var slime_scene = preload("res://Scene/Goblin_ears.tscn")

@onready var attack_area = $AttackArea
@onready var detection_area = $DetectionArea
@onready var animated_sprite = $AnimatedSprite2D
@onready var patrol_timer = $PatrolTimer  
@onready var attack_timer = $AttackTimer  
@onready var top_raycast = $Node2D/TopRaycast 
@onready var bottom_raycast = $Node2D/BottomRaycast 
@onready var left_raycast = $Node2D/LeftRaycast 
@onready var right_raycast = $Node2D/RightRaycast

enum State {
	IDLE,
	PATROL,
	ATTACK,
	FLEE,
	CHASE
}

func _ready():
	player = get_node("/root/World/Player")
	if patrol_timer and patrol_timer.has_signal("timeout"):
		patrol_timer.connect("timeout", Callable(self, "_on_patrol_timer_timeout"))
	
	if attack_timer and attack_timer.has_signal("timeout"):
		attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	
	start_patrol()

func _physics_process(delta):
	if dead:
		return  # Prevent further action if dead

	# State management to handle the movement and animations based on the state
	state_management()

	# If patrolling, move the goblin
	if state == State.PATROL:
		avoid_obstacles()
		move_and_slide()

	# Chase the player if the player is in the detection area
	elif state == State.CHASE:
		avoid_obstacles()
		chase_player(delta)

	# Attack the player if in attack range
	elif state == State.ATTACK and player_in_attack_area and attack_timer.is_stopped():
		attack()


# Function to handle obstacle avoidance using RayCasts
func avoid_obstacles():
	# Check each raycast to see if it's colliding with an object
	if top_raycast.is_colliding() and top_raycast.get_collider() != player:
		# If the top raycast detects a collision, move down or in another direction
		direction.y = 1  # Move down

	elif bottom_raycast.is_colliding() and bottom_raycast.get_collider() != player:
		# If the bottom raycast detects a collision, move up or in another direction
		direction.y = -1  # Move up

	elif left_raycast.is_colliding() and left_raycast.get_collider() != player:
		# If the left raycast detects a collision, move right
		direction.x = 1  # Move right

	elif right_raycast.is_colliding() and right_raycast.get_collider() != player:
		# If the right raycast detects a collision, move left
		direction.x = -1  # Move left

	# Normalize the direction vector to ensure it doesn't exceed normal speed
	direction = direction.normalized()
	velocity = direction * SPEED

func start_patrol():
	# Start the patrol timer with a random interval between 7 and 15 seconds
	patrol_timer.start(randf_range(7, 15))

func _on_patrol_timer_timeout():
	# Generate a random number between 0 and 1 for direction
	var random_num = randi_range(0, 4)

	# Logic to determine the state based on the random number
	match random_num:
		0:
			state = State.IDLE
			print("Goblin is now IDLE.")
		1:
			state = State.PATROL
			patrol()
			print("Goblin is now PATROLLING.")
		2, 3, 4:
			state = State.IDLE  # You can add custom behavior for these as needed
			print("Goblin remains in IDLE.")

	# Restart the patrol timer with a new random interval
	start_patrol()

func patrol():
	# Set a random direction for patrolling
	direction = Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()
	velocity = direction * SPEED

func chase_player(_delta):
	if player:
		direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED  
		move_and_slide()

func _on_detection_area_body_entered(body):
	if body == player:
		player_in_area = true
		player_in_attack_area = false
		state = State.CHASE
	
func _on_detection_area_body_exited(body):
	if body == player:
		player_in_area = false
		player_in_attack_area = false
		if not is_attacking and not player_in_area:
			state = State.PATROL

func _on_attack_area_body_entered(body):
	if body == player:
		player_in_attack_area = true
		state = State.ATTACK

func _on_attack_area_body_exited(body):
	if body == player:
		player_in_attack_area = false
		attack_timer.stop()
		is_attacking = false  # Mark the goblin as not attacking anymore
		if not player_in_area:
			state = State.PATROL  # Switch back to PATROL state if player is not detected
		else:
			state = State.CHASE  # If the player is still in the detection area, switch to CHASE state


func state_management():
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.play("Idle" + get_direction_suffix())
		State.PATROL:
			$AnimatedSprite2D.play("Walk" + get_direction_suffix())
		State.ATTACK:
			$AnimatedSprite2D.play("Attack" + get_direction_suffix())
		State.FLEE:
			$AnimatedSprite2D.play("Run" + get_direction_suffix())
		State.CHASE:
			$AnimatedSprite2D.play("Run" + get_direction_suffix())

func attack():
	if player_in_attack_area and not dead and attack_timer.is_stopped():
		if player: 
			attack_timer.start(1)
			print("Goblin started attacking the player.")

func _on_attack_timer_timeout():
	if player_in_attack_area and not dead:
		player.reduce_HP(attack_damage)
		print("Goblin dealt ", attack_damage, " damage to the player.")
	else:
		attack_timer.stop()

func get_direction_suffix() -> String:
	if abs(direction.x) > abs(direction.y):
		return "East" if direction.x > 0 else "West"
	else:
		return "South" if direction.y > 0 else "North"

func take_damage(damage):
	health -= damage
	if health <= 0:
		health = 0
		death()

func death():
	dead = true
	attack_timer.stop()  # Stop attacking if dead
	patrol_timer.stop()  # Stop patrolling if dead
	animated_sprite.play("Death")
	await get_tree().create_timer(1).timeout
	drop_loot()
	queue_free()

func drop_loot():
	var loot_instance = slime_scene.instantiate()
	loot_instance.position = position
	get_parent().add_child(loot_instance)


func _on_hit_box_area_entered(area):
	var damage = 30
	if area.has_method("arrow_deal_damage"):
		take_damage(damage)
