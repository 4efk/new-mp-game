extends Node

# white, black, red, green, yellow, orange, violet, cyan
const PLAYER_COLORS = ['#fff1f3', '#000000', '#fd6883', '#adda78', '#f9cc6c', '#f38d70', '#a8a9eb', '#85dacc']
const DEFAULT_SETTINGS = {
	'fullscreen': true,
}
const DEFAULT_PLAYER_INFO = {'color': 0, 'custom_letter': "H", 'ready': false, 'alive':false, 'move':null, 'transforms': [Vector2(), PI/2]}

var settings = DEFAULT_SETTINGS.duplicate()
var self_player_info = DEFAULT_PLAYER_INFO.duplicate()
