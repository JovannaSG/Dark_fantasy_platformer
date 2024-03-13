extends CharacterBody2D


enum { 
	IDLE, 
	ATTACK, 
	CHASE, 
	DEATH, 
	DAMAGE, 
	RECOVER,
	MOVE
}

var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DEATH:
				death_state()


@onready
var ray_cast = $RayCast2D
@onready
var animation = $AnimationPlayer
@onready
var sprite2d = $AnimatedSprite2D
@export
var fireball : PackedScene
@onready
var timer = $Timer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chase = false
var SPEED = 0
var player
var direction
var damage = 10
var HP = 10
var player_damage


var is_enter = false


func _ready():
	#player = get_parent().find_child("Player")
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))
	Signals.connect("player_attack", Callable(self, "_on_damage_taking"))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if state == DEATH:
		death_state()
	
	var player = $"../../Player/Player"
	if player.position.x - self.position.x > 0:
		sprite2d.flip_h = true
	elif player.position.x - self.position.x < 0:
		sprite2d.flip_h = false
	
	if is_enter:
		var direction = (player.position - self.position).normalized()
		_aim(player)
		_check_player_collision(player)
	else:
		timer.stop()
	
	move_and_slide()


func _check_player_collision(player):
	if ray_cast.get_collider() == player and timer.is_stopped():
		timer.start()
	elif ray_cast.get_collider() != player and not timer.is_stopped():
		timer.stop()


func _aim(player):
	ray_cast.target_position = to_local(player.position)


func _on_player_position_update(player_pos):
	player = player_pos


func idle_state():
	animation.play("idle")
	state = CHASE


func attack_state():
	animation.play("attack")
	await animation.animation_finished
	state = RECOVER


func death_state():
	animation.play("death")
	await animation.animation_finished
	queue_free()


# Коллизия атаки
func _on_attack_range_body_entered(body):
	state = ATTACK


# Для атаки персонажа
func _on_hit_box_area_entered(area):
	Signals.emit_signal("enemy_attack", damage)


# При получении урона
func damage_state():
	animation.play("takingDamage")
	await animation.animation_finished
	state = IDLE


func _on_damage_taking(plr_damage):
	player_damage = plr_damage


func _on_hurt_box_area_entered(area):
	await get_tree().create_timer(0.01).timeout
	HP -= player_damage
	if HP <= 0:
		state = DEATH
	else:
		state = IDLE
		state = DAMAGE


func _on_detector_body_entered(body):
	is_enter = true


func _on_timer_timeout():
	_shoot()
	
	
func _shoot():
	animation.play("attack")
	await animation.animation_finished
	if state != DEATH:
		var f = fireball.instantiate()
		f.position = position
		f.direction = (ray_cast.target_position).normalized()
		get_tree().current_scene.add_child(f)
	animation.play("idle")


func _on_detector_body_exited(body):
	is_enter = false
