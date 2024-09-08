extends CharacterBody2D

var bullet_scene = preload("res://Player/bullet.tscn")

var speed = 300.0
var move_direction = 0
var network_id

@onready var move_timer: Timer = $MoveTimer
@onready var barrel_end: Marker2D = $BarrelEnd

#func move_move(dir):
	#move_direction = dir
	#move_timer.start()
	
#func move_rotate(dir):
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, 'rotation', rotation + PI/8 * dir, 1)
	#move_timer.start()
	
func move_forward():
	move_direction = 1
	move_timer.start()
func move_backward():
	move_direction = -1
	move_timer.start()
func move_rotate_cw():
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'rotation', rotation + PI/8 * 1, 1)
	move_timer.start()
func move_rotate_ccw():
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'rotation', rotation + PI/8 * -1, 1)
	move_timer.start()
func move_shoot():
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.direction = Vector2(1, 0).rotated(rotation)
	bullet_instance.global_position = barrel_end.global_position
	get_parent().get_parent().get_node('Bullets').add_child(bullet_instance)

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("forward"):
		#move_shoot()
	#if Input.is_action_just_pressed("backward"):
		#move_move(-1)
	#if Input.is_action_just_pressed("left"):
		#move_rotate(-1)
	#if Input.is_action_just_pressed("right"):
		#move_rotate(1)

func _physics_process(delta: float) -> void:
	if move_timer.is_stopped():
		return
	
	velocity = Vector2(1, 0).rotated(rotation) * speed * move_direction
	
	move_and_slide()
	
	# the animation

func _on_move_timer_timeout() -> void:
	move_direction = 0
