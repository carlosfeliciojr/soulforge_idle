extends CharacterBody2D

## Entity is a abstract class and should not be instantiated.
##
## Abstract base class for top-down moving entities.
## Handles animations, sound playback, and movement logic.
## Should be extended by characters like the player and monsters.
class_name Entity

const CombatState = preload("res://globals/enums/combat_states.gd").CombatState

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var detection_shape: CollisionShape2D = $DetectionArea/DetectionShape

@export var health: float
@export var attack_damage: float
@export var defense_chance: float
@export var move_speed: float
@export var attack_speed: float
@export var detection_radius: float
@export var attack_range: float

var state: CombatState = CombatState.IDLE
var target: Entity
var is_attacking: bool = false
var is_defending: bool = false

func _ready() -> void:
	var circle = CircleShape2D.new()
	circle.radius = detection_radius
	detection_shape.shape = circle
	detection_shape.debug_color = Color("ab82006b")
	detection_shape.position = collision_shape.position
	
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	sprite.z_index = int(global_position.y)


func play_animation(name: String) -> void:
	if sprite.animation != name:
		sprite.play(name)


func force_play_animation(name: String) -> void:
	sprite.play(name)
	sprite.frame = 0


func flip_sprite(direction_x: float):
	if abs(direction_x) > 0.01:
		sprite.flip_h = direction_x < 0


func attack_target(target: Entity) -> void:
	if target == null or is_instance_valid(target) == false: return
	if is_attacking: return
	if target.has_method("receive_attack"):
		is_attacking = true
		target.receive_attack(attack_damage)
		play_animation("attack")


func _on_animation_finished() -> void:
	match sprite.animation:
		"attack":
			sprite.play("idle")
			await get_tree().create_timer(1.0).timeout
			is_attacking = false
		"defend":
			is_defending = false
			sprite.play("idle")
		"idle":
			pass


func receive_attack(damage: float) -> void:
	if randf() > defense_chance:
		health -= damage
		state = CombatState.BEING_HIT
		print("Levou dano")
	else:
		is_defending = true
		force_play_animation("defend")
		print("Defendendo!")
	if health <= 0:
		state = CombatState.DEAD


func _on_detection_area_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_detection_area_area_exited(area: Area2D) -> void:
	pass # Replace with function body.


func _on_attack_range_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_attack_range_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
