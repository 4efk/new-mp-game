extends Node2D

const PLAYER_MOVE_OPTIONS = ['move_forward', 'move_backward', 'move_rotate_cw', 'move_rotate_ccw', 'move_shoot']
const PLAYER_MOVE_OPTIONS_NAMES = ['move forward', 'move backward', 'rotate right', 'rotate left', 'shoot']
var player_scene = preload("res://Player/player.tscn")

@onready var spawnpoints: Node = $Spawnpoints
@onready var players: Node = $Players
@onready var bullets: Node = $Bullets

@onready var move_timer: Timer = $MoveTimer
@onready var move_options_buttons: HBoxContainer = $Ui/SelectMove/VBoxContainer/MoveOptions
@onready var selected_move_label: Label = $Ui/SelectedMove/SelectedMove
@onready var select_move_ui: Control = $Ui/SelectMove
@onready var spectating_info_ui: Control = $Ui/SpectatingInfo
@onready var game_over_screen_timer: Timer = $GameOverScreenTimer
@onready var game_over_ui: Control = $Ui/GameOver
@onready var go_round_count: Label = $Ui/GameOver/RoundCount

var current_round = 0
var game_finished = false
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
		Networking.connected_players[player]['alive'] = true
		
		i += 1
	Networking.in_game = true

func _process(delta: float) -> void:
	if game_finished:
		return
	var players_with_move = []
	for player in Networking.connected_players:
		if Networking.connected_players[player]['move'] != null:
			players_with_move.append(player)
	var dead_players = []
	for player in Networking.connected_players:
		if !Networking.connected_players[player]['alive']:
			dead_players.append(player)
	if len(players_with_move) + len(dead_players) == len(Networking.connected_players) and !currently_playing_moves and multiplayer.is_server():
		Networking.act_all_clients_moves()
		make_all_moves()
	if currently_playing_moves and move_timer.is_stopped() and !bullets.get_child_count() and multiplayer.is_server():
		Networking.finish_clients_moves()
		moves_done()

func disconnect_player(player):
	if players.has_node(str(player)):
		players.get_node(str(player)).queue_free()

func make_all_moves():
	currently_playing_moves = true
	move_timer.start()
	current_round += 1
	for player in Networking.connected_players:
		if Networking.connected_players[player]['alive']:
			players.get_node(str(player)).call(PLAYER_MOVE_OPTIONS[Networking.connected_players[player]['move']])
			Networking.connected_players[player]['move'] = null

func moves_done():
	currently_playing_moves = false
	current_chosen_move = null
	move_chosen = false
	for button in move_options_buttons.get_children():
		button.set_pressed_no_signal(false)
	selected_move_label.get_parent().hide()
	if Networking.connected_players[multiplayer.get_unique_id()]['alive']:
		select_move_ui.show()
	else:
		spectating_info_ui.show()
	
	if !multiplayer.is_server():
		return
		
	#Networking.send_all_info_to_clients()
	Networking.correct_clients_transforms()
		
	var alive_players = []
	for player in Networking.connected_players:
		if Networking.connected_players[player]['alive']:
			alive_players.append(players)
	if len(alive_players) < 2:
		Networking.finish_clients_game()
		game_over()

func correct_players_transforms():
	for player in players.get_children():
		var tween = get_tree().create_tween()
		tween.tween_property(player, 'global_position', Networking.connected_players[int(str(player.name))]['transforms'][0], 0.25)

func game_over():
	game_finished = true
	select_move_ui.hide()
	spectating_info_ui.hide()
	selected_move_label.get_parent().hide()
	game_over_ui.show()
	go_round_count.text = 'turns: ' + str(current_round)
	var winner
	for player in Networking.connected_players:
		if Networking.connected_players[player]['alive']:
			winner = player
	if winner:
		game_over_ui.get_node('Winner').show()
		game_over_ui.get_node('Winner/WinnerPlayer').get_node('CustomLetter').text = Networking.connected_players[winner]['custom_letter']
		game_over_ui.get_node('Winner/WinnerPlayer').modulate = GlobalScript.PLAYER_COLORS[Networking.connected_players[winner]['color']]
	else:
		game_over_ui.get_node('Draw').show()
	game_over_screen_timer.start()

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
	if current_chosen_move == null:
		return
	move_chosen = true
	GlobalScript.self_player_info['move'] = current_chosen_move
	if multiplayer.is_server():
		Networking.send_all_info_to_clients()
	else:
		Networking.make_own_move(GlobalScript.self_player_info['move'])
	selected_move_label.text = 'selected move: ' + PLAYER_MOVE_OPTIONS_NAMES[current_chosen_move]
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

# game over screen
func _on_game_over_screen_timer_timeout() -> void:
	for player in Networking.connected_players:
		Networking.connected_players[player]['alive'] = GlobalScript.DEFAULT_PLAYER_INFO['alive']
		Networking.connected_players[player]['move'] = GlobalScript.DEFAULT_PLAYER_INFO['move']
		Networking.connected_players[player]['ready'] = GlobalScript.DEFAULT_PLAYER_INFO['ready']
		
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
