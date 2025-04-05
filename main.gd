extends Node2D

@onready var ground_tile_map_layer: TileMapLayer = $GroundTileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map_size: Vector2i = ground_tile_map_layer.get_used_rect().size
	var map_tile_size: Vector2i = ground_tile_map_layer.tile_set.tile_size
	var enemies: Array[Enemy] = GameManager.create_enemies(
		5,
		map_size, 
		map_tile_size,
		Vector2i(0,0),
	)
	
	for enemy in enemies:
		add_child(enemy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
