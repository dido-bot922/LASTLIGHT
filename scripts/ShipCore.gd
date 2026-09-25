extends Node3D
class_name ShipCore

const ShipModule = preload("res://scripts/ShipModule.gd")

var modules: Dictionary = {}
var ship_bounds := Vector3(22.0, 4.4, 12.0)
var module_positions := {
    "reactor": Vector3(-8.0, 1.4, -1.0),
    "life_support": Vector3(-2.8, 1.4, -1.0),
    "science": Vector3(2.8, 1.4, -1.0),
    "comms": Vector3(8.0, 1.4, -1.0),
    "cargo": Vector3(-5.2, 1.4, 4.5),
    "airlock": Vector3(5.2, 1.4, 4.5)
}

func _ready() -> void:
    _build_environment()
    _build_hull()
    _build_corridor_details()
    _spawn_modules()
    GameState.log_added.emit("CASCO AURORA-7: todos os módulos internos carregados.", "good")

func _build_environment() -> void:
    var world := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("02050a")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("38556a")
    environment.ambient_light_energy = 0.75
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world.environment = environment
    add_child(world)

    var key := DirectionalLight3D.new()
    key.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
    key.light_color = Color("a8d7ee")
    key.light_energy = 0.55
    key.shadow_enabled = true
    add_child(key)

    var fill := OmniLight3D.new()
    fill.position = Vector3(0, 3.5, 0)
    fill.light_color = Color("235d77")
    fill.light_energy = 2.0
    fill.omni_range = 18.0
    add_child(fill)

func _build_hull() -> void:
    _make_box("deck", Vector3(0, -0.18, 0), Vector3(22, 0.35, 12), Color("101d29"))
    _make_box("ceiling", Vector3(0, 4.4, 0), Vector3(22, 0.25, 12), Color("0b141e"))
    _make_box("port_hull", Vector3(-11, 2, 0), Vector3(0.3, 4.4, 12), Color("111f2c"))
    _make_box("starboard_hull", Vector3(11, 2, 0), Vector3(0.3, 4.4, 12), Color("111f2c"))
    _make_box("forward_hull", Vector3(0, 2, -6), Vector3(22, 4.4, 0.3), Color("101c28"))
    _make_box("aft_hull", Vector3(0, 2, 6), Vector3(22, 4.4, 0.3), Color("101c28"))

    for x in [-8.0, -2.8, 2.8, 8.0]:
        _make_box("light_%s" % str(x), Vector3(x, 4.22, 0), Vector3(2.0, 0.04, 0.16), Color("64dcff"), true)

func _build_corridor_details() -> void:
    for x in [-7.2, -3.6, 0.0, 3.6, 7.2]:
        _make_box("floor_strip_%s" % str(x), Vector3(x, 0.015, 0), Vector3(0.06, 0.025, 11.0), Color("2c9db5"), true)
    for z in [-4.8, -2.4, 0.0, 2.4, 4.8]:
        _make_box("bulkhead_%s" % str(z), Vector3(0, 2.1, z), Vector3(0.08, 3.8, 0.05), Color("203a4b"))

func _spawn_modules() -> void:
    for id in module_positions:
        var module := ShipModule.new()
        module.setup(id, module_positions[id])
        add_child(module)
        modules[id] = module

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
    material.metallic = 0.65
    material.roughness = 0.32
    if emissive:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 2.5
    mesh.material_override = material
    body.add_child(mesh)
    add_child(body)
    return body
