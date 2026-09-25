extends Node3D

const ShipPanel = preload("res://scripts/ShipPanel.gd")
const ScienceTerminal = preload("res://scripts/ScienceTerminal.gd")
const HUD = preload("res://scripts/HUD.gd")
const Player = preload("res://scripts/Player.gd")

func _ready() -> void:
    _build_environment()
    _build_player()
    _build_hud()
    GameState.log_added.emit("Sistema principal ativado. Módulo de preparação pronto.", "good")

func _build_environment() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("03070d")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("27465d")
    env.ambient_light_energy = 0.65
    world_env.environment = env
    add_child(world_env)

    var dir_light := DirectionalLight3D.new()
    dir_light.rotation_degrees = Vector3(-55.0, -35.0, 0.0)
    dir_light.light_color = Color("9bc8e5")
    dir_light.light_energy = 1.0
    add_child(dir_light)

    _make_box("floor", Vector3(0, -0.15, 0), Vector3(18, 0.3, 12), Color("101b26"))
    _make_box("ceiling", Vector3(0, 4.2, 0), Vector3(18, 0.3, 12), Color("0b121c"))
    _make_box("back_wall", Vector3(0, 2, -6), Vector3(18, 4.3, 0.3), Color("111e2b"))
    _make_box("left_wall", Vector3(-9, 2, 0), Vector3(0.3, 4.3, 12), Color("111e2b"))
    _make_box("right_wall", Vector3(9, 2, 0), Vector3(0.3, 4.3, 12), Color("111e2b"))
    _make_box("bulkhead", Vector3(0, 2, 6), Vector3(18, 4.3, 0.3), Color("111e2b"))

    for x in [-6.5, -2.2, 2.2, 6.5]:
        _make_box("ceiling_light", Vector3(x, 4.0, 0), Vector3(2.4, 0.04, 0.18), Color("65d9ff"), true)

    var power_panel := ShipPanel.new()
    add_child(power_panel)
    power_panel.setup("power", "REATOR / DISTRIBUIÇÃO", Vector3(-6.8, 1.9, -5.75))

    var life_panel := ShipPanel.new()
    add_child(life_panel)
    life_panel.setup("life_support", "SUPORTE DE VIDA", Vector3(-2.3, 1.9, -5.75))

    var comms_panel := ShipPanel.new()
    add_child(comms_panel)
    comms_panel.setup("comms", "COMUNICAÇÕES", Vector3(2.3, 1.9, -5.75))

    var science_panel := ShipPanel.new()
    add_child(science_panel)
    science_panel.setup("science", "LABORATÓRIO", Vector3(6.8, 1.9, -5.75))

    var terminal := ScienceTerminal.new()
    add_child(terminal)
    terminal.setup(Vector3(0, 1.0, -1.4))

    _make_box("console_base", Vector3(0, 0.5, -1.4), Vector3(2.2, 1.0, 0.7), Color("0e2532"))

func _build_player() -> void:
    var body := CharacterBody3D.new()
    body.name = "Player"
    body.position = Vector3(0, 0.0, 4.2)
    body.set_script(Player)
    body.add_child(_create_capsule_collision())
    add_child(body)

func _create_capsule_collision() -> CollisionShape3D:
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.38
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    return collision

func _build_hud() -> void:
    var hud := HUD.new()
    add_child(hud)

func _make_box(name_: String, pos: Vector3, size: Vector3, color: Color, emissive := false) -> void:
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
    material.metallic = 0.45
    material.roughness = 0.42

    if emissive:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 3.0

    mesh.material_override = material
    body.add_child(mesh)
    add_child(body)
