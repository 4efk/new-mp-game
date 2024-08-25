extends Control

#var ip_address = ''
#var port = 4242

@onready var console_output = $VBoxContainer/ConsoleOutput
@onready var ip_address_input = $VBoxContainer/IPAddress
@onready var port_input = $VBoxContainer/Port

func create_server(port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 10)
	multiplayer.multiplayer_peer = peer
	
func create_client(ip, port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id):
	console_output.text += 'peer ' + str(id) + ' connected\n'
	
func _on_connected_ok():
	console_output.text += 'connected to server\n'


func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	#multiplayer.connection_failed.connect(_on_connected_fail)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connect_button_pressed():
	create_client(ip_address_input.text, int(port_input.text))
	
	console_output.text += 'connecting to server\n'

func _on_host_button_pressed():
	create_server(int(port_input.text))
	
	console_output.text += 'created server\n'
