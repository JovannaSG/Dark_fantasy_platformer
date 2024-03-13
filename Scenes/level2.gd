extends Node2D


@onready
var hpBar = $CanvasLayer/hpBar
@onready
var player = $Player/Player

# Called when the node enters the scene tree for the first time.
func _ready():
	hpBar.max_value = player.max_HP
	hpBar.value = hpBar.max_value


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_player_hp_changed(new_hp):
	hpBar.value = new_hp


func _on_finish_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Scenes/finish_scene.tscn")
