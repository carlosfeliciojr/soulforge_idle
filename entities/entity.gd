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

func _ready() -> void:
	var circle = CircleShape2D.new()
	circle.radius = detection_radius
	detection_shape.shape = circle
	detection_shape.debug_color = Color("ab82006b")
	detection_shape.position = collision_shape.position
	
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	sprite.z_index = int(global_position.y)


func play_animation(name: String):
	if sprite.animation != name:
		sprite.play(name)


func flip_sprite(direction_x: float):
	if abs(direction_x) > 0.01:
		sprite.flip_h = direction_x < 0


func attack_target(target: Entity) -> void:
	if target == null or is_instance_valid(target) == false: return
	if target.has_method("receive_attack"):
		play_animation("attack")
		target.receive_attack(attack_damage)


func _on_animation_finished() -> void:
	if sprite.animation == "attack":
		sprite.play("idle")
		await get_tree().create_timer(0.5).timeout


func receive_attack(damage: float) -> void:
	print("%s foi atacado!" % name)
	# Aqui o NPC pode reagir (animação, reduzir vida, trocar estado etc)
	if randf() > defense_chance:
		health -= damage
		state = CombatState.BEING_HIT
	else:
		print("Defendeu!")
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
