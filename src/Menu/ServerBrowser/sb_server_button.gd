extends Button

@export var ip_address = 'localhost'
@export var port = Networking.DEFAULT_GAME_PORT

func _on_pressed() -> void:
	Networking.create_client(ip_address, port)
