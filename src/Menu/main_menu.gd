extends Control

@onready var main_menu: Control = $MainMenu

@onready var host_join_browser: Control = $HostJoinBrowser

@onready var lobby: Control = $Lobby
@onready var players_grid: GridContainer = $Lobby/VBoxContainer/PlayersGrid
@onready var v_box_container: VBoxContainer = $Lobby/VBoxContainer
@onready var ready_button: Button = $Lobby/VBoxContainer/HBoxContainer/ReadyButton
@onready var ready_cooldown_timer: Timer = $Lobby/ReadyCooldownTimer
@onready var start_countdown_timer: Timer = $Lobby/StartCountdownTimer
@onready var start_countdown: Label = $Lobby/StartCountdownContainer/StartCountdown

var can_change_ready = true
var start_timer = 5

func _process(delta: float) -> void:
	for node in players_grid.get_children():
		if str(node.name).begins_with('Player'):
			node.hide()
		else:
			node.show()
	var i = 0
	var ready_players = []
	for player in Networking.connected_players:
		players_grid.get_child(i).show()
		players_grid.get_child(i).get_node('CustomLetter').text = Networking.connected_players[player]['custom_letter']
		players_grid.get_child(i).get_node('IsReady').text = ['not ready', 'ready'][int(Networking.connected_players[player]['ready'])]
		players_grid.get_child(i + 4).hide()
		i += 1
		
		if !Networking.connected_players[player]['ready']:
			start_timer = 5
			start_countdown_timer.stop()
			print(1)
		else:
			ready_players.append(player)
	
	if len(Networking.connected_players) == len(ready_players) and start_countdown_timer.is_stopped() and start_timer > 0:
		start_countdown_timer.start()
	
	start_countdown.get_parent().visible = !start_countdown_timer.is_stopped()
	start_countdown.text = str(start_timer)

func connected_to_server():
	host_join_browser.hide()
	lobby.show()

# main menu buttons
func _on_play_button_pressed() -> void:
	main_menu.hide()
	host_join_browser.show()
func _on_quit_button_pressed() -> void:
	get_tree().quit()

# server browser buttons
func _on_host_button_pressed() -> void:
	Networking.create_server(Networking.DEFAULT_GAME_PORT)
	host_join_browser.hide()
	lobby.show()

func _on_direct_join_button_pressed() -> void:
	Networking.create_client('localhost', Networking.DEFAULT_GAME_PORT)
	
func _on_back_button_pressed() -> void:
	main_menu.show()
	host_join_browser.hide()

# lobby stuff
func _on_ready_button_toggled(toggled_on: bool) -> void:
	if !can_change_ready:
		ready_button.set_pressed_no_signal(!toggled_on)
		return
	GlobalScript.self_player_info['ready'] = toggled_on
	if multiplayer.get_unique_id() == 1:
		Networking.send_all_info_to_clients()
	else:
		Networking.send_own_client_info_to_server()
	can_change_ready = false
	ready_cooldown_timer.start()
func _on_leave_button_pressed() -> void:
	Networking.close_server()
	host_join_browser.show()
	lobby.hide()
func _on_ready_cooldown_timer_timeout() -> void:
	can_change_ready = true
func _on_start_countdown_timer_timeout() -> void:
	start_timer -= 1
	if start_timer == 0:
		if multiplayer.is_server():
			Networking.start_clients_game()
			get_tree().change_scene_to_file("res://World/game.tscn")
		print('game started')
		start_countdown_timer.stop()
