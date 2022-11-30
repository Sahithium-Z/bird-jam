extends Area2D

onready var collisionShape2D = $CollisionShape2D
onready var animatedSprite = $AnimatedSprite

signal player_touched

func _on_body_entered(body):
	if body is Player:
		collisionShape2D.set_deferred("disabled", true)
		animatedSprite.visible = false
		emit_signal("player_touched")
		yield(get_tree().create_timer(10.0), "timeout")
		collisionShape2D.set_deferred("disabled", false)
		animatedSprite.visible = true
