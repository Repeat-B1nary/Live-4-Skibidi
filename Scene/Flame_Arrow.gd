extends Area2D

var SPEED = 300

func _ready():
	set_as_top_level(true)

func _process(delta):
	position += (Vector2.RIGHT * SPEED).rotated(rotation) * delta
	$AnimatedSprite2D.play("Begining")

func _on_visible_on_screen_enabler_2d_screen_exited():
	$AnimatedSprite2D.play("Hit")
	queue_free()

func arrow_deal_damage():
	pass

func _on_contact_body_entered(body):
	if body.has_method("player"):
		body.player()  
	else:
		$AnimatedSprite2D.play("Hit")
		queue_free()
