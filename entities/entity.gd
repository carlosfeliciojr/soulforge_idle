extends CharacterBody2D

## Entity is a abstract class and should not be instantiated.
##
## Abstract base class for top-down moving entities.
## Handles animations, sound playback, and movement logic.
## Should be extended by characters like the player and monsters.
class_name Entity

@export var health: float
@export var attack: float
@export var defense_chance: float
@export var move_speed: float
@export var speed_attack: float
@export var detection_radius: float
