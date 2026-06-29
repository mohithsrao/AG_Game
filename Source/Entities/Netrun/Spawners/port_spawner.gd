# port_spawner.gd
extends Node2D

## Handles automated minion spawning, bandwidth overclocking, heat buildup, and reboot states.

const MinionData = preload("res://Entities/Netrun/Shared/Resources/minion_data.gd")
const HealthComponent = preload("res://Entities/Netrun/Shared/Components/health_component.gd")
const Minion = preload("res://Entities/Netrun/Minions/minion.gd")

enum PortType { HTTP, HTTPS, SSH }

@export var port_type: PortType = PortType.HTTP
@export var minion_scene: PackedScene
@export var base_spawn_time: float = 2.0
@export var is_focused: bool = false
@export var focus_spawn_multiplier: float = 2.0
@export var focus_duration: float = 5.0

@export var http_minion_data: Resource # MinionData resource
@export var https_minion_data: Resource # MinionData resource
@export var ssh_minion_data: Resource # MinionData resource

var heat: float = 0.0
var max_heat: float = 100.0
var is_rebooting: bool = false

var spawn_timer: Timer = Timer.new()
var focus_timer: Timer = Timer.new()
var reboot_timer: Timer = Timer.new()
var health_component: HealthComponent = HealthComponent.new()

var reboot_tween: Tween

@onready var sprite_2d = get_node_or_null("Sprite2D")

func _ready() -> void:
	# Add timers as children
	if spawn_timer.get_parent() == null:
		add_child(spawn_timer)
	spawn_timer.wait_time = base_spawn_time
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timeout)
	
	if focus_timer.get_parent() == null:
		add_child(focus_timer)
	focus_timer.one_shot = true
	focus_timer.timeout.connect(_on_focus_timeout)
	
	if reboot_timer.get_parent() == null:
		add_child(reboot_timer)
	reboot_timer.one_shot = true
	reboot_timer.timeout.connect(_on_reboot_timeout)
	
	if health_component.get_parent() == null:
		add_child(health_component)
	health_component.max_health = 150.0
	health_component.died.connect(_on_destroyed)
	
	spawn_timer.start()
	_update_spawner_sprite()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if reboot_tween:
			reboot_tween.kill()
		if is_instance_valid(spawn_timer) and spawn_timer.get_parent() == null:
			spawn_timer.free()
		if is_instance_valid(focus_timer) and focus_timer.get_parent() == null:
			focus_timer.free()
		if is_instance_valid(reboot_timer) and reboot_timer.get_parent() == null:
			reboot_timer.free()
		if is_instance_valid(health_component) and health_component.get_parent() == null:
			health_component.free()

func _process(delta: float) -> void:
	if is_rebooting:
		return
		
	# Manage Heat
	if is_focused:
		heat = min(max_heat, heat + 20.0 * delta)
		if heat >= max_heat:
			trigger_reboot()
	else:
		heat = max(0.0, heat - 15.0 * delta)

func set_focus(val: bool) -> void:
	if is_rebooting:
		return
		
	is_focused = val
	var current_multiplier: float = focus_spawn_multiplier if val else 1.0
	spawn_timer.wait_time = base_spawn_time / current_multiplier
	
	# Restart the timer to apply wait_time change immediately
	spawn_timer.start()
	
	_update_spawner_sprite()
	
	if val:
		focus_timer.start(focus_duration)
		NetrunEvents.gateway_focus_alert.emit(global_position)
	else:
		focus_timer.stop()

func spawn_minion() -> void:
	if not minion_scene or is_rebooting:
		return
		
	var minion_instance: Node = minion_scene.instantiate()
	if minion_instance.has_method("take_damage"):
		minion_instance.minion_data = null
		
		# Set properties based on Port type
		match port_type:
			PortType.HTTP:
				minion_instance.minion_data = http_minion_data
			PortType.HTTPS:
				minion_instance.minion_data = https_minion_data
				if is_instance_valid(minion_instance.shield_component):
					minion_instance.shield_component.is_shielded = true
			PortType.SSH:
				minion_instance.minion_data = ssh_minion_data
				if is_instance_valid(minion_instance.stealth_component):
					minion_instance.stealth_component.apply_stealth(3.0)
		
		minion_instance.global_position = global_position
		get_parent().add_child(minion_instance)

func trigger_reboot() -> void:
	is_rebooting = true
	is_focused = false
	spawn_timer.stop()
	focus_timer.stop()
	reboot_timer.start(10.0) # 10s reboot duration
	_update_spawner_sprite()
	
	# Start blinking red effect
	if is_instance_valid(sprite_2d):
		if reboot_tween:
			reboot_tween.kill()
		reboot_tween = create_tween().set_loops()
		reboot_tween.tween_property(sprite_2d, "modulate", Color.RED, 0.25)
		reboot_tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.25)

func _update_spawner_sprite() -> void:
	if not is_instance_valid(sprite_2d):
		return
		
	var region := Rect2()
	match port_type:
		PortType.HTTP:
			if is_rebooting:
				region = Rect2(10, 45, 80, 80)
			elif is_focused:
				region = Rect2(95, 215, 80, 60)
			else:
				region = Rect2(95, 45, 80, 80)
		PortType.HTTPS:
			if is_rebooting:
				region = Rect2(180, 130, 80, 80)
			elif is_focused:
				region = Rect2(180, 215, 80, 60)
			else:
				region = Rect2(180, 45, 80, 80)
		PortType.SSH:
			if is_rebooting:
				region = Rect2(265, 45, 80, 80)
			elif is_focused:
				region = Rect2(300, 215, 80, 60)
			else:
				region = Rect2(265, 130, 80, 80)
				
	sprite_2d.region_rect = region

func _on_spawn_timeout() -> void:
	spawn_minion()

func _on_focus_timeout() -> void:
	set_focus(false)

func _on_reboot_timeout() -> void:
	is_rebooting = false
	heat = 0.0
	health_component.current_health = health_component.max_health / 2.0
	spawn_timer.wait_time = base_spawn_time
	spawn_timer.start()
	_update_spawner_sprite()
	
	# Stop blinking red effect
	if reboot_tween:
		reboot_tween.kill()
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = Color.WHITE

func _on_destroyed() -> void:
	trigger_reboot()
