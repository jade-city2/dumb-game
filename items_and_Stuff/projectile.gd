extends CharacterBody2D
class_name PlayerProjectile

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _ready() -> void:
	get_tree().create_timer(5.0).timeout.connect(literally_just_explode)
	#make a timer, explode on timeout

func _on_area_2d_body_entered(_body: Node2D) -> void:
	literally_just_explode()

func literally_just_explode() -> void:
	velocity = Vector2.ZERO #set movement to zero
	$AnimationPlayer.play("anim") #play the explosion animation
	await $AnimationPlayer.animation_finished #wait for the animation to finish
	queue_free() #remove this object from the node tree

func on_area_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	literally_just_explode()

func on_explosion_area_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	pass # Replace with function body.

func on_explosion_body_entered(body: Node2D) -> void:
	if body is PlayerThing:
		#angle for aiming the player.
		var aim_angle:float = global_position.angle_to_point(body.global_position)
		var player_direction:Vector2 = Vector2(cos(aim_angle), sin(aim_angle))
		body.velocity += player_direction * 1250
	if body is BaseEnemy:
		if !body.damaged: body.damage()
