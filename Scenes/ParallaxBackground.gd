extends ParallaxBackground


var SPEED = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scroll_offset.x -= SPEED * delta 

# Play button
func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/first_level.tscn")

# Quit button
func _on_quit_button_pressed():
	get_tree().quit()
