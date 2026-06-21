# e:/Godot/Projects/AntiGravityWorkspace/AG_Game/Source/Entities/Player/player.gd
class_name Player
extends CharacterBody2D

## Player Entity governing movement and double-jump composition.

signal land_state_entered

@export var speed: float = 300.0
@export var gravity: float = 980.0

@onready var jump_component: JumpComponent = $JumpComponent
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var state: String = "OnFloor"

func _ready() -> void:
	if not is_instance_valid(jump_component):
		push_error("Player requires a child JumpComponent node!")
		return
	
	# Connect double jump signal to handle feedback effects
	jump_component.double_jumped.connect(_on_double_jumped)

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		if state != "InAir":
			state = "InAir"
	else:
		if state != "OnFloor":
			state = "OnFloor"
			jump_component.reset_charges()
			land_state_entered.emit()

	# Handle horizontal movement
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * speed
		if sprite:
			sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

	# Handle jumping
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = jump_component.get_jump_velocity()
		elif jump_component.can_double_jump():
			velocity.y = jump_component.execute_double_jump()

	move_and_slide()

func _on_double_jumped() -> void:
	# Visual/Audio juice triggers
	if sfx_player:
		sfx_player.play()
	# Trigger particle system if present
	_spawn_double_jump_vfx()

func _spawn_double_jump_vfx() -> void:
	# Simulated particles spawn
	pass
