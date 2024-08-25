extends CharacterBody2D

var speed = 350.0
var jump_velocity = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var following

func shot():
	queue_free()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var placed_lights_distances = []
	var placed_lights_distances_dict = {}
	for placed_light in get_node("../Lights").get_children():
		placed_lights_distances_dict[(placed_light.global_position - global_position).length()] = placed_light
		placed_lights_distances.append((placed_light.global_position - global_position).length())
	placed_lights_distances.sort()
	
	if placed_lights_distances:
		following = placed_lights_distances_dict[placed_lights_distances[0]]
	else:
		following = null
	
	if following:
		velocity.x = (following.global_position - global_position).normalized().x * speed
	else:
		velocity.x = (get_parent().get_node("Player").global_position - global_position).normalized().x * speed

		#velocity.y = JUMP_VELOCITY

	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.die()
