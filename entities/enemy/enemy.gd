extends Entity

## Enemy is a abstract class and should not be instantiated.
class_name Enemy

@export var wander_time: float = 2.0
@export var wander_radius: float = 100.0
@export var wander_time_min: float = 1.0
@export var wander_time_max: float = 3.0


var _wander_target: Vector2
var _wander_timer: float = 0.0


func _ready():
	super._ready()
	_pick_new_wander_target()


func _physics_process(delta: float):
	super._physics_process(delta)
	if state == CombatState.CHASING:
		chase(delta)
		return
	if state == CombatState.ATTACKING:
		attack_target(target)
		return
	
	wander(delta)


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


func _on_detection_area_area_entered(area: Area2D) -> void:
	super._on_detection_area_area_entered(area)
	var maybe_player = area.get_owner()
	if maybe_player.is_in_group("Player"):
		target = maybe_player
		state = CombatState.CHASING


func _on_detection_area_area_exited(area: Area2D) -> void:
	super._on_detection_area_area_exited(area)
	target = null
	state = CombatState.WANDERING


func _on_attack_range_area_entered(area: Area2D) -> void:
	super._on_attack_range_area_entered(area)
	var maybe_player = area.get_owner()
	if maybe_player.is_in_group("Player"):
		state = CombatState.ATTACKING


func _on_attack_range_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
