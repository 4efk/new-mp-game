extends Control

@onready var main_menu: Control = $MainMenu
@onready var host_join_browser: Control = $HostJoinBrowser

# main menu buttons
func _on_play_button_pressed() -> void:
	main_menu.hide()
	host_join_browser.show()
func _on_quit_button_pressed() -> void:
	get_tree().quit()

# server browser buttons
func _on_host_button_pressed() -> void:
	Networking.create_server(Networking.DEFAULT_GAME_PORT)

func _on_direct_join_button_pressed() -> void:
	Networking.create_client('localhost', Networking.DEFAULT_GAME_PORT)
	
func _on_back_button_pressed() -> void:
	main_menu.show()
	host_join_browser.hide()
