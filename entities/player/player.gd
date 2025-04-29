extends Entity

## Player is a abstract class and should not be instantiated.
class_name Player


func _on_detection_area_body_entered(body: Node2D) -> void:
	super._on_detection_area_body_entered(body)
	if body.is_in_group("Enemy"):
		add_target(body as Enemy, targets_in_detection_area)


func _on_detection_area_body_exited(body: Node2D) -> void:
	super._on_detection_area_body_exited(body)
	if body.is_in_group("Enemy"):
		remove_target_from_targets(body as Enemy, targets_in_detection_area)
		remove_target_from_targets(body as Enemy, targets_in_attack_area)
		get_next_target()


func _on_attack_range_body_entered(body: Node2D) -> void:
	super._on_attack_range_body_entered(body)
	if body.is_in_group("Enemy"):
		add_target(body as Enemy, targets_in_attack_area)


func _on_attack_range_body_exited(body: Node2D) -> void:
	super._on_attack_range_body_exited(body)
	if body.is_in_group("Enemy"):
		remove_target_from_targets(body as Enemy, targets_in_attack_area)
		get_next_target()
