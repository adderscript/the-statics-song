extends CPUParticles2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = lifetime
	timer.timeout.connect(func(): queue_free())
	
	emitting = true
	timer.start()
