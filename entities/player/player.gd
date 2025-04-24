extends Entity

## Player is a abstract class and should not be instantiated.
class_name Player

func set_enemy_as_target(body: Node2D) -> Enemy:
	if body.is_in_group("Enemy"):
		targets.append(body as Enemy)
		if is_in_danger(): return
		target = body as Enemy
		return target
	return null

func log_action(text: String) -> void:
	super.log_action("Player: %s" % [text])


func _on_detection_area_body_entered(body: Node2D) -> void:
	super._on_detection_area_body_entered(body)
	if set_enemy_as_target(body):
		state = CombatState.CHASING


func _on_detection_area_body_exited(body: Node2D) -> void:
	super._on_detection_area_body_exited(body)
	if body.is_in_group("Enemy"):
		var enemy_index: int = targets.find(body)
		if enemy_index != -1 and !targets.is_empty():
			targets.remove_at(enemy_index)


func _on_attack_range_body_entered(body: Node2D) -> void:
	super._on_attack_range_body_entered(body)
	state = CombatState.BATTLING
