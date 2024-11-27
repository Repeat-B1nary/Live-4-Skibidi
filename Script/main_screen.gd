extends Node2D

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("Elastic_Title")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_play_pressed():
	var new_scene_path = "res://Scene/world.tscn"
	if ResourceLoader.exists(new_scene_path):
		get_tree().change_scene_to_file(new_scene_path)
	else:
		print("Error: Scene not found at path: ", new_scene_path)

func _on_run_away_pressed():
	get_tree().quit()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Elastic_Title":
		print("Animation has finished playing.")
