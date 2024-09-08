extends CharacterBody2D

const SPEED = 20.0

var direction = Vector2(0, 0)
var collision
var bounces_left = 5

func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	collision = move_and_collide(velocity)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		return
	
	if body.is_in_group('player'):
		print('hit')
		queue_free()
	elif bounces_left <= 0:
		queue_free()
	else:
		bounces_left -= 1
		direction = direction.bounce(collision.get_normal())
