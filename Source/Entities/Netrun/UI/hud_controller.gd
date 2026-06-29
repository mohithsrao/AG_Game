# hud_controller.gd
extends Control

## Controls HUD presentation for the Neon Netrun module.
## Displays spawner overclock heat levels, Boss buffer overflow gauges, and active syscall cooldowns.

@export var boss_path: NodePath
@export var spawner_paths: Array[NodePath] = []

@onready var boss_core: Node2D = get_node_or_null(boss_path) as Node2D
@onready var spawners: Array[Node2D] = []

# UI Node References
@onready var boss_health_bar: ProgressBar = $BossHealthBar
@onready var ddos_buffer_bar: ProgressBar = $DDoSBufferBar
@onready var stun_overlay: Panel = $StunOverlay
@onready var spawner_heat_container: VBoxContainer = $SpawnerHeatContainer

func _ready() -> void:
	# Resolve spawner paths
	for path in spawner_paths:
		var spawner = get_node_or_null(path) as Node2D
		if is_instance_valid(spawner):
			spawners.append(spawner)
			
	# Connect global events
	NetrunEvents.boss_stunned.connect(_on_boss_stunned)
	NetrunEvents.boss_recovered.connect(_on_boss_recovered)
	
	if not is_instance_valid(boss_core):
		var boss = get_tree().get_first_node_in_group("boss") as Node2D
		if is_instance_valid(boss):
			boss_core = boss
			
	_setup_hud()

func _process(delta: float) -> void:
	_update_hud()

func _setup_hud() -> void:
	if is_instance_valid(boss_core):
		boss_health_bar.max_value = boss_core.max_health
		boss_health_bar.value = boss_core.health
		
		ddos_buffer_bar.max_value = boss_core.ddos_stun_threshold
		ddos_buffer_bar.value = boss_core.ddos_hit_count
		
	if is_instance_valid(stun_overlay):
		stun_overlay.visible = false
		
	# Setup individual progress bars for spawner heat
	if is_instance_valid(spawner_heat_container):
		for child in spawner_heat_container.get_children():
			child.queue_free()
			
		for i in range(spawners.size()):
			var spawner = spawners[i]
			var bar = ProgressBar.new()
			bar.name = "Spawner_" + str(i) + "_Heat"
			bar.max_value = spawner.max_heat
			bar.value = spawner.heat
			spawner_heat_container.add_child(bar)

func _update_hud() -> void:
	if is_instance_valid(boss_core):
		boss_health_bar.value = boss_core.health
		ddos_buffer_bar.value = boss_core.ddos_hit_count
		
	if is_instance_valid(spawner_heat_container):
		var bars = spawner_heat_container.get_children()
		for i in range(min(spawners.size(), bars.size())):
			var spawner = spawners[i]
			var bar = bars[i] as ProgressBar
			if is_instance_valid(spawner) and is_instance_valid(bar):
				bar.value = spawner.heat
				# Indicate reboot state
				if spawner.is_rebooting:
					bar.modulate = Color.RED
				else:
					bar.modulate = Color.CYAN if spawner.is_focused else Color.WHITE

func _on_boss_stunned() -> void:
	if is_instance_valid(stun_overlay):
		stun_overlay.visible = true
	# Trigger Lowpass filter or visual glitch shaders here

func _on_boss_recovered() -> void:
	if is_instance_valid(stun_overlay):
		stun_overlay.visible = false
