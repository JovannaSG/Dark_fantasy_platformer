extends CharacterBody2D


signal hp_changed(new_hp)

enum { MOVE, ATTACK, ATTACK2, SLIDE, DAMAGE, DEATH }

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready
var animation = $AnimatedSprite2D
@onready
var animationPlayer = $AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_HP = 100
var HP
var state = MOVE
var combo = false
var attack_cooldown = false
var player_position


func _ready():
	Signals.connect("enemy_attack", Callable(self, "_on_taking_damage"))
	HP = max_HP


func _physics_process(delta):
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		SLIDE:
			slide_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animationPlayer.play("jump")

	if velocity.y > 0:
		animationPlayer.play("fall")
	
	move_and_slide()
	player_position = self.position
	Signals.emit_signal("player_position_update", player_position)


func death_state():
	velocity.x = 0
	animationPlayer.play("death")
	await animationPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func move_state():
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if velocity.y == 0:
			animationPlayer.play("player_walk")
		velocity.x = direction * SPEED
	else:
		if velocity.y == 0:
			animationPlayer.play("player_stay")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction == -1:
		animation.flip_h = true
	elif direction == 1:
		animation.flip_h = false
		
	if Input.is_action_just_released("slide"):
		state = SLIDE
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK


func slide_state():
	animationPlayer.play("slide")
	if self.velocity.x >= 0:
		velocity.x += 25
	else:
		velocity.x -= 25
	await animationPlayer.animation_finished
	state = MOVE


func attack_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	animationPlayer.play("attack")
	await animationPlayer.animation_finished
	attack_freeze()
	state = MOVE


func attack2_state():
	animationPlayer.play("attack2")
	await animationPlayer.animation_finished
	state = MOVE


func combo_attack():
	combo = true
	await animationPlayer.animation_finished
	combo = false


func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.3).timeout
	attack_cooldown = false


func damage_state():
	velocity.x = 0
	animationPlayer.play("taking_damage")
	await animationPlayer.animation_finished
	state = MOVE


func _on_taking_damage(enemy_damage):
	HP -= enemy_damage
	if HP <= 0:
		HP = 0
		state = DEATH
	else:
		state = DAMAGE
	emit_signal("hp_changed", HP)
