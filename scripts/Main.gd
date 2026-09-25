extends StaticBody3D
class_name ShipModule

var label: Label3D
var module_name := "module"
var module_type := "core"

func setup(id: String, pos: Vector3) -> void:
    module_name = id
    module_type = _type(id)
    position = pos

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(2.2, 2.6, 1.0)
    collision.shape = shape
    add_child(collision)

    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(2.2, 2.6, 1.0)
    mesh.mesh = box
    var material := StandardMaterial3D.new()
    material.albedo_color = _color_for(id)
    material.metallic = 0.7
    material.roughness = 0.35
    mesh.material_override = material
    add_child(mesh)

    label = Label3D.new()
    label.text = _title_for(id) + "\nE  INSPECIONAR"
    label.font_size = 26
    label.position = Vector3(0, 1.8, -0.62)
    label.modulate = _text_color_for(id)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.no_depth_test = true
    add_child(label)

func interact() -> void:
    match module_name:
        "reactor":
            GameState.toggle_system("power")
        "life_support":
            GameState.toggle_system("life_support")
        "science":
            GameState.toggle_system("science")
        "comms":
            GameState.toggle_system("comms")
        "cargo":
            GameState.log_added.emit("Carga: amostras e ferramentas do módulo de suporte preservadas.", "good")
        "airlock":
            GameState.log_added.emit("Airlock: pressão estabilizada. Acesso externo pronto.", "good")
        "corridor":
            GameState.log_added.emit("Corredor: tráfego da nave normalizado.", "good")

func _title_for(id: String) -> String:
    var names := {
        "reactor": "REATOR",
        "life_support": "SUPORTE DE VIDA",
        "science": "LABORATÓRIO",
        "comms": "COMUNICAÇÕES",
        "cargo": "CARGA",
        "airlock": "AIRLOCK",
        "corridor": "CORREDOR"
    }
    return names.get(id, "MÓDULO")

func _type(id: String) -> String:
    var types := {
        "reactor": "system",
        "life_support": "system",
        "science": "system",
        "comms": "system",
        "cargo": "storage",
        "airlock": "access",
        "corridor": "transit"
    }
    return types.get(id, "utility")

func _color_for(id: String) -> Color:
    var colors := {
        "reactor": Color("2b4d59"),
        "life_support": Color("305b46"),
        "science": Color("3d4673"),
        "comms": Color("4f3d6a"),
        "cargo": Color("5b4d34"),
        "airlock": Color("4a5660"),
        "corridor": Color("1f2d36")
    }
    return colors.get(id, Color("20323b"))

func _text_color_for(id: String) -> Color:
    var colors := {
        "reactor": Color("aee8ff"),
        "life_support": Color("b8f5c6"),
        "science": Color("c4d2ff"),
        "comms": Color("e2c7ff"),
        "cargo": Color("ffd985"),
        "airlock": Color("dceaf7"),
        "corridor": Color("d9f0ff")
    }
    return colors.get(id, Color("d9f0ff"))
