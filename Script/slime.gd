extends CharacterBody2D

const SPEED = 150.0
const MAX_FORCE = 100.0  # Maximum steering force
const MAX_VELOCITY = SPEED  # Maximum speed

var health = 60
var dead = false
var player_in_area = false
var is_attacking = false
var damage = 10

var player 
var slime_scene = preload("res://Scene/Slime_Collectable.tscn") 
@onready var Player = get_node("/root/World/Player")
var damage_timer = null

func _ready():
	dead = false
	damage_timer = Timer.new()  # Create a new Timer instance
	damage_timer.wait_time = 1.0  # Set damage interval (1 second for example)
	damage_timer.connect("timeout", Callable(self, "_on_damage_timer_timeout"))  # Connect timeout signal
	add_child(damage_timer)  # Add the timer to the slime node

func _physics_process(delta):
	if !dead:
		$DetectionArea/CollisionShape2D.disabled = false
		
		if player_in_area:
			move_towards_player(delta)
		else:
			$AnimatedSprite2D.play("Idle")
	else:
		$DetectionArea/CollisionShape2D.disabled = true

func move_towards_player(delta):
	# Calculate the desired velocity
	var desired_velocity = (player.position - position).normalized() * MAX_VELOCITY
	
	# Calculate steering force
	var steering = desired_velocity - velocity
	steering = steering.limit_length(MAX_FORCE)  # Limit to maximum steering force

	# Apply steering to the velocity
	velocity += steering * delta
	velocity = velocity.limit_length(MAX_VELOCITY)  # Limit to maximum speed

	# Move the slime using the move_and_slide method without arguments
	move_and_slide()  # No arguments needed in Godot 4

	$AnimatedSprite2D.play('Move')

func _on_detection_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		player = body
		damage_timer.start()  # Start the damage timer when the player enters

func _on_detection_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false
		damage_timer.stop()  # Stop the timer when the player exits

func _on_hit_box_area_entered(area):
	if area.has_method("arrow_deal_damage"):
		take_damage(damage)

func take_damage(damage):
	health -= damage
	if health <= 0:
		death()

func death():
	dead = true
	$AnimatedSprite2D.play("Death")
	await get_tree().create_timer(1).timeout
	drop_loot()  # Call function to drop loot
	queue_free()

func drop_loot():
	var loot_instance = slime_scene.instantiate()  # Create an instance of the loot scene
	loot_instance.position = position  # Set the position of the loot to the enemy's current position
	get_parent().add_child(loot_instance)

func _on_poison_zone_body_entered(body):
	if body.has_method('player'):
		is_attacking = true
		print("body detected")
		Player.reduce_HP(damage)
		damage_timer.start()  # Start the damage timer when the player enters the poison zone

func _on_poison_zone_body_exited(body):
	if body.has_method('player'):
		is_attacking = false
		print("body exited")
		damage_timer.stop()

func _on_damage_timer_timeout():
	if player and player.has_method("reduce_HP"):
		player.reduce_HP(damage)  
