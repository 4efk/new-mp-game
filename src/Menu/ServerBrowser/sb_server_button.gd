extends Button

@export var ip_address = 'localhost'
@export var port = 4242

func _on_pressed() -> void:
	Networking.create_client(ip_address, port)
