extends Control

var inventory = {}  # This will store item types and their counts
var max_slots = 10  # Number of slots in the inventory

# Reference to the grid containing the inventory slots
@onready var inventory_grid = $InventoryGrid
@onready var feedback_label = $FeedbackLabel 

func _ready():
	update_inventory_ui() 
	feedback_label.text = ""  
	feedback_label.visible = false

func add_item(item_name: String, amount: int = 1):
	print("Adding item: ", item_name, " Amount: ", amount)  # Debug output
	if inventory.has(item_name):
		inventory[item_name] += amount
	else:
		if len(inventory) < max_slots:
			inventory[item_name] = amount
		else:
			print("Inventory is full!")
			return
	update_inventory_ui()

func update_inventory_ui():
	print("Updating Inventory UI")
	var slots = inventory_grid.get_children()
	var idx = 0

	# Clear all slots first
	for slot in slots:
		print("Clearing slot: ", idx)
		var item_texture = slot.get_node("ItemTexture") as TextureRect
		var item_count_label = slot.get_node("ItemCount") as Label
		item_texture.texture = null
		item_count_label.text = ""  # Reset the label text
		item_count_label.visible = false  # Ensure label is hidden initially
		idx += 1

	# Reset index for populating the inventory
	idx = 0  

	# Loop through inventory items and update UI
	for item_name in inventory.keys():
		if idx >= max_slots:
			return
		var slot = slots[idx]
		var item_texture = slot.get_node("ItemTexture") as TextureRect
		var item_count_label = slot.get_node("ItemCount") as Label

		print("Setting texture for item: ", item_name)
		match item_name:
			"apple":
				item_texture.texture = preload("res://Art/apple-icon.png")
				print("Loaded texture for apple")
			"slime":
				item_texture.texture = preload("res://Art/slime-icon.png")
				print("Loaded texture for Slime")
			"Goblin_Ears":
				item_texture.texture = preload("res://Art/Enemy/Orc1/Transperent/Icon3.png")
				print("Loaded texture for Slime")

		# Update the item count label with the correct number
		var item_count = inventory[item_name]
		item_count_label.text = str(item_count)  # Set the count in the label
		item_count_label.visible = true  # Ensure the label is visible
		print("Set count for item: ", item_name, " Count: ", item_count)

		idx += 1

# Inventory.gd
func use_item(item_name: String, player):
	if inventory.has(item_name) and inventory[item_name] > 0:
		inventory[item_name] -= 1  # Use one item
		match item_name:
			"slime":
				player.heal(5)  # Heal the player by 5 HP
				if inventory[item_name] <= 0:
					inventory.erase(item_name)  # Remove item if count is zero
	
		update_inventory_ui()
		show_feedback("Item used!")
	else:
		show_feedback("Not enough items!")

func show_feedback(message: String):
	feedback_label.text = message
	feedback_label.visible = true
	await get_tree().create_timer(2).timeout  # Show for 2 seconds
	feedback_label.visible = false

func toggle_visibility():
	visible = !visible 
