extends Node

const SETTINGS_FILEPATH = 'user://settings.dat'

# white, black, red, green, yellow, orange, violet, cyan
const PLAYER_COLORS = ['#fff1f3', '#000000', '#fd6883', '#adda78', '#f9cc6c', '#f38d70', '#a8a9eb', '#85dacc']
const DEFAULT_SETTINGS = {
	'fullscreen': true,
	'sfx_volume': 0,
	'music_volume': 0,
	'player_color': 0,
	'player_custom_letter': "H",
}
const DEFAULT_PLAYER_INFO = {'color': 6, 'custom_letter': "H", 'ready': false, 'alive':false, 'move':null, 'transforms': [Vector2(), PI/2]}

var settings = DEFAULT_SETTINGS.duplicate()
var self_player_info = DEFAULT_PLAYER_INFO.duplicate()

func _ready() -> void:
	load_settings()
	apply_settings()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		settings['fullscreen'] = !settings['fullscreen']
		DisplayServer.window_set_mode(4 * int(settings['fullscreen']))
		save_settings()

func apply_settings():
	DisplayServer.window_set_mode(4 * int(settings['fullscreen']))
	
	self_player_info['color'] = settings['player_color']
	self_player_info['custom_letter'] = settings['player_custom_letter']

func save_settings():
	var error = FileAccess.open(SETTINGS_FILEPATH, FileAccess.WRITE)
	error.store_var(settings)
	error.close()
func load_settings():
	if FileAccess.file_exists(SETTINGS_FILEPATH):
		var error = FileAccess.open(SETTINGS_FILEPATH, FileAccess.READ)
		if error:
			settings = error.get_var()
			error.close()
