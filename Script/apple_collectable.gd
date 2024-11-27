# apple_collectable.gd
extends StaticBody2D

func _ready():
	fallfromtree()

func fallfromtree():
	$AnimatedSprite2D/AnimationPlayer.play("fallingfromtree")
	await get_tree().create_timer(1.5).timeout
	$AnimatedSprite2D/AnimationPlayer.play('fade')
	print("+1 apple")  # Add this for debugging
	get_node("/root/World/Player").collect_apple()  # Trigger collect_apple in player.gd
	await get_tree().create_timer(0.3).timeout
	queue_free()
