extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_state = "idle"

var HP = 100

var inventory_visible = false
@onready var inventory_ui = $CanvasLayer/InventoryUI
@onready var Health_Bar = $CanvasLayer3/HP
@onready var color_rect = $CanvasLayer/ColorRect
@onready var camera = $Camera2D

var bow_equiped = false
var bow_cooldown = true
var regular_arrow = preload("res://Scene/arrow.tscn")
var flame_arrow = preload("res://Scene/Flame_Arrow.tscn")  # Preload Flame_Arrow scene

var mouse_loc_from_player = null
var current_arrow_type = "regular"  # Default arrow type

func _ready():
	inventory_ui.visible = false
	Health_Bar.value = HP
	color_rect.visible = false

func _process(delta):
	if Input.is_action_just_pressed("i"):
		color_rect.visible = not color_rect.visible
		inventory_ui.toggle_visibility()

	if Input.is_action_just_pressed("u"):
		inventory_ui.use_item("slime", self)

	# Check for mouse scroll input to switch arrows
	if Input.is_action_just_pressed("scroll"):
		switch_arrow()

func collect_apple():
	inventory_ui.add_item("apple", 1)

func collect_item(item_name: String, amount: int = 1):
	inventory_ui.add_item(item_name, 1)

func _physics_process(delta):
	mouse_loc_from_player = get_global_mouse_position() - self.position
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
	else:
		player_state = "walking"
	
	var adjusted_speed = SPEED
	if bow_equiped:
		adjusted_speed /= 4
	
	velocity = direction * adjusted_speed
	move_and_slide()
	
	if Input.is_action_just_pressed("q"):
		bow_equiped = not bow_equiped
	
	var mouse_position = get_global_mouse_position()
	$Marker2D.look_at(mouse_position)
	
	if Input.is_action_just_pressed("left_mouse") and bow_equiped and bow_cooldown:
		bow_cooldown = false
		var arrow_instance = spawn_arrow()  # Spawn the correct arrow type
		arrow_instance.rotation = $Marker2D.rotation
		arrow_instance.position = $Marker2D.global_position
		add_child(arrow_instance)

		await get_tree().create_timer(0.5).timeout
		bow_cooldown = true
		
	play_anim(direction)

func spawn_arrow():
	# Return the correct arrow instance based on current_arrow_type
	if current_arrow_type == "regular":
		return regular_arrow.instantiate()
	elif current_arrow_type == "flame":
		return flame_arrow.instantiate()

func switch_arrow():
	# Switch between regular arrow and flame arrow
	current_arrow_type = "flame" if current_arrow_type == "regular" else "regular"
	print("Switched to: ", current_arrow_type)

func play_anim(dir):
	if not bow_equiped:
		if player_state == 'idle':
			$AnimatedSprite2D.play('Idle')
		elif player_state == 'walking':
			if dir.x > 0.5 and dir.y < -0.5:
				$AnimatedSprite2D.play("NorthEast_walk")
			elif dir.x > 0.5 and dir.y > 0.5:
				$AnimatedSprite2D.play("SouthEast_walk")
			elif dir.x < -0.5 and dir.y < -0.5:
				$AnimatedSprite2D.play("NorthWest_walk")
			elif dir.x < -0.5 and dir.y > 0.5:
				$AnimatedSprite2D.play("SouthWest_walk")
			else:
				if dir.y == -1:
					$AnimatedSprite2D.play("North_walk") 
				elif dir.y == 1:
					$AnimatedSprite2D.play("South_walk") 
				elif dir.x == -1:
					$AnimatedSprite2D.play("West_walk") 
				elif dir.x == 1:
					$AnimatedSprite2D.play("East_walk")

	if bow_equiped:
		if mouse_loc_from_player.x >= -25 and mouse_loc_from_player.x <= 25 and mouse_loc_from_player.y < 0:
			$AnimatedSprite2D.play("N_attack")
		if mouse_loc_from_player.y >= -25 and mouse_loc_from_player.y <= 25 and mouse_loc_from_player.x > 0:
			$AnimatedSprite2D.play("E_attack")
		if mouse_loc_from_player.x >= -25 and mouse_loc_from_player.x <= 25 and mouse_loc_from_player.y > 0:
			$AnimatedSprite2D.play("S_attack")
		if mouse_loc_from_player.y >= -25 and mouse_loc_from_player.y <= 25 and mouse_loc_from_player.x < 0:
			$AnimatedSprite2D.play("W_attack")
		
		if mouse_loc_from_player.x >= 25 and mouse_loc_from_player.y <= -25:
			$AnimatedSprite2D.play("NE_attack") 
		if mouse_loc_from_player.x >= 0.5 and mouse_loc_from_player.y >= 25:
			$AnimatedSprite2D.play("SE_attack") 
		if mouse_loc_from_player.x <= -0.5 and mouse_loc_from_player.y >= 25:
			$AnimatedSprite2D.play("SW_attack") 
		if mouse_loc_from_player.x <= -25 and mouse_loc_from_player.y <= -25:
			$AnimatedSprite2D.play("NW_attack") 

func reduce_HP(Damage):
	HP -= Damage
	Health_Bar.value = HP
	print("player's health:", HP)
	if HP <= 0:  
		Death()

func Death():
	set_process(false) 
	$AnimatedSprite2D.play('Death')
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scene/Dead.tscn") 

func heal(amount: int):
	HP += amount
	HP = clamp(HP, 0, 100) 
	Health_Bar.value = HP 
	print("Healed by ", amount, " HP. Current HP: ", HP)

func player():
	pass
