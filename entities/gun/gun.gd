extends Node2D
class_name Gun

var shoot_force: float = 200.0
var shoot_delay: float = 0.5
var shoot_timer: float = 0.0 

var player_distance: float = 10.0
var rotation_smoothing: float = 0.5
var base_scale: Vector2

@export var bullet_scene: PackedScene
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_point: Node2D = $FirePoint
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	base_scale = scale

func _process(delta: float) -> void:
	# point towards mouse
	rotation = lerp_angle(
		rotation,
		(get_global_mouse_position() - player.origin.global_position).angle(),
		rotation_smoothing
	)
	
	# orbit around player
	var forward = Vector2(cos(rotation), sin(rotation))
	global_position = forward * player_distance + player.origin.global_position
	
	# handle shooting
	if Input.is_action_pressed("shoot") && shoot_timer >= shoot_delay:
		shoot()
	
	# update shoot timer
	if shoot_timer < shoot_delay:
		shoot_timer += delta
	
	# flip if facing left
	var dist = get_global_mouse_position() - player.origin.global_position
	if dist.x > 0.0:
		scale = base_scale
	else:
		scale = Vector2(base_scale.x, -base_scale.y)

func shoot() -> void:
	# create bullet
	var bullet = bullet_scene.instantiate();
	bullet.global_position = fire_point.global_position
	
	# shoot in facing direction
	var dir = (get_global_mouse_position() - player.origin.global_position).normalized()
	bullet.apply_central_impulse(dir * shoot_force)
	
	# add to scene
	get_tree().current_scene.add_child(bullet)
	shoot_timer = 0.0
	
	# play anim
	sprite.play("shoot")
