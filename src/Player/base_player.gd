extends CharacterBody2D

var bullet_scene = preload("res://Player/bullet.tscn")

var speed = 300.0
var move_direction = 0
var network_id
var move_time = 1.0

var track_states = ['~-~-~-~', '-~-~-~-']

@onready var move_timer: Timer = $MoveTimer
@onready var barrel_end: Marker2D = $BarrelEnd
@onready var left_track: Label = $LeftTrack
@onready var right_track: Label = $RightTrack

func move_forward():
	move_direction = 1
	move_timer.start()
func move_backward():
	move_direction = -1
	move_timer.start()
func move_rotate_cw():
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'rotation', rotation + PI/8 * 1, move_time)
	move_timer.start()
func move_rotate_ccw():
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'rotation', rotation + PI/8 * -1, move_time)
	move_timer.start()
func move_shoot():
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.direction = Vector2(1, 0).rotated(rotation)
	bullet_instance.global_position = barrel_end.global_position
	bullet_instance.get_node('Letter').text = get_node("CustomLetter").text
	bullet_instance.modulate = modulate
	get_parent().get_parent().get_node('Bullets').add_child(bullet_instance)

func hit():
	Networking.connected_players[int(str(name))]['alive'] = false
	if multiplayer.is_server():
		Networking.send_all_info_to_clients()
	queue_free()

func _ready() -> void:
	if multiplayer.is_server():
		Networking.connected_players[int(str(name))]['transforms'] = [global_position, rotation]

func _physics_process(delta: float) -> void:
	if move_timer.is_stopped():
		return
	
	if multiplayer.is_server():
		Networking.connected_players[int(str(name))]['transforms'] = [global_position, rotation]
	
	velocity = Vector2(1, 0).rotated(rotation) * speed * move_direction
	
	move_and_slide()
	
	# the animation
	var current_track_state = track_states[int(Time.get_ticks_msec() % 1000 > 500)]
	left_track.text = current_track_state
	right_track.text = current_track_state
	
func _on_move_timer_timeout() -> void:
	move_direction = 0
