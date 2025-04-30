extends CharacterBody2D

## Entity is a abstract class and should not be instantiated.
##
## Abstract base class for top-down moving entities.
## Handles animations, sound playback, and movement logic.
## Should be extended by characters like the player and monsters.
class_name Entity

const CombatState = preload("res://globals/enums/combat_states.gd").CombatState

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var detection_shape: CollisionShape2D = $DetectionArea/DetectionShape
@onready var attack_shape: CollisionShape2D = $AttackRange/AttackShape
@onready var action_cooldown: Timer = $ActionCooldown


@export var health: float
@export var attack_damage: float
@export var defense_chance: float
@export var flee_chance: float
@export var move_speed: float
@export var attack_speed: float
@export var detection_radius: float
@export var attack_range_radius: float
@export var cooldown_between_actions: float
@export var wander_time: float = 2.0
@export var wander_radius: float = 100.0
@export var wander_time_min: float = 1.0
@export var wander_time_max: float = 3.0


var state: CombatState = CombatState.WANDERING
var targets_in_detection_area: Array[Entity]
var targets_in_attack_area: Array[Entity]
var target: Entity
var is_in_a_defend_animation: bool = false
var is_in_a_flee_animation: bool = false
var is_cooldown_active: bool = false
var _wander_target: Vector2
var _wander_timer: float = 0.0

func _ready() -> void:
	set_detection_radius()
	
	sprite.animation_finished.connect(_on_animation_finished)
	

	_pick_new_wander_target()


func set_detection_radius() -> void:
	var circle = CircleShape2D.new()
	circle.radius = detection_radius
	detection_shape.shape = circle
	detection_shape.position = collision_shape.position


func set_attack_radius() -> void:
	var circle = CircleShape2D.new()
	circle.radius = attack_range_radius
	attack_shape.shape = circle
	attack_shape.position = collision_shape.position


func _physics_process(delta: float) -> void:
	sprite.z_index = int(global_position.y)
	if is_dead(): return
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
	print("%s: %s" % [name, text])


func invalid_action_against_target() -> bool:
	return is_dead() or target == null or is_instance_valid(target) == false or target.is_dead()


func is_dead() -> bool:
	return state == CombatState.DEAD


func is_in_danger() -> bool:
	return target != null


func start_cooldown() -> void:
	var min_time = cooldown_between_actions - (cooldown_between_actions / 3.0)
	var max_time = cooldown_between_actions
	var cooldown_time = randf_range(min_time, max_time)
	action_cooldown.start(cooldown_time)
	is_cooldown_active = true


func play_animation(animation_name: String) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)


func force_play_animation(animation_name: String) -> void:
	if animation_name != "defend": is_in_a_defend_animation = false
	sprite.play(animation_name)
	sprite.frame = 0


func flip_sprite(destination: Vector2) -> void:
	var direction: Vector2 = (destination - global_position).normalized()
	if abs(direction.x) > 0.01:
		sprite.flip_h = direction.x < 0


func add_target(new_target: Entity, targets: Array[Entity]) -> void:
	var new_target_index: int = targets.find(new_target)
	if new_target_index > -1: return
	targets.append(new_target)
	get_next_target()


func remove_target_from_targets(
	target_to_remove: Entity,
	targets: Array[Entity],
	) -> void:
	var player_index: int = targets.find(target_to_remove)
	if player_index != -1 and !targets.is_empty():
		targets.remove_at(player_index)


func get_next_target() -> void:
	if is_dead(): return
	if (targets_in_attack_area.is_empty() and targets_in_detection_area.is_empty()):
		target = null
		state = CombatState.WANDERING
		return

	if !targets_in_attack_area.is_empty():
		target = get_target_from_targets(targets_in_attack_area, nearest_target_condition)
		if target: state = CombatState.BATTLING
		return
		
	if !targets_in_detection_area.is_empty():
		target = get_target_from_targets(targets_in_detection_area, nearest_target_condition)
		if target: state = CombatState.CHASING
		return


