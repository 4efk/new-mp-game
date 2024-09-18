extends Node

const ADVERTISE_LISTEN_PORT = 4243
const ADVERTISE_BROADCAST_PORT = 4344
const DEFAULT_GAME_PORT = 4242

var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
@onready var broadcast_timer: Timer = $BroadcastTimer

var available_servers = []
var server_info = {}
var connected_players = {}
var in_game = false

func create_server(port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 3)
	multiplayer.multiplayer_peer = peer
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address('192.168.1.255', ADVERTISE_LISTEN_PORT)
	# TODO I SHOULD HANDLE ERRORS HERE
	broadcaster.bind(ADVERTISE_BROADCAST_PORT)
	broadcast_timer.start()
	
	# as the dictionary is not duplicated, but directly added there, changes to that dict alone also reflect on the connected_players dict
	connected_players[1] = GlobalScript.self_player_info
	
	print('created server')
	
func create_client(ip, port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func _on_connected_ok():
	send_own_client_info_to_server()
	get_node('/root/MainMenu').connected_to_server()
	
	print("connected to server")
func _on_connected_fail():
	print("connectection failed")
func _on_server_disconnected():
	print("disconnected from server")
func _on_peer_connected(id):
	if Networking.in_game:
		if multiplayer.is_server():
			kick_client(id, 'failed to connect:\ngame in progress')
		return
	Networking.connected_players[id] = GlobalScript.DEFAULT_PLAYER_INFO
	print(str(id) + " connected")
func _on_peer_disconnected(id):
	if Networking.in_game:
		get_node('/root/Game').disconnect_player(id)
	Networking.connected_players.erase(id)
	print(str(id) + " disconnected")

func advertise_server():
	broadcaster.put_packet("hi, can you hear me?".to_ascii_buffer())

func close_server():
	multiplayer.multiplayer_peer = null
	connected_players = {}
	broadcast_timer.stop()
	broadcaster = null

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# LAN server detection
	listener = PacketPeerUDP.new()
	listener.bind(ADVERTISE_LISTEN_PORT)

func _process(delta: float) -> void:
	var packet = listener.get_packet().get_string_from_ascii()
	if packet:
		pass #print(packet)
	
	#print(multiplayer.get_unique_id(), connected_players, '\n')
	
func _on_broadcast_timer_timeout() -> void:
	advertise_server()

# RPCs and despair
func send_own_client_info_to_server():
	rpc_id(1, 'receive_info_from_client', GlobalScript.self_player_info)
func send_all_info_to_clients():
	rpc('receive_all_info_from_server', Networking.connected_players)
func send_all_info_to_client(id):
	rpc_id(id, 'receive_all_info_from_server', Networking.connected_players)
func change_own_ready_state(state):
	rpc_id(1, 'receive_client_ready_change', state)
func start_clients_game():
	rpc('start_game')
func make_own_move(move):
	rpc_id(1, 'receive_client_move', move)
func act_all_clients_moves():
	rpc('act_all_moves')
func finish_clients_moves():
	rpc('finish_all_moves')
func correct_clients_transforms():
	rpc('correct_transforms', Networking.connected_players)
func finish_clients_game():
	rpc('finish_game')
func kick_client(id, msg):
	rpc_id(id, 'kicked_from_server', msg)

@rpc("any_peer", "reliable")
func receive_info_from_client(info):
	connected_players[multiplayer.get_remote_sender_id()] = info
	send_all_info_to_clients()
@rpc("authority", "reliable")
func receive_all_info_from_server(info):
	Networking.connected_players = info
@rpc('any_peer', 'reliable')
func receive_client_ready_change(state):
	Networking.connected_players[multiplayer.get_remote_sender_id()]['ready'] = state
	Networking.send_all_info_to_clients()
@rpc("authority", "reliable")
func start_game():
	get_tree().change_scene_to_file("res://World/game.tscn")
@rpc("any_peer", 'reliable')
func receive_client_move(move):
	Networking.connected_players[multiplayer.get_remote_sender_id()]['move'] = move
	Networking.send_all_info_to_clients()
@rpc("authority", "reliable")
func act_all_moves():
	if Networking.in_game:
		get_node('/root/Game').make_all_moves()
@rpc("authority", "reliable")
func finish_all_moves():
	if Networking.in_game:
		get_node('/root/Game').moves_done()
@rpc("authority", "reliable")
func correct_transforms(info):
	Networking.connected_players = info
	if Networking.in_game:
		get_node('/root/Game').correct_players_transforms()
@rpc("authority", "reliable")
func finish_game():
	if Networking.in_game:
		get_node('/root/Game').game_over()
@rpc("authority", "reliable")
func kicked_from_server(msg):
	multiplayer.multiplayer_peer = null
	print(msg)
