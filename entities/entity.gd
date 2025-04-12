extends CharacterBody2D

## Entity is a abstract class and should not be instantiated.
##
## Abstract base class for top-down moving entities.
## Handles animations, sound playback, and movement logic.
## Should be extended by characters like the player and monsters.
class_name Entity

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var detection_shape: CollisionShape2D = $DetectionArea/DetectionShape

@export var health: float
@export var attack: float
@export var defense_chance: float
@export var move_speed: float
@export var speed_attack: float
@export var detection_radius: float


func _ready() -> void:
	var circle = CircleShape2D.new()
	circle.radius = detection_radius
	detection_shape.shape = circle
	detection_shape.debug_color = Color("ab82006b")
	detection_shape.position = collision_shape.position


func _physics_process(delta: float) -> void:
	sprite.z_index = int(global_position.y)


func play_animation(name: String):
	if sprite.animation != name:
		sprite.play(name)


func flip_sprite(direction_x: float):
	if abs(direction_x) > 0.01:
		sprite.flip_h = direction_x < 0

func _on_detection_area_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_detection_area_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
