extends Entity

## Enemy is a abstract class and should not be instantiated.
class_name Enemy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var wander_time: float = 2.0
@export var wander_radius: float = 100.0
@export var wander_time_min: float = 1.0
@export var wander_time_max: float = 3.0

var _wander_target: Vector2
var _wander_timer: float = 0.0

func _ready():
	_pick_new_wander_target()


func _physics_process(delta: float):
	wander(delta)


func play_animation(name: String):
	if sprite.animation != name:
		sprite.play(name)


func _flip_sprite(direction_x: float):
	if abs(direction_x) > 0.01:
		sprite.flip_h = direction_x < 0


func _stop_and_wait(delta: float):
	velocity = Vector2.ZERO
	play_animation("idle")
	_wander_timer -= delta
	if _wander_timer <= 0:
		_pick_new_wander_target()


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
			_flip_sprite(direction.x)


func _pick_new_wander_target():
	var angle = randf_range(0, TAU)
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(0, wander_radius)
	_wander_target = position + offset
	_wander_timer = randf_range(wander_time_min, wander_time_max)
