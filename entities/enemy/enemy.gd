extends Entity

## Enemy is a abstract class and should not be instantiated.
class_name Enemy

func set_player_as_target(body: Node2D) -> Player:
	if body.is_in_group("Player"):
		targets.append(body as Player)
		if is_in_danger(): return
		target = body as Player
		return target
	return null


func log_action(text: String) -> void:
	super.log_action("Enemy: %s" % [text])


func _on_detection_area_body_exited(body: Node2D) -> void:
	super._on_detection_area_body_exited(body)
	if body.is_in_group("Player"):
		var player_index: int = targets.find(body)
		if player_index != -1 and !targets.is_empty():
			targets.remove_at(player_index)

func _on_detection_area_body_entered(body: Node2D) -> void:
	super._on_detection_area_body_entered(body)
	if set_player_as_target(body):
		state = CombatState.CHASING


func _on_attack_range_body_entered(body: Node2D) -> void:
	super._on_attack_range_body_entered(body)
	state = CombatState.BATTLING
