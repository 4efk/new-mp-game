extends CharacterBody3D

var placed_light_scene = preload("res://World/3D/Props/placed_light_3d.tscn")

@export var speed = 5.0
@export var jump_velocity = 4.0
@export var base_look_sensitivity = 0.003
@export var acceleration_ground = 35.0
@export var acceleration_air = 3.0
@export var weapon_range = 20

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var acceleration = 1
var horizontal_velocity = Vector3()
var vertical_velocity = 0

var hp = 100

@onready var camera = $Head/Camera3D
@onready var head = $Head

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func  _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * base_look_sensitivity)
		head.rotate_x(-event.relative.y * base_look_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

func _process(delta):
	if Input.is_action_just_pressed("place_light"):
		# NOT ROTATED
		#
		var place_position = $Head/Marker3D.global_position
		if $Head/RayCast3D.is_colliding():
			place_position = $Head/RayCast3D.get_collision_point()
		var placed_light_instance = placed_light_scene.instantiate()
		placed_light_instance.global_position = place_position
		get_parent().get_node("Lights").add_child(placed_light_instance)

func  _physics_process(delta):
	#movement
	horizontal_velocity = Input.get_vector("left", "right", "forward", "backward").normalized() * speed
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'velocity', horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z, 1/acceleration)
	
	if is_on_floor():
		acceleration = acceleration_ground
		vertical_velocity = 0
		if Input.is_action_just_pressed("jump"): vertical_velocity = jump_velocity
	else:
		acceleration = acceleration_air
		vertical_velocity -= gravity * delta
	
	velocity.y = vertical_velocity
	move_and_slide()
