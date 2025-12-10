extends Node

@onready var spawn_timer: Timer = $EnemySpawnTimer
@export var enemy_scene: PackedScene
@export var spawn_areas: Array[Area2D]

func _ready() -> void:
	spawn_timer.start()
	
	spawn_timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	# create enemy
	var enemy = enemy_scene.instantiate()
	
	# get random spawn area
	var spawn_area = spawn_areas[randi_range(0, spawn_areas.size()-1)]
	var collider = spawn_area.get_node("CollisionShape2D")
	
	# get rect
	var rect = collider.shape
	var half_extents = rect.size * 0.5
	
	# get random position inside of rect
	var local_offset = Vector2(
		randf_range(-half_extents.x, half_extents.x),
		randf_range(-half_extents.y, half_extents.y)
	)
	var global_pos = collider.global_transform * local_offset
	
	# set position and add to scene
	enemy.global_position = global_pos - enemy.get_node("Origin").position
	get_tree().current_scene.add_child(enemy)
