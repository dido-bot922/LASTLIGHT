extends Node3D

const ShipCore = preload("res://scripts/ShipCore.gd")
const HUD = preload("res://scripts/HUD.gd")
const MissionDirector = preload("res://scripts/MissionDirector.gd")
const RepairConsole = preload("res://scripts/interactions/RepairConsole.gd")
const ScienceConsole = preload("res://scripts/interactions/ScienceConsole.gd")
const NavigationConsole = preload("res://scripts/interactions/NavigationConsole.gd")
const AirlockController = preload("res://scripts/interactions/AirlockController.gd")

var ship: Node3D
var player: CharacterBody3D

func _ready() -> void:
    _build_world()
    _build_ship()
    _build_player()
    _build_interactive_consoles()
    _build_hud()
    _build_director()
    EventBus.post("AURORA-7 online. Preparação da missão iniciada.", "good")

func _build_world() -> void:
    var environment_node := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("02050a")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("4c7890")
    environment.ambient_light_energy = 0.65
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment_node.environment = environment
    add_child(environment_node)

    var key := DirectionalLight3D.new()
    key.name = "ShipKeyLight"
    key.rotation_degrees = Vector3(-48.0, -30.0, 0.0)
    key.light_color = Color("b6e5f5")
    key.light_energy = 0.42
    key.shadow_enabled = true
    add_child(key)

    var fill := OmniLight3D.new()
    fill.name = "CorridorFill"
    fill.position = Vector3(0.0, 3.4, 0.0)
    fill.light_color = Color("1d6a83")
    fill.light_energy = 2.2
    fill.omni_range = 22.0
    add_child(fill)

func _build_ship() -> void:
    ship = ShipCore.new()
    ship.name = "Aurora7"
    add_child(ship)

func _build_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0.0, 0.2, 4.8)
    player.set_script(preload("res://scripts/Player.gd"))
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.38
    capsule.height = 1.8
    collision.shape = capsule
    collision.position.y = 0.9
    player.add_child(collision)
    add_child(player)

func _build_interactive_consoles() -> void:
    var repair := RepairConsole.new()
    repair.name = "ReactorRepairConsole"
    repair.setup("coolant_leak", "reactor", Vector3(-8.0, 1.4, -2.0))
    add_child(repair)

    var science := ScienceConsole.new()
    science.name = "ScienceAnalysisConsole"
    science.setup("spectral_scan", Vector3(2.8, 1.4, -2.0))
    add_child(science)

    var navigation := NavigationConsole.new()
    navigation.name = "NavigationConsole"
    navigation.setup(Vector3(8.0, 1.4, -2.0))
    add_child(navigation)

    var airlock := AirlockController.new()
    airlock.name = "AirlockController"
    airlock.setup(Vector3(5.2, 1.4, 4.6))
    add_child(airlock)

func _build_hud() -> void:
    add_child(HUD.new())

func _build_director() -> void:
    var director := MissionDirector.new()
    director.name = "MissionDirector"
    add_child(director)
