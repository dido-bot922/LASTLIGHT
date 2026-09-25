extends Node3D

const ShipCore = preload("res://scripts/ShipCore.gd")
const HUD = preload("res://scripts/HUD.gd")
const MissionDirector = preload("res://scripts/MissionDirector.gd")
const RepairConsole = preload("res://scripts/interactions/RepairConsole.gd")
const ScienceConsole = preload("res://scripts/interactions/ScienceConsole.gd")
const NavigationConsole = preload("res://scripts/interactions/NavigationConsole.gd")
const AirlockController = preload("res://scripts/interactions/AirlockController.gd")

func _ready() -> void:
    _build_ship()
    _build_player()
    _build_interactive_consoles()
    _build_hud()
    _build_director()
    GameState.log_added.emit("AURORA-7 online. Preparação da missão iniciada.", "good")

func _build_ship() -> void:
    add_child(ShipCore.new())

func _build_player() -> void:
    var player := CharacterBody3D.new()
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
    repair.setup("coolant_leak", "reactor", Vector3(-8.0, 1.4, -2.0))
    add_child(repair)
    var science := ScienceConsole.new()
    science.setup("spectral_scan", Vector3(2.8, 1.4, -2.0))
    add_child(science)
    var navigation := NavigationConsole.new()
    navigation.setup(Vector3(8.0, 1.4, -2.0))
    add_child(navigation)
    var airlock := AirlockController.new()
    airlock.setup(Vector3(5.2, 1.4, 4.6))
    add_child(airlock)

func _build_hud() -> void:
    add_child(HUD.new())

func _build_director() -> void:
    add_child(MissionDirector.new())
