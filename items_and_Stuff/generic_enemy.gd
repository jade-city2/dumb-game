extends BaseEnemy
class_name GenericEnemy

var player:PlayerThing = null

const PROJECTILE_SCENE = preload("res://items_and_Stuff/enemy_projectile.tscn")
const HEALTH_PICKUP_SCENE = preload("res://items_and_Stuff/health_pickup.tscn")

var has_double_jump:bool = false

var timer:float = 0.5
var aim_dir:float

func _ready() -> void:
	randomize()

func _physics_process(delta: float) -> void:
	if !damaged:
		if is_on_floor():
			velocity.y = 0
			has_double_jump = true
		else:
			velocity.y += 9.5 + (9.5 * int(velocity.y > 0))
		if player:
			position.x = move_toward(global_position.x, player.global_position.x, 2)
			if is_on_floor() && (player.global_position.y - global_position.y) < -200:
				velocity.y = -480.0
			elif is_on_floor() && (player.global_position.y - global_position.y) < -200:
				if has_double_jump && velocity.y >= 0.0:
					velocity.y = -480.0
					has_double_jump = false
			aim_dir = global_position.angle_to_point(player.global_position)
			$Node2D.rotation = aim_dir
			timer -= delta
			if timer < 0.0:
				shoot_player()
				randomize()
				timer = randf_range(0.1, 0.7)
	
	move_and_slide()

func player_detected(body: Node2D) -> void:
	if body is PlayerThing:
		player = body
		randomize()
		timer = randf_range(0.1, 0.7)

func player_exited(body: Node2D) -> void:
	if body is PlayerThing:
		player = null

func hurt_box_entered(body: Node2D) -> void:
	if body is PlayerProjectile:
		damage()

func shoot_player():
	var projectile = PROJECTILE_SCENE.instantiate()
	var projectile_direction: Vector2 = Vector2(cos(aim_dir), sin(aim_dir))
	projectile.velocity = projectile_direction * 1200
	projectile.global_position = $Node2D/Marker2D.global_position
	get_parent().add_child(projectile)

func damage():
	health -= 1
	
	damaged = true
	$HurtBox/CollisionShape2D2.set_deferred("disabled", true)
	await create_tween().tween_property($EvilGodotLogo, "modulate", Color(1.0,0.0,0.0,1.0), 0.2).finished
	await create_tween().tween_property($EvilGodotLogo, "modulate", Color(1.0,1.0,1.0,1.0), 0.2).finished
	
	if health <= 0:
		die()
	else:
		damaged = false
		$HurtBox/CollisionShape2D2.set_deferred("disabled", false)

func die():
	var health_pickup = HEALTH_PICKUP_SCENE.instantiate()
	health_pickup.global_position = global_position
	get_parent().add_child(health_pickup)
	await create_tween().tween_property($EvilGodotLogo, "modulate", Color(1.0,1.0,1.0,0.0), 0.5).finished
	queue_free()

func _hurt_box_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	damage()
