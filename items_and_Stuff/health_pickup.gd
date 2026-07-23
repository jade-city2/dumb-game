extends Area2D

func _ready() -> void:
	$Sprite2D.modulate = Color(1,1,1,0)
	create_tween().tween_property($Sprite2D, "modulate", Color(1,1,1,1), 0.2)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerThing:
		body.player_health += 1
		body.update_health()
	await create_tween().tween_property($Sprite2D, "modulate", Color(1,1,1,0), 0.2).finished
	queue_free()
