extends Area2D

@onready var sprite = $Sprite2D  # Adjust this to match the node for the loot's visual
var item_name = "Goblin_Ears"  # The name of the item, can be used for inventory logic
var collected = false  # To avoid multiple collection events

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered") ) # Connect the body_entered signal
	collected = false

func _on_collection_area_body_entered(body):
	if body.has_method("player") and not collected: 
		print("loot contact with player")
		collect_loot(body)
		collected = true
		await get_tree().create_timer(0.5).timeout
		queue_free()

# Handle loot collection (e.g., adding to inventory)
func collect_loot(player):
	player.collect_item(item_name, 1)  # Assuming the player has a collect_item function
	queue_free()  # Remove the loot from the scene after collection


