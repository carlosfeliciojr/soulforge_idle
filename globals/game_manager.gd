extends Node

const KNIGHT: PackedScene = preload("res://entities/monsters/knight/knight.tscn")

func game_loop() -> void:
	pass

func create_enemies(
	amount: int,
	map_size: Vector2i,
	tile_size: Vector2i,
	player_position: Vector2
) -> Array[Enemy]:
	
	var enemies: Array[Enemy] = []
	var count: int = 0

	while count < amount:
		count += 1

		var tile_x: int = randi_range(0, map_size.x - 1)
		var tile_y: int = randi_range(0, map_size.y - 1)
		var tile_pos: Vector2i = Vector2i(tile_x, tile_y)

		var enemy_position: Vector2 = tile_pos * tile_size + tile_size / 2

		var is_overlapping: bool = enemies.any(func(e): return e.global_position == enemy_position)
		
		if enemy_position != player_position and not is_overlapping:
			var knight_enemy: Knight = KNIGHT.instantiate()
			knight_enemy.global_position = enemy_position
			enemies.append(knight_enemy)
	
	return enemies
