extends CharacterBody2D

enum { IDLE, ATTACK, CHASE }

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

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chase = false
var alive = true
var SPEED = 100
var player
var direction
@onready var animation = $AnimationPlayer
@onready var sprite2d = $AnimatedSprite2D


func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()
	
	if state == CHASE:
		chase_state()
	
	move_and_slide()


func _on_player_position_update(player_pos):
	player = player_pos


func idle_state():
	animation.play("idle")
	await get_tree().create_timer(1).timeout
	$AttackDIrection/AttackRange/CollisionShape2D.disabled = false
	state = CHASE


func attack_state():
	animation.play("attack")
	await animation.animation_finished
	$AttackDIrection/AttackRange/CollisionShape2D.disabled = true
	state = IDLE


func chase_state():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite2d.flip_h = true
		$AttackDIrection.rotation_degrees = 180
	else:
		sprite2d.flip_h = false
		$AttackDIrection.rotation_degrees = 0


func _on_detector_body_entered(body):
	pass


func _on_detector_body_exited(body):
	pass


func death():
	alive = false
	animation.play("death")
	await animation.animation_finished
	queue_free()


func _on_detector_death_2_body_entered(body):
	pass
#	death()


# Коллизия атаки
func _on_attack_range_body_entered(body):
	state = ATTACK
