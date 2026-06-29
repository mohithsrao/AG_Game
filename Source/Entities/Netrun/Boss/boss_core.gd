# boss_core.gd
extends CharacterBody2D

## Handles Boss Core AI states, movement, anti-virus sweeps, and buffer overflow stuns.

const HealthComponent = preload("res://Entities/Netrun/Shared/Components/health_component.gd")
const RotatorComponent = preload("res://Entities/Netrun/Shared/Components/rotator_component.gd")
const Minion = preload("res://Entities/Netrun/Minions/minion.gd")

enum State { ACTIVE, BUFFER_OVERFLOW, SYSTEM_PURGE, DESTROYED }

@export var max_health: float = 1000.0:
	set(val):
		max_health = val
		if is_instance_valid(health_component):
			health_component.max_health = val

var health: float = 1000.0:
	set(val):
		health = val
		if is_instance_valid(health_component) and health_component.current_health != val:
			health_component.current_health = val

@export var ddos_stun_threshold: int = 10
@export var ddos_hit_window: float = 2.0
@export var stun_duration: float = 3.0

var current_state: State = State.ACTIVE
var ddos_hit_count: int = 0
var hit_window_timer: float = 0.0
var stun_timer: float = 0.0

var health_component = HealthComponent.new()
var rotator_component = RotatorComponent.new()
var purge_area: Area2D = Area2D.new()

@onready var animation_player = get_node_or_null("AnimationPlayer")

func _init() -> void:
	# Configure health component defaults
	health_component.max_health = max_health
	health_component.current_health = max_health
	health = max_health
	
	health_component.died.connect(destroy_core)
	health_component.health_changed.connect(func(curr: float, _max_val: float) -> void:
		health = curr
	)
	
	rotator_component.rotation_speed = 1.0

func _ready() -> void:
	add_to_group("boss")
	
	if health_component.get_parent() == null:
		add_child(health_component)
	
	if rotator_component.get_parent() == null:
		add_child(rotator_component)
	
	if purge_area.get_parent() == null:
		add_child(purge_area)
	var collision: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 400.0
	collision.shape = circle
	purge_area.add_child(collision)
	collision.disabled = true
	
	if is_instance_valid(animation_player):
		animation_player.play("Boss_Idle")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(health_component) and health_component.get_parent() == null:
			health_component.free()
		if is_instance_valid(rotator_component) and rotator_component.get_parent() == null:
			rotator_component.free()
		if is_instance_valid(purge_area) and purge_area.get_parent() == null:
			purge_area.free()

func _process(delta: float) -> void:
	if current_state == State.ACTIVE:
		if hit_window_timer > 0.0:
			hit_window_timer -= delta
			if hit_window_timer <= 0.0:
				ddos_hit_count = 0
	elif current_state == State.BUFFER_OVERFLOW:
		stun_timer -= delta
		if stun_timer <= 0.0:
			recover_from_stun()

func register_ddos_hit() -> void:
	if current_state != State.ACTIVE:
		return
		
	ddos_hit_count += 1
	hit_window_timer = ddos_hit_window
	
	if ddos_hit_count >= ddos_stun_threshold:
		trigger_buffer_overflow()

func apply_ddos_hit(amount: int = 1) -> void:
	for i in range(amount):
		register_ddos_hit()

func trigger_buffer_overflow() -> void:
	current_state = State.BUFFER_OVERFLOW
	stun_timer = stun_duration
	ddos_hit_count = 0
	NetrunEvents.boss_stunned.emit()
	
	if is_instance_valid(animation_player):
		animation_player.play("Boss_Stun")

func recover_from_stun() -> void:
	current_state = State.SYSTEM_PURGE
	trigger_system_purge()
	current_state = State.ACTIVE
	NetrunEvents.boss_recovered.emit()
	
	if is_instance_valid(animation_player):
		animation_player.play("Boss_Idle")

func trigger_system_purge() -> void:
	var collision: CollisionShape2D = purge_area.get_child(0) as CollisionShape2D
	if collision:
		collision.disabled = false
		
	var manager = get_tree().get_first_node_in_group("minion_managers")
	if manager and manager.has_method("registered_minions"):
		var minions_copy = manager.registered_minions.duplicate()
		for minion in minions_copy:
			if is_instance_valid(minion) and global_position.distance_to(minion.global_position) <= 400.0:
				minion.take_damage(999.0)
				
	if collision:
		collision.disabled = true

func take_damage(amount: float) -> void:
	var multiplier: float = 2.0 if current_state == State.BUFFER_OVERFLOW else 1.0
	health_component.take_damage(amount * multiplier)
	
	if is_instance_valid(animation_player):
		animation_player.play("Boss_Hit")
		if current_state == State.BUFFER_OVERFLOW:
			animation_player.queue("Boss_Stun")
		else:
			animation_player.queue("Boss_Idle")

func destroy_core() -> void:
	current_state = State.DESTROYED
	queue_free()
