extends CharacterBody2D

var bullet_speed = 50 #500
var initial_velocity = Vector2()

func _physics_process(delta):
	velocity = initial_velocity * bullet_speed

	#move_and_slide()
	move_and_collide(velocity)

func _on_area_2d_body_entered(body):
	if !body.is_in_group("bullet") and !body.is_in_group("player"):
		queue_free()
	if body.is_in_group("shootable"):
		body.shot()
