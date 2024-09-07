extends Node2D

var player_scene = preload("res://Player/player.tscn")

@onready var spawnpoints: Node = $Spawnpoints
@onready var players: Node = $Players

func _ready() -> void:
	var i = 0
	for player in Networking.connected_players:
		var player_instance = player_scene.instantiate()
		player_instance.name = str(player)
		player_instance.get_node('CustomLetter').text = Networking.connected_players[player]['custom_letter']
		player_instance.global_position = spawnpoints.get_child(i).global_position
		players.add_child(player_instance)
		
		i += 1
