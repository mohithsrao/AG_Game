# minion_data.gd
class_name MinionData
extends Resource

## Configuration resource specifying stats and default routing for network minions.

@export var minion_name: String = "Minion"
@export var base_speed: float = 120.0
@export var base_health: float = 20.0
@export var ddos_value: float = 1.0
@export var routing_strategy: RoutingStrategy

