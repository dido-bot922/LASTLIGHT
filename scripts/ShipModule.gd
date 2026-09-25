extends Node3D
class_name ShipCore

var modules: Dictionary = {}
var module_positions := {
    "reactor": Vector3(-8.0, 1.4, -1.0),
    "life_support": Vector3(-2.8, 1.4, -1.0),
    "science": Vector3(2.8, 1.4, -1.0),
    "comms": Vector3(8.0, 1.4, -1.0),
    "cargo": Vector3(-5.2, 1.4, 4.8),
    "airlock": Vector3(5.2, 1.4, 4.8),
    "corridor": Vector3(0.0, 1.4, 0.0),
}

func _ready() -> void:
    _build_ship_shell()
    _spawn_modules()
    GameState.log_added.emit("Nave operacional. Módulos carregados e prontos para inspeção.", "good")

func _build_ship_shell() -> void:
    var floor := _box("ship_floor", Vector3(0, -0.2, 0), Vector3(22, 0.3, 12), Color("0f1d29"))
    add_child(floor)

    var ceiling := _box("ship_ceiling", Vector3(0, 4.4, 0), Vector3(22, 0.3, 12), Color("14212a"))
    add_child(ceiling)

    var left := _box("left_wall", Vector3(-11, 2.0, 0), Vector3(0.25, 4.2, 12), Color("101d2c"))
    var right := _box("right_wall", Vector3(11, 2.0, 0), Vector3(0.25, 4.2, 12), Color("101d2c"))
    var front := _box("front_wall", Vector3(0, 2.0, -6.0), Vector3(22, 4.2, 0.25), Color("111d2a"))
    var back := _box("back_wall", Vector3(0, 2.0, 6.0), Vector3(22, 4.2, 0.25), Color("111d2a"))
    add_child(left)
    add_child(right)
    add_child(front)
    add_child(back)

    for x in [-8.0, -2.8, 2.8, 8.0]:
        var lamp := _box("lamp_%s" % x, Vector3(x, 4.2, 0), Vector3(2.2, 0.06, 0.14), Color("73d9ff"), true)
        add_child(lamp)

func _spawn_modules() -> void:
    for module_name in module_positions.keys():
        var module := preload("res://scripts/ShipModule.gd").new()
        module.setup(module_name, module_positions[module_name])
        add_child(module)
        modules[module_name] = module

func _box(name_: String, pos: Vector3, size: Vector3, color: Color, emissive := false) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name = name_
    body.position = pos
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)

    var mesh := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size = size
    mesh.mesh = cube

    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = 0.5
    material.roughness = 0.42
    if emissive:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 2.5
    mesh.material_override = material
    body.add_child(mesh)
    return body
