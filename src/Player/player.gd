extends CharacterBody2D

var placed_light_scene = preload("res://World/2D/Props/placed_light.tscn")
var bullet_scene = preload("res://Guns/bullet.tscn")

var speed = 300.0
var jump_velocity = -400.0
var friction = 200.0
var climb_speed = -200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var climb_gravity = 980

var climbing = false

func die():
	queue_free()

func _process(delta):
	$Head.look_at(get_global_mouse_position())
	print($Head.rotation_degrees)
	print(get_viewport().get_mouse_position())
	
	if Input.is_action_just_pressed("place_light"):
		var placed_light_instance = placed_light_scene.instantiate()
		placed_light_instance.global_position = global_position
		get_parent().get_node("Lights").add_child(placed_light_instance)
		
	if Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.global_position = $Head.global_position + Vector2(50, 0).rotated($Head.rotation)
		bullet_instance.initial_velocity = Vector2(1, 0).rotated($Head.rotation)
		get_parent().add_child(bullet_instance)

func _physics_process(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor() and !climbing:
		velocity.y = jump_velocity
	if climbing and Input.is_action_pressed("jump"):
		velocity.y = climb_speed# * int(Input.is_action_pressed("jump"))

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed

	velocity.x = move_toward(velocity.x, 0, 50)
	
	if not is_on_floor() and not climbing:
		velocity.y += gravity * delta
	elif climbing:
		velocity.y += climb_gravity * delta
		velocity.y = clamp(velocity.y, -2000, 300)

	move_and_slide()
