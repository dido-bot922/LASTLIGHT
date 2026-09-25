extends Node3D
class_name ShipCore

const ShipModule = preload("res://scripts/ShipModule.gd")

var module_positions := {
    "reactor": Vector3(-8.0, 1.4, -1.0),
    "life_support": Vector3(-2.8, 1.4, -1.0),
    "science": Vector3(2.8, 1.4, -1.0),
    "comms": Vector3(8.0, 1.4, -1.0),
    "cargo": Vector3(-5.2, 1.4, 4.8),
    "airlock": Vector3(5.2, 1.4, 4.8)
}

func _ready() -> void:
    _build_shell()
    _build_corridor()
    _spawn_modules()
    GameState.log_added.emit("CASCO AURORA-7 pronto. Módulos internos carregados.", "good")

func _build_shell() -> void:
    _make_box("deck", Vector3(0, -0.18, 0), Vector3(22, 0.35, 12), Color("101d29"))
    _make_box("ceiling", Vector3(0, 4.4, 0), Vector3(22, 0.25, 12), Color("0c141d"))
    _make_box("left_wall", Vector3(-11, 2.0, 0), Vector3(0.25, 4.3, 12), Color("111d2d"))
    _make_box("right_wall", Vector3(11, 2.0, 0), Vector3(0.25, 4.3, 12), Color("111d2d"))
    _make_box("front_wall", Vector3(0, 2.0, -6), Vector3(22, 4.3, 0.25), Color("0e1921"))
    _make_box("back_wall", Vector3(0, 2.0, 6), Vector3(22, 4.3, 0.25), Color("0e1921"))

    for x in [-8.0, -2.8, 2.8, 8.0]:
        _make_box("light_%s" % str(x), Vector3(x, 4.2, 0), Vector3(2.0, 0.05, 0.18), Color("73dfff"), true)

func _build_corridor() -> void:
    for x in [-7.2, -3.6, 0.0, 3.6, 7.2]:
        _make_box("strip_%s" % str(x), Vector3(x, 0.02, 0), Vector3(0.08, 0.04, 11.2), Color("2d9bb5"), true)
    for z in [-4.6, -2.3, 0.0, 2.3, 4.6]:
        _make_box("bulkhead_%s" % str(z), Vector3(0, 2.1, z), Vector3(0.08, 3.8, 0.06), Color("21415a"))

func _spawn_modules() -> void:
    for id in module_positions:
        var module := ShipModule.new()
        module.setup(id, module_positions[id])
        add_child(module)

func _make_box(node_name: String, pos: Vector3, size: Vector3, color: Color, emissive := false) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name = node_name
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
    material.metallic = 0.55
    material.roughness = 0.32
    if emissive:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 2.25
    mesh.material_override = material
    body.add_child(mesh)
    add_child(body)
    return body
