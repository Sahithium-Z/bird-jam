extends Area2D

export(String, FILE, "*.tscn") var target_path = ""


func _on_Door_entered(body):
	if not body is Player: return
	if target_path.empty(): return
	get_tree().change_scene(target_path)
