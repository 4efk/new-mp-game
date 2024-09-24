extends Control

var server_browser_server_button = preload("res://Menu/ServerBrowser/sb_server_button.tscn")

@onready var main_menu: Control = $MainMenu

@onready var host_join_browser: Control = $HostJoinBrowser
@onready var ip_address_lineedit: LineEdit = $HostJoinBrowser/VBoxContainer/Buttons/IPAddress
@onready var port_lineedit: LineEdit = $HostJoinBrowser/VBoxContainer/Buttons/Port
@onready var server_list: VBoxContainer = $HostJoinBrowser/VBoxContainer/ScrollContainer/Servers


@onready var lobby: Control = $Lobby
@onready var players_grid: GridContainer = $Lobby/VBoxContainer/PlayersGrid
@onready var v_box_container: VBoxContainer = $Lobby/VBoxContainer
@onready var ready_button: Button = $Lobby/VBoxContainer/HBoxContainer/ReadyButton
@onready var ready_cooldown_timer: Timer = $Lobby/ReadyCooldownTimer
@onready var start_countdown_timer: Timer = $Lobby/StartCountdownTimer
@onready var start_countdown: Label = $Lobby/StartCountdownContainer/StartCountdown

@onready var customize_ui: Control = $Customize
@onready var customize_ui_player: CharacterBody2D = $Customize/VBoxContainer/Player
@onready var customize_ui_custom_letter_lineedit: LineEdit = $Customize/VBoxContainer/HBoxContainer/CustomLetter

var can_change_ready = true
var start_timer = 5

func _ready() -> void:
	if multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		main_menu.hide()
		lobby.show()
	Networking.in_game = false
	
	# customization ui stuff
	customize_ui_player.modulate = GlobalScript.PLAYER_COLORS[GlobalScript.settings['player_color']]
	customize_ui_player.get_node('CustomLetter').text = GlobalScript.settings['player_custom_letter']
	customize_ui_custom_letter_lineedit.text = GlobalScript.settings['player_custom_letter']

func _process(delta: float) -> void:
	# server browser ui
	var available_servers_names_reformatted = []
	var available_servers_key_strings = []
	
	for available_server in Networking.available_servers.keys():
		available_servers_names_reformatted.append(available_server.replace('.', '_').replace(':', '_'))
		available_servers_key_strings.append(available_server)
	
	for available_server in available_servers_names_reformatted:
		if !server_list.has_node(available_server):
			var server_button_instance = server_browser_server_button.instantiate()
			server_button_instance.name = available_server
			server_button_instance.text = available_servers_key_strings[available_servers_names_reformatted.find(available_server)] + ' - ' + str(Networking.available_servers[available_servers_key_strings[available_servers_names_reformatted.find(available_server)]][2]) + '/4 players'
			server_button_instance.ip_address = Networking.available_servers[available_servers_key_strings[available_servers_names_reformatted.find(available_server)]][0]
			server_button_instance.port = Networking.available_servers[available_servers_key_strings[available_servers_names_reformatted.find(available_server)]][1]
			server_list.add_child(server_button_instance)
	
	#for server_button in server_list.get_children():
		#if not server_button.name in available_servers_names_reformatted:
			#server_button.queue_free()
	
	# lobby ui
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
		players_grid.get_child(i).get_node('CustomLetter').text = Networking.connected_players[player]['custom_letter']
		players_grid.get_child(i).modulate = GlobalScript.PLAYER_COLORS[Networking.connected_players[player]['color']]
		players_grid.get_child(i + 4).hide()
		i += 1
		
		if !Networking.connected_players[player]['ready']:
			start_timer = 5
			start_countdown_timer.stop()
		else:
			ready_players.append(player)
	
	if len(Networking.connected_players) == len(ready_players) and start_countdown_timer.is_stopped() and start_timer > 0 and lobby.visible:
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
func _on_customize_button_pressed() -> void:
	main_menu.hide()
	customize_ui.show()
func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
func _on_quit_button_pressed() -> void:
	get_tree().quit()

# server browser buttons
func _on_host_button_pressed() -> void:
	Networking.create_server(Networking.DEFAULT_GAME_PORT)
	host_join_browser.hide()
	lobby.show()
func _on_direct_join_button_pressed() -> void:
	Networking.create_client(ip_address_lineedit.text, int(port_lineedit.text))# Networking.DEFAULT_GAME_PORT)
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
		Networking.change_own_ready_state(GlobalScript.self_player_info['ready'])
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
		start_countdown_timer.stop()
		
# customize stuff
func _on_choose_color_button_pressed() -> void:
	if GlobalScript.settings['player_color'] + 1 >= len(GlobalScript.PLAYER_COLORS):
		GlobalScript.settings['player_color'] = 0
	else:
		GlobalScript.settings['player_color'] += 1
	GlobalScript.apply_settings()
	GlobalScript.save_settings()
	
	customize_ui_player.modulate = GlobalScript.PLAYER_COLORS[GlobalScript.settings['player_color']]
func _on_custom_letter_text_changed(new_text: String) -> void:
	GlobalScript.settings['player_custom_letter'] = customize_ui_custom_letter_lineedit.text
	GlobalScript.apply_settings()
	GlobalScript.save_settings()
	
	customize_ui_player.get_node('CustomLetter').text = GlobalScript.settings['player_custom_letter']
func _on_c_back_button_pressed() -> void:
	customize_ui.hide()
	main_menu.show()

# popups stuff
func _on_popup_close_button_pressed() -> void:
	get_node("Popups/Popup1").hide()
