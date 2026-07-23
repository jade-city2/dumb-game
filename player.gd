extends CharacterBody2D
class_name PlayerThing

signal signal_name

@export var hello_there:bool = false
@export var items:Array[BaseItem] = []

const MAX_SPEED:float = 480.0
const GRAVITY:float = 9.5
const JMP:float = 480.0
var acc:float = 10.5
var dec:float = acc # NOTE: IT WORKS, JUST LOOKS UGLY

var max_player_health:int = 20
var player_health:int = 20

var has_double_jump:bool = true

var direction:int
var aim_dir:float

const PROJECTILE_SCENE = preload("res://items_and_Stuff/projectile.tscn")
var projectile_speed = 750.0

func _ready() -> void:
	update_health()

func update_health() -> void:
	for i in $CanvasLayer/Control/MarginContainer/HBoxContainer.get_children():
		i.queue_free()
	
	var healthy_slots = max_player_health - player_health
	var gold_slots = player_health - max_player_health
	for i in max_player_health:
		var new_health_bit = ColorRect.new()
		new_health_bit.color = Color(0.5,0,0,1) if healthy_slots > 0 else Color(1,0,0,1)
		if gold_slots > 0:
			new_health_bit.color = Color(1,0.8,0,1) if gold_slots < 20 else Color(1,0,1,1)
			gold_slots -= 1
		new_health_bit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		$CanvasLayer/Control/MarginContainer/HBoxContainer.add_child(new_health_bit)
		healthy_slots -= 1
	print(player_health)

func _physics_process(_delta: float) -> void:
	if is_on_floor():
		velocity.y = 0
		has_double_jump = true
		if Input.is_action_just_pressed("ui_accept"): velocity.y = -JMP
	else:
		velocity.y += GRAVITY + (GRAVITY * int(velocity.y > 0))
		if has_double_jump && Input.is_action_just_pressed("ui_accept"):
			velocity.y = -JMP
			has_double_jump = false
	
	direction = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
	velocity.x += direction * (acc + (acc if sign(direction) * sign(velocity.x) < 0 else 0.0)) if has_double_jump else direction * (acc/2)
	if is_on_floor() && direction != 0: velocity.x = clampf(velocity.x, -MAX_SPEED, MAX_SPEED)
	if direction == 0:
		velocity.x -= (dec * sign(velocity.x))
	
	if Input.is_action_just_pressed("ui_cancel"):
		for i in items:
			print(i.item_name)
		emit_signal("signal_name")
	
	var mouse_pos = get_global_mouse_position()
	aim_dir = global_position.angle_to_point(mouse_pos)
	$Node2D.rotation = aim_dir
	
	if Input.is_action_just_pressed("shoot"):
		launch_projectile()
	
	move_and_slide()

func launch_projectile() -> void:
	var projectile = PROJECTILE_SCENE.instantiate()
	var projectile_direction: Vector2 = Vector2(cos(aim_dir), sin(aim_dir))
	projectile.velocity = projectile_direction * projectile_speed
	projectile.global_position = $Node2D/Marker2D.global_position
	get_parent().add_child(projectile)

func take_damage():
	player_health -= 1
	$OuchieBox/CollisionShape2D2.set_deferred("disabled", true)
	await create_tween().tween_property($Sprite2D, "modulate", Color(1.0,0.0,0.0,1.0), 0.2).finished
	update_health()
	if player_health > 0:
		await create_tween().tween_property($Sprite2D, "modulate", Color(1.0,1.0,1.0,1.0), 0.2).finished
		$OuchieBox/CollisionShape2D2.set_deferred("disabled", false)
	else:
		get_tree().reload_current_scene()

func ouchies_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	take_damage()
