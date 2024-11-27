extends ProgressBar

func _ready():
	# Create a Gradient
	var gradient = Gradient.new()
	gradient.colors = [Color(1, 0.5, 0.5), Color(1, 0, 0)]  # Light red to dark red
	gradient.offsets = [0.0, 1.0]  # From 0 (start) to 1 (end)
	
	# Create a GradientTexture2D
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = 256  # Width of the gradient texture
	
	# Create a StyleBoxTexture to apply the gradient texture
	var stylebox_bg = StyleBoxTexture.new()
	stylebox_bg.texture = gradient_texture  # Set the gradient texture as the background
	
	# Apply the StyleBoxTexture to the ProgressBar's background
	add_theme_stylebox_override("bg", stylebox_bg)

	# Optionally, create and apply a foreground StyleBox
	var stylebox_fg = StyleBoxFlat.new()
	stylebox_fg.bg_color = Color(0, 1, 0)  # Green color for the foreground bar
	add_theme_stylebox_override("fg", stylebox_fg)
