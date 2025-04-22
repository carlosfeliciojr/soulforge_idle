extends Entity

## Player is a abstract class and should not be instantiated.
class_name Player

func set_enemy_as_target(body: Node2D) -> Player:
	if body.is_in_group("Enemy"):
		target = body
		return target
	return null

func log_action(text: String) -> void:
	super.log_action("Player: %s" % [text])


func _on_detection_area_body_entered(body: Node2D) -> void:
	super._on_detection_area_body_entered(body)
	if set_enemy_as_target(body):
		state = CombatState.CHASING


func _on_attack_range_body_entered(body: Node2D) -> void:
	super._on_attack_range_body_entered(body)
	if set_enemy_as_target(body):
		state = CombatState.BATTLING
