extends RigidBody2D
class_name Player

var move_speed: float = 1000.0

var max_health: float = 3.0
var health: float = max_health
signal died

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var origin: Node2D = $Origin

func _ready() -> void:
	linear_damp = 15.0

func _physics_process(_delta: float) -> void:
	# handle movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	apply_central_force(input_dir * move_speed)

	# animate
	if (input_dir.length() > 0.2):
		sprite.play("run")
	else:
		sprite.play("idle")
	
	# flip if facing left
	var dist = get_global_mouse_position() - origin.global_position;
	sprite.flip_h = dist.x < 0.0
	
	# check if dead
	if health <= 0.0:
		die()

func take_damage(damage: float, damager_position: Vector2, knockback_force: float) -> void:
	health -= damage
	
	# apply knockback
	var dir = (position - damager_position).normalized()
	apply_central_impulse(dir * knockback_force)

func die() -> void:
	emit_signal("died")
	queue_free()
