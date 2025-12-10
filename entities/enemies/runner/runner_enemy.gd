extends RigidBody2D
class_name Enemy

var move_speed: float = 500.0
var target: Node2D

var max_health: float = 2.0
var health: float = max_health
var flash_duration: float = 0.2
var damage: float = 1.0
var knockback_force: float = 750.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $Origin/NavigationAgent2D
@onready var pathfinding_timer: Timer = $PathfindingTimer
@onready var detection_radius: Area2D = $PlayerDetectionRadius
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var radio_tower: StaticBody2D = get_tree().get_first_node_in_group("radio_tower")

func _ready() -> void:
	linear_damp = 10.0
	contact_monitor = true
	max_contacts_reported = 5
	target = radio_tower
	
	sprite.material = sprite.material.duplicate()
	sprite.play("run")
	nav_agent.target_position = target.global_position
	
	body_entered.connect(_on_collision_entered)
	pathfinding_timer.timeout.connect(_on_timer_timeout)

func _physics_process(_delta: float) -> void:
	# check if player is in detection radius
	if player != null and AreaCollision.is_point_in_area(detection_radius, player.global_position):
		target = player
	else:
		target = radio_tower

	# pathfind to target
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	apply_central_force(dir * move_speed)
	
	# check if dead
	if health <= 0.0:
		die()

func _on_timer_timeout() -> void:
	if target == null: return
	nav_agent.target_position = target.global_position

func _on_collision_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage, position, knockback_force)

func take_damage(damage_amount: float, damager_position: Vector2, damager_knockback_force: float) -> void:
	var shader_material = sprite.material as ShaderMaterial
	
	# take damage
	health -= damage_amount
	
	# apply knockback
	var dir = (position - damager_position).normalized()
	apply_central_impulse(dir * damager_knockback_force)
	
	# set full flash
	shader_material.set_shader_parameter("flash_strength", 1.0)
	var tween = create_tween()
	
	# tween flash_strength from 1.0 -> 0.0
	tween.tween_method(
		func(value: float) -> void:
			shader_material.set_shader_parameter("flash_strength", value),
		1.0,
		0.0,
		flash_duration
	)

func die() -> void:
	queue_free()
