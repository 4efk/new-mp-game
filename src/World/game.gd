extends Node2D

const PLAYER_MOVE_OPTIONS = ['move_forward', 'move_backward', 'move_rotate_cw', 'move_rotate_ccw', 'move_shoot']
var player_scene = preload("res://Player/player.tscn")

@onready var spawnpoints: Node = $Spawnpoints
@onready var players: Node = $Players
@onready var bullets: Node = $Bullets

@onready var move_timer: Timer = $MoveTimer
@onready var move_options_buttons: HBoxContainer = $Ui/SelectMove/VBoxContainer/MoveOptions
@onready var selected_move_label: Label = $Ui/SelectedMove/SelectedMove
@onready var select_move_ui: Control = $Ui/SelectMove

var current_round = 0
var currently_playing_moves = false
var move_chosen = false
var current_chosen_move = null

func _ready() -> void:
	var i = 0
	for player in Networking.connected_players:
		var player_instance = player_scene.instantiate()
		player_instance.name = str(player)
		player_instance.get_node('CustomLetter').text = Networking.connected_players[player]['custom_letter']
		player_instance.modulate = GlobalScript.PLAYER_COLORS[Networking.connected_players[player]['color']]
		player_instance.global_position = spawnpoints.get_child(i).global_position
		players.add_child(player_instance)
		
		i += 1

func _process(delta: float) -> void:
	var players_with_move = []
	for player in Networking.connected_players:
		if Networking.connected_players[player]['move'] != null:
			players_with_move.append(player)
	if len(players_with_move) == len(Networking.connected_players) and multiplayer.is_server():
		Networking.act_all_clients_moves()
		make_all_moves()
	if currently_playing_moves and move_timer.is_stopped() and !bullets.get_child_count() and multiplayer.is_server():
		Networking.finish_clients_moves()
		moves_done()

func make_all_moves():
	currently_playing_moves = true
	move_timer.start()
	current_round += 1
	for player in Networking.connected_players:
		players.get_node(str(player)).call(PLAYER_MOVE_OPTIONS[Networking.connected_players[player]['move']])
		Networking.connected_players[player]['move'] = null

func moves_done():
	currently_playing_moves = false
	current_chosen_move = null
	move_chosen = false
	for button in move_options_buttons.get_children():
		button.set_pressed_no_signal(false)
	selected_move_label.get_parent().hide()
	select_move_ui.show()

# move select buttons
func choose_move(move):
	if move_chosen:
		move_options_buttons.get_child(move).set_pressed_no_signal(false)
		return
	for button in move_options_buttons.get_children():
		if move_options_buttons.get_children().find(button) == move:
			button.set_pressed_no_signal(true)
		else:
			button.set_pressed_no_signal(false)
	current_chosen_move = move

func _on_move_confirm_button_pressed() -> void:
	move_chosen = true
	GlobalScript.self_player_info['move'] = current_chosen_move
	if multiplayer.is_server():
		Networking.send_all_info_to_clients()
	else:
		Networking.make_own_move(GlobalScript.self_player_info['move'])
	selected_move_label.text = PLAYER_MOVE_OPTIONS[current_chosen_move]
	select_move_ui.hide()
	selected_move_label.get_parent().show()
func _on_move_button_pressed() -> void:
	choose_move(0)
func _on_move_button_1_pressed() -> void:
	choose_move(1)
func _on_move_button_2_pressed() -> void:
	choose_move(2)
func _on_move_button_3_pressed() -> void:
	choose_move(3)
func _on_move_button_4_pressed() -> void:
	choose_move(4)
