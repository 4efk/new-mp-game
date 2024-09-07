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
	
	print('created server')
	
func create_client(ip, port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func _on_connected_ok():
	print("connected to server")
func _on_connected_fail():
	print("connectection failed")
func _on_server_disconnected():
	print("disconnected from server")
func _on_peer_connected(id):
	print(str(id) + " connected")
func _on_peer_disconnected(id):
	print(str(id) + " disconnected")

func advertise_server():
	broadcaster.put_packet("hi, can you hear me?".to_ascii_buffer())

func close_server():
	pass

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

func _on_broadcast_timer_timeout() -> void:
	advertise_server()
