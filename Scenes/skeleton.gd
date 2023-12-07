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
			CHASE:
				chase_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()
			MOVE:
				move_state()

@onready
var animation = $AnimationPlayer
@onready
var sprite2d = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chase = false
var SPEED = 100
var player
var direction
var damage = 10
var HP = 30
var player_damage


func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))
	Signals.connect("player_attack", Callable(self, "_on_damage_taking"))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	var player = $"../Player"
	var direction = (player.position - self.position).normalized()
	
	move_and_slide()


func _on_player_position_update(player_pos):
	player = player_pos


func idle_state():
	animation.play("idle")
	state = CHASE


func attack_state():
	animation.play("attack")
	await animation.animation_finished
	state = RECOVER


func chase_state():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite2d.flip_h = true
		$AttackDIrection.rotation_degrees = 180
	else:
		sprite2d.flip_h = false
		$AttackDIrection.rotation_degrees = 0


func move_state():
	var player = $"../Player"
	var direction = (player.position - self.position).normalized()
	if direction.x < 0:
		sprite2d.flip_h = true
		animation.play("walk")
		velocity.x = SPEED * direction.x
	else:
		sprite2d.flip_h = false
		animation.play("walk")
		velocity.x = SPEED * direction.x


# 2 метода для преследования
func _on_detector_body_entered(body):
	state = MOVE


func _on_detector_body_exited(body):
	velocity.x = 0
	state = IDLE


func recover_state():
	animation.play("recover")
	await animation.animation_finished
	state = IDLE


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
