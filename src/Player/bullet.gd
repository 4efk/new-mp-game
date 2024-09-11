extends CharacterBody2D

const SPEED = 20.0

var direction = Vector2(0, 0)
var collision
var bounces_left = 3

func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	collision = move_and_collide(velocity)
	
	if collision:
		var body = collision.get_collider()
		if body == self:
			return
		if body.is_in_group('player'):
			body.hit()
			queue_free()
		elif bounces_left <= 0:
			queue_free()
		else:
			bounces_left -= 1
			direction = direction.bounce(collision.get_normal())
