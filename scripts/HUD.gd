extends Node3D

const ShipCore = preload("res://scripts/ShipCore.gd")
const HUD = preload("res://scripts/HUD.gd")
const Player = preload("res://scripts/Player.gd")

func _ready() -> void:
    _build_ship()
    _build_player()
    _build_hud()
    GameState.log_added.emit("Nave da missão acoplada. Sistema principal em vigilância.", "good")

func _build_ship() -> void:
    var ship := ShipCore.new()
    add_child(ship)

func _build_player() -> void:
    var body := CharacterBody3D.new()
    body.name = "Player"
    body.position = Vector3(0.0, 0.2, 5.2)
    body.set_script(Player)
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.38
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    body.add_child(collision)
    add_child(body)

func _build_hud() -> void:
    add_child(HUD.new())
