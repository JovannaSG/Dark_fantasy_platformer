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


func _on_fall_death_body_entered(body):
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_area_2d_1_body_entered(body):
	get_tree().change_scene_to_file("res://Scenes/node_2d.tscn")


func _on_area_2d_body_entered(body):
	get_tree().change_scene_to_file("res://Scenes/level2.tscn")
