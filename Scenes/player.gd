extends CharacterBody2D


signal hp_changed(new_hp)

enum { 
	MOVE, 
	ATTACK, 
	ATTACK2, 
	SLIDE, 
	DAMAGE, 
	DEATH 
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready
var animation = $AnimatedSprite2D
@onready
var animationPlayer = $AnimationPlayer
@onready
var collisionShape = $CollisionShape2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_HP = 100
var HP
var state = MOVE
var combo = false
var attack_cooldown = false
var player_position
var damage_basic = 15
var damage_multiplier = 1
var damage
var last_direction = 1
var movementInput = 0
var slideDirection = 1


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
	
	damage = damage_basic * damage_multiplier
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animationPlayer.play("jump")
		await animationPlayer.animation_finished

	if velocity.y > 0:
		animationPlayer.play("fall")
	
	move_and_slide()
	player_position = self.position
	Signals.emit_signal("player_position_update", player_position)
	animation.flip_h = last_direction - 1


func death_state():
	velocity.x = 0
	animationPlayer.play("death")
	await animationPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func move_state():
	# set movement input  to 1, -1, or 0
	movementInput = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if movementInput != 0:
		last_direction = movementInput
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
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		animation.flip_h = false
		$AttackDirection.rotation_degrees = 0
		
	if Input.is_action_just_released("slide"):
		state = SLIDE
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK


func slide_state():
	slideDirection = last_direction
	animationPlayer.play("slide")
	velocity.x = 250 * slideDirection
	await animationPlayer.animation_finished
	state = MOVE


func attack_state():
	damage_multiplier = 1
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	animationPlayer.play("attack")
	await animationPlayer.animation_finished
	attack_freeze()
	state = MOVE


func attack2_state():
	damage_multiplier = 2
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
	if state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE
	HP -= enemy_damage
	if HP <= 0:
		HP = 0
		state = DEATH
	emit_signal("hp_changed", HP)


func _on_hit_box_area_entered(area):
	Signals.emit_signal("player_attack", damage)
