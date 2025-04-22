extends Entity

## Enemy is a abstract class and should not be instantiated.
class_name Enemy

func set_player_as_target(body: Node2D) -> Player:
	if body.is_in_group("Player"):
		target = body
		return target
	return null


func log_action(text: String) -> void:
	super.log_action("Enemy: %s" % [text])


func _on_detection_area_body_entered(body: Node2D) -> void:
	super._on_detection_area_body_entered(body)
	if set_player_as_target(body):
		state = CombatState.CHASING


func _on_attack_range_body_entered(body: Node2D) -> void:
	super._on_attack_range_body_entered(body)
	if set_player_as_target(body):
		state = CombatState.BATTLING
