extends Area2D

signal player_dead
onready var player = get_tree().get_root().find_node("Player")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Spike_body_entered(body):
	print("entereeee")
	get_tree().reload_current_scene()