func get_target_from_targets(
	targets: Array[Entity],
	condition: Callable,
	) -> Entity:
	if targets.is_empty(): return null
	var target_index: int = targets.find_custom(condition)
	if target_index > -1:
		return targets[target_index]
	else:
		return null


func nearest_target_condition(next_target: Entity) -> bool:
	var self_distance: float = next_target.global_position.distance_to(global_position)
	for _target in targets_in_detection_area:
		var distance: float = _target.global_position.distance_to(global_position)
		if distance < self_distance:
			return false
	return true


func _on_animation_finished() -> void:
	match sprite.animation:
		"attack":
			if !target.is_in_a_defend_animation:
				target.flee_attack(self)
				target.receive_attack(attack_damage)
			play_animation("idle")
		"defend":
			is_in_a_defend_animation = false
			play_animation("idle")
		"hurt":
			if state == CombatState.DEAD: play_animation("death")
			else: play_animation("idle")


func start_battle() -> void:
	if invalid_action_against_target(): return
	if is_cooldown_active: return
	
	start_cooldown()
	if target.has_method("receive_attack"):
		if target.is_dead(): return
		target.defend_attack()
		flip_sprite(target.global_position)
		force_play_animation("attack")


func defend_attack() -> void:
	if is_dead() or is_in_a_flee_animation or is_in_a_defend_animation: return
	if (randf() > defense_chance): return
	is_in_a_defend_animation = true
	force_play_animation("defend")


func flee_attack(from_entity: Entity) -> void:
	if is_dead() or is_in_a_flee_animation or is_in_a_defend_animation: return
	if (randf() > flee_chance): return
	is_in_a_flee_animation = true
	flip_sprite(from_entity.global_position)
	await _flee_animation(from_entity.global_position)
	is_in_a_flee_animation = false


func _flee_animation(from_entity_position: Vector2) -> void:
	var direction: Vector2 = (from_entity_position - global_position).normalized()
	var tween: Tween = create_tween()
	if abs(direction.x) > 0.01:
		tween.tween_property($AnimatedSprite2D, "offset", Vector2(-5, 0), 0.05)
	else:
		tween.tween_property($AnimatedSprite2D, "offset", Vector2(5, 0), 0.05)
	tween.tween_property($AnimatedSprite2D, "offset", Vector2(0, 0), 0.1)
	await tween.finished


func receive_attack(damage: float) -> void:
	if is_dead(): return
	if is_in_a_defend_animation or is_in_a_flee_animation: return
	health -= damage
	force_play_animation("hurt")
	if health <= 0:
		dead()


func dead() -> void:
	if is_dead(): return
	state = CombatState.DEAD
	target = null
	velocity = Vector2.ZERO
	collision_shape.disabled = true
	if detection_shape:
		detection_shape.disabled = true


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
	if is_dead(): return
	if position.distance_to(_wander_target) < 5:
		_stop_and_wait(delta)
	else:
		var direction: Vector2 = (_wander_target - position).normalized()
		velocity = direction * move_speed
		move_and_slide()
		
		if get_slide_collision_count() > 0:
			_pick_new_wander_target()
			_stop_and_wait(delta)
		else:
			play_animation("walk")
			flip_sprite(_wander_target)


func chase(delta: float) -> void:
	if invalid_action_against_target(): return
	var direction: Vector2 = (target.global_position - global_position).normalized()
	play_animation("run")
	flip_sprite(target.global_position)
	velocity = direction * move_speed * 1.50
	move_and_collide(velocity * delta)


func _on_action_cooldown_timeout() -> void:
	is_cooldown_active = false


func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_dead(): return


func _on_detection_area_body_exited(body: Node2D) -> void:
	if is_dead(): return


func _on_attack_range_body_entered(body: Node2D) -> void:
	if is_dead(): return


func _on_attack_range_body_exited(body: Node2D) -> void:
	if is_dead(): return
