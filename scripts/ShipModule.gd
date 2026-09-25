extends StaticBody3D
class_name ShipModule

var module_id := "reactor"
var label: Label3D

func setup(id: String, pos: Vector3) -> void:
    module_id = id
    position = pos

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(2.2, 2.7, 1.0)
    collision.shape = shape
    add_child(collision)

    var panel := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(2.2, 2.7, 1.0)
    panel.mesh = box
    panel.position.z = 0.05
    var material := StandardMaterial3D.new()
    material.albedo_color = _color_for(module_id)
    material.metallic = 0.72
    material.roughness = 0.35
    panel.material_override = material
    add_child(panel)

    label = Label3D.new()
    label.text = _title_for(module_id) + "\nE  Operar"
    label.font_size = 26
    label.position = Vector3(0.0, 1.75, -0.35)
    label.modulate = _text_color_for(module_id)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.no_depth_test = true
    add_child(label)

    _refresh_visual()

func interact() -> void:
    match module_id:
        "reactor":
            GameState.toggle_system("reactor")
        "life_support":
            GameState.toggle_system("life_support")
        "science":
            GameState.toggle_system("science")
        "comms":
            GameState.toggle_system("comms")
        "cargo":
            GameState.log_added.emit("Carga: reagentes, filtros e amostras preservadas no módulo inferior.", "good")
        "airlock":
            GameState.toggle_system("airlock")
            GameState.log_added.emit("Airlock estabilizado. Acesso externo pronto.", "good")

    _refresh_visual()

func _refresh_visual() -> void:
    var on := false
    if module_id == "reactor":
        on = GameState.systems.reactor
    elif module_id == "life_support":
        on = GameState.systems.life_support
    elif module_id == "science":
        on = GameState.systems.science
    elif module_id == "comms":
        on = GameState.systems.comms
    elif module_id == "airlock":
        on = GameState.systems.airlock

    if label == null:
        return
    label.text = _title_for(module_id) + "\n" + ("ONLINE" if on else "STANDBY")

func _title_for(id: String) -> String:
    var names := {
        "reactor": "REATOR",
        "life_support": "SUPORTE DE VIDA",
        "science": "LABORATÓRIO",
        "comms": "COMUNICAÇÕES",
        "cargo": "CARGA",
        "airlock": "AIRLOCK"
    }
    return names.get(id, "MÓDULO")

func _color_for(id: String) -> Color:
    var colors := {
        "reactor": Color("2b4d59"),
        "life_support": Color("2d564a"),
        "science": Color("3c4d74"),
        "comms": Color("533d6d"),
        "cargo": Color("5c4e32"),
        "airlock": Color("47545d")
    }
    return colors.get(id, Color("20333d"))

func _text_color_for(id: String) -> Color:
    var colors := {
        "reactor": Color("aee8ff"),
        "life_support": Color("b8f5c6"),
        "science": Color("d2d7ff"),
        "comms": Color("e1c6ff"),
        "cargo": Color("ffd986"),
        "airlock": Color("dfe9f0")
    }
    return colors.get(id, Color("dfe9f0"))
