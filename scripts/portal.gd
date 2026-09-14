extends Area2D


func _on_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scene/game03.tscn")
