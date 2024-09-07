extends Node

const DEFAULT_SETTINGS = {
	'fullscreen': true,
}
const DEFAULT_PLAYER_INFO = {'color': 0, 'custom_letter': "H", 'ready': false, 'transforms': [Vector2(), PI/2]}

var settings = DEFAULT_SETTINGS.duplicate()
var self_player_info = DEFAULT_PLAYER_INFO.duplicate()
