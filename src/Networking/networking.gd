extends Node

func create_server(port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 4)
	multiplayer.multiplayer_peer = peer
	
func create_client(ip, port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
