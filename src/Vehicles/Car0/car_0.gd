extends VehicleBody3D

@export var speed = 4000
@export var breaking_force = 150
@export var steering_speed: float = 7.5

func _physics_process(delta: float) -> void:
	engine_force = Input.get_axis("forward", "backward") * speed
	
	if Input.get_axis("right", "left"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, 'steering', Input.get_axis("right", "left") * PI/10, 1/steering_speed)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, 'steering', 0, 1/steering_speed)
	
	brake = int(Input.is_action_pressed("brake")) * breaking_force
	
	print($WheelFL.get_rpm())
	
	#$WheelFL.brake = int(Input.is_action_pressed("brake")) * breaking_force
	#$WheelFR.brake = int(Input.is_action_pressed("brake")) * breaking_force
	#$WheelRL.brake = int(Input.is_action_pressed("brake")) * breaking_force
	#$WheelRR.brake = int(Input.is_action_pressed("brake")) * breaking_force
