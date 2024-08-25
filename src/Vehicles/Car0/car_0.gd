extends VehicleBody3D

@export var speed = 4000

func _physics_process(delta: float) -> void:
	engine_force = Input.get_axis("forward", "backward") * speed

	steering = Input.get_axis("right", "left") * PI/8
