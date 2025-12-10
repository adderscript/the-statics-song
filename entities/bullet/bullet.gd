extends RigidBody2D

var damage: float = 1.0
var knockback_force: float = 250.0

@export var hit_particles_scene: PackedScene

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	
	body_entered.connect(_on_collision_entered)

func _physics_process(_delta: float) -> void:
	pass

func _on_collision_entered(body: Node) -> void:
	# check type
	if body.is_in_group("enemies"):
		body.take_damage(damage, position, knockback_force)
	
	# create particle system
	var particles = hit_particles_scene.instantiate()
	particles.position = position
	
	# add to scene
	get_tree().current_scene.add_child(particles)
	
	queue_free()
