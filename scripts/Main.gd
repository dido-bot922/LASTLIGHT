extends Node3D

func _ready() -> void:
    _build_environment()
    _build_player()
    _build_hud()
    GameState.log_added.emit("Bem-vindo, especialista. O desconhecido começa aqui.", "good")

func _build_environment() -> void:
    var world := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("03070d")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("27465d")
    environment.ambient_light_energy = 0.65
    world.environment = environment
    add_child(world)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-55, -35, 0)
    light.light_color = Color("9bc8e5")
    light.light_energy = 0.8
    add_child(light)
    _box("floor", Vector3(0, -0.15, 0), Vector3(18, 0.3, 12), Color("101b26"))
    _box("ceiling", Vector3(0, 4.2, 0), Vector3(18, 0.3, 12), Color("0b121c"))
    _box("back_wall", Vector3(0, 2, -6), Vector3(18, 4.3, 0.3), Color("111e2b"))
    _box("left_wall", Vector3(-9, 2, 0), Vector3(0.3, 4.3, 12), Color("111e2b"))
    _box("right_wall", Vector3(9, 2, 0), Vector3(0.3, 4.3, 12), Color("111e2b"))
    _box("bulkhead", Vector3(0, 2, 6), Vector3(18, 4.3, 0.3), Color("111e2b"))
    for x in [-6.5, -2.2, 2.2, 6.5]:
        _box("ceiling_light", Vector3(x, 4.0, 0), Vector3(2.4, 0.04, 0.18), Color("65d9ff"), true)
    _add_panel("power", "REATOR / DISTRIBUIÇÃO", Vector3(-6.8, 1.9, -5.75))
    _add_panel("life_support", "SUPORTE DE VIDA", Vector3(-2.3, 1.9, -5.75))
    _add_panel("comms", "COMUNICAÇÕES", Vector3(2.3, 1.9, -5.75))
    _add_panel("science", "LABORATÓRIO", Vector3(6.8, 1.9, -5.75))
    var terminal := preload("res://scripts/ScienceTerminal.gd").new()
    add_child(terminal)
    terminal.setup(Vector3(0, 1.0, -1.4))
    _box("console_base", Vector3(0, 0.5, -1.4), Vector3(2.2, 1.0, 0.7), Color("0e2532"))

func _box(node_name: String, pos: Vector3, size: Vector3, color: Color, emissive := false) -> void:
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
    material.metallic = 0.45
    material.roughness = 0.42
    if emissive:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 3.0
    mesh.material_override = material
    body.add_child(mesh)
    add_child(body)

func _add_panel(id: String, title: String, pos: Vector3) -> void:
    var panel := preload("res://scripts/ShipPanel.gd").new()
    add_child(panel)
    panel.setup(id, title, pos)

func _build_player() -> void:
    var player := CharacterBody3D.new()
    player.name = "Player"
    player.set_script(preload("res://scripts/Player.gd"))
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.38
    capsule.height = 1.8
    collision.shape = capsule
    collision.position.y = 0.9
    player.add_child(collision)
    player.position = Vector3(0, 0.1, 4.0)
    add_child(player)

func _build_hud() -> void:
    add_child(preload("res://scripts/HUD.gd").new())
