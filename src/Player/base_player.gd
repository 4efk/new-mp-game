extends CharacterBody2D

var speed = 300.0

var move_direction = 0

var network_id

@onready var move_timer: Timer = $MoveTimer

func move_move(dir):
	move_direction = dir
	move_timer.start()

func move_rotate(dir):
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'rotation', rotation + PI/8 * dir, 1)
	move_timer.start()

func move_shoot():
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("forward"):
		move_move(1)
	if Input.is_action_just_pressed("backward"):
		move_move(-1)
	if Input.is_action_just_pressed("left"):
		move_rotate(-1)
	if Input.is_action_just_pressed("right"):
		move_rotate(1)

func _physics_process(delta: float) -> void:
	if move_timer.is_stopped():
		return
	
	velocity = Vector2(1, 0).rotated(rotation) * speed * move_direction
	
	move_and_slide()

func _on_move_timer_timeout() -> void:
	move_direction = 0
