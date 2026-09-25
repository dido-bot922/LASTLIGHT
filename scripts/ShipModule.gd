extends StaticBody3D
class_name ShipModule

var module_id := "reactor"
var label: Label3D
var status_light: MeshInstance3D
var screen: Label3D

func setup(id: String, pos: Vector3) -> void:
    module_id = id
    position = pos
    _build_console()
    _build_label()
    _refresh_visual()

func _build_console() -> void:
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.9, 1.35, 0.22)
    collision.shape = shape
    add_child(collision)

    var housing := MeshInstance3D.new()
    var housing_mesh := BoxMesh.new()
    housing_mesh.size = Vector3(1.9, 1.35, 0.18)
    housing.mesh = housing_mesh
    housing.position.z = 0.04
    housing.material_override = _material(_color_for(module_id), 0.65, 0.32)
    add_child(housing)

    screen = Label3D.new()
    screen.text = _screen_text()
    screen.font_size = 18
    screen.modulate = _text_color_for(module_id)
    screen.position = Vector3(0, 0.12, -0.08)
    screen.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    screen.no_depth_test = true
    add_child(screen)

    status_light = MeshInstance3D.new()
    var led := BoxMesh.new()
    led.size = Vector3(0.12, 0.12, 0.04)
    status_light.mesh = led
    status_light.position = Vector3(-0.72, 0.48, -0.08)
    add_child(status_light)

func _build_label() -> void:
    label = Label3D.new()
    label.text = _title_for(module_id) + "\n[E] OPERAR"
    label.font_size = 25
    label.position = Vector3(0, 1.05, -0.1)
    label.modulate = _text_color_for(module_id)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.no_depth_test = true
    add_child(label)

func interact() -> void:
    match module_id:
        "reactor": GameState.toggle_system("reactor")
        "life_support": GameState.toggle_system("life_support")
        "science": GameState.toggle_system("science")
        "comms": GameState.toggle_system("comms")
        "cargo": GameState.log_added.emit("CARGA: ferramentas e amostras estão seladas.", "good")
        "airlock":
            GameState.toggle_system("airlock")
            GameState.log_added.emit("AIRLOCK: pressão e travas verificadas.", "good")
    _refresh_visual()

func _refresh_visual() -> void:
    if status_light == null:
        return
    var active := false
    if GameState.systems.has(module_id):
        active = GameState.systems[module_id]
    var color := Color("57f2b0") if active else Color("d28d43")
    status_light.material_override = _material(color, 0.1, 0.2, true)
    screen.text = _screen_text()

func _screen_text() -> String:
    var state := "ONLINE" if GameState.systems.get(module_id, false) else "STANDBY"
    return "[%s]\n%s" % [state, _telemetry_for(module_id)]

func _telemetry_for(id: String) -> String:
    var data := {"reactor": "CORE  82%", "life_support": "O2    96%", "science": "LAB   READY", "comms": "LINK  SEARCH", "cargo": "SEALED", "airlock": "PRES  NOMINAL"}
    return data.get(id, "READY")

func _title_for(id: String) -> String:
    var names := {"reactor": "REATOR", "life_support": "SUPORTE DE VIDA", "science": "LABORATÓRIO", "comms": "COMUNICAÇÕES", "cargo": "CARGA", "airlock": "AIRLOCK"}
    return names.get(id, "MÓDULO")

func _color_for(id: String) -> Color:
    var colors := {"reactor": Color("244a5b"), "life_support": Color("285443"), "science": Color("384878"), "comms": Color("4d3868"), "cargo": Color("574a32"), "airlock": Color("46525b")}
    return colors.get(id, Color("20333d"))

func _text_color_for(id: String) -> Color:
    var colors := {"reactor": Color("aee8ff"), "life_support": Color("b8f5c6"), "science": Color("d2d7ff"), "comms": Color("e1c6ff"), "cargo": Color("ffd986"), "airlock": Color("dfe9f0")}
    return colors.get(id, Color("dfe9f0"))

func _material(color: Color, metallic: float, roughness: float, glow := false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = metallic
    material.roughness = roughness
    if glow:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 3.0
    return material
