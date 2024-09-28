extends CharacterBody2D

func _process(delta: float) -> void:
	rotation += delta
	#global_position = Vector2(960, 700) #get_viewport_rect().get_center()
	#global_position.y += 100
