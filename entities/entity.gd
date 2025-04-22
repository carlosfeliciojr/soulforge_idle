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
@onready var action_cooldown: Timer = $ActionCooldown

@export var health: float
@export var attack_damage: float
@export var defense_chance: float
@export var move_speed: float
@export var attack_speed: float
@export var detection_radius: float
@export var attack_range: float
@export var cooldown_between_actions: float
@export var wander_time: float = 2.0
@export var wander_radius: float = 100.0
@export var wander_time_min: float = 1.0
@export var wander_time_max: float = 3.0


var state: CombatState = CombatState.WANDERING
var target: Entity
var is_in_an_attack_animation: bool = false
var is_in_a_defend_animation: bool = false
var is_cooldown_active: bool = false
var _wander_target: Vector2
var _wander_timer: float = 0.0

func _ready() -> void:
	var circle = CircleShape2D.new()
	circle.radius = detection_radius
	detection_shape.shape = circle
	detection_shape.debug_color = Color("ab82006b")
	detection_shape.position = collision_shape.position
	
	sprite.animation_finished.connect(_on_animation_finished)

	_pick_new_wander_target()


func _physics_process(delta: float) -> void:
	sprite.z_index = int(global_position.y)
	match state:
		CombatState.IDLE:
			play_animation("idle")
		CombatState.BATTLING:
			start_battle()
		CombatState.CHASING:
			chase(delta)
		CombatState.WANDERING:
			wander(delta)


func log_action(text: String) -> void:
	print(text)


func start_cooldown() -> void:
	var min_time = cooldown_between_actions - (cooldown_between_actions / 3.0)
	var max_time = cooldown_between_actions
	var cooldown_time = randf_range(min_time, max_time)
	action_cooldown.start(cooldown_time)
	is_cooldown_active = true


func play_animation(name: String) -> void:
	if sprite.animation != name:
		sprite.play(name)


func force_play_animation(name: String) -> void:
	sprite.play(name)
	sprite.frame = 0


func flip_sprite(direction_x: float):
	if abs(direction_x) > 0.01:
		sprite.flip_h = direction_x < 0


func _on_animation_finished() -> void:
	match sprite.animation:
		"attack":
			target.receive_attack(attack_damage)
			play_animation("idle")
			is_in_an_attack_animation = false
			start_cooldown()

		"defend":
			is_in_a_defend_animation = false
			play_animation("idle")
			start_cooldown()

		"hurt":
			play_animation("idle")


func start_battle() -> void:
	if target == null or is_instance_valid(target) == false: return
	if is_in_an_attack_animation or \
		is_in_a_defend_animation or \
		is_cooldown_active: return
	if target.has_method("receive_attack"):
		target.defend_attack()
		log_action("Attacking")
		is_in_an_attack_animation = true
		force_play_animation("attack")


func defend_attack() -> void:
	if (randf() > defense_chance): return
	is_in_a_defend_animation = true
	force_play_animation("defend")
	log_action("Defended")


func receive_attack(damage: float) -> void:
	if is_in_a_defend_animation: return
	health -= damage
	force_play_animation("hurt")
	log_action("Being hitted")
	if health <= 0:
		state = CombatState.DEAD


func _stop_and_wait(delta: float):
	velocity = Vector2.ZERO
	play_animation("idle")
	_wander_timer -= delta
	if _wander_timer <= 0:
		_pick_new_wander_target()


func _pick_new_wander_target():
	var angle = randf_range(0, TAU)
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(0, wander_radius)
	_wander_target = position + offset
	_wander_timer = randf_range(wander_time_min, wander_time_max)


func wander(delta: float) -> void:
	if position.distance_to(_wander_target) < 5: 
		_stop_and_wait(delta)
	else:
		var direction: Vector2 = ( _wander_target - position ).normalized()
		velocity = direction * move_speed
		move_and_slide()
		
		if get_slide_collision_count() > 0:
			_pick_new_wander_target()
			_stop_and_wait(delta)
		else:
			play_animation("walk")
			flip_sprite(direction.x)


func chase(delta: float) -> void:
	if target == null or is_instance_valid(target) == false: return
	
	var direction: Vector2 = (target.global_position - global_position).normalized()
	play_animation("run")
	flip_sprite(direction.x)
	velocity = direction * move_speed * 1.50
	move_and_collide(velocity * delta)


func _on_action_cooldown_timeout() -> void:
	is_cooldown_active = false


func _on_detection_area_body_entered(body: Node2D) -> void:
	log_action("entered in detection area")


func _on_detection_area_body_exited(body: Node2D) -> void:
	target = null
	state = CombatState.WANDERING


func _on_attack_range_body_entered(body: Node2D) -> void:
	log_action("entered in attack range area")


func _on_attack_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
