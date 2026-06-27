# health_component.gd
class_name HealthComponent
extends Node

## Manages health values, damage calculation, healing, and death signals for entities.

signal health_changed(current: float, max_value: float)
signal died

@export var max_health: float = 100.0

@onready var current_health: float = max_health

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0.0:
		return
	
	current_health = max(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	if current_health <= 0.0:
		return
	
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
