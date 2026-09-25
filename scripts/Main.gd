extends Node3D

const ShipCore = preload("res://scripts/ShipCore.gd")
const HUD = preload("res://scripts/HUD.gd")
const MissionDirector = preload("res://scripts/MissionDirector.gd")

func _ready() -> void:
    _build_ship()
    _build_player()
    _build_hud()
    _build_director()
    GameState.log_added.emit("AURORA-7 pronta. A missão começa dentro da nave.", "good")

func _build_ship() -> void:
    add_child(ShipCore.new())

func _build_player() -> void:
    var player := CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0.0, 0.05, 5.0)
    player.set_script(preload("res://scripts/Player.gd"))
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.38
    capsule.height = 1.8
    collision.shape = capsule
    collision.position.y = 0.9
    player.add_child(collision)
    add_child(player)

func _build_hud() -> void:
    add_child(HUD.new())

func _build_director() -> void:
    add_child(MissionDirector.new())
