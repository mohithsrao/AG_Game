# rotator_component.gd
class_name RotatorComponent
extends Node

## Helper component to rotate a target Node2D at a specified angular speed.

@export var target_node: Node2D
@export var rotation_speed: float = 1.0 # Radians per second

func _process(delta: float) -> void:
	var node: Node2D = target_node
	if not is_instance_valid(node):
		node = get_parent() as Node2D
		
	if is_instance_valid(node):
		node.rotate(rotation_speed * delta)
