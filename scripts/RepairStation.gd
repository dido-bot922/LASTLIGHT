extends StaticBody3D
class_name RepairStation

@export var target_system := "power"
var health := 0.45
var label: Label3D

func configure(position_3d: Vector3, system := "power") -> void:
    position = position_3d
    target_system = system
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.4, 1.6, 0.8)
    collision.shape = shape
    add_child(collision)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(1.4, 1.6, 0.8)
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("3b2024")
    mat.metallic = 0.65
    mesh.material_override = mat
    add_child(mesh)
    label = Label3D.new()
    label.text = "ESTAÇÃO DE REPARO\nE  DIAGNÓSTICO"
    label.position = Vector3(0, 1.35, -0.45)
    label.font_size = 26
    label.modulate = Color("ffbd68")
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.no_depth_test = true
    add_child(label)

func interact() -> void:
    if not Inventory.has_item("repair_kit"):
        GameState.log_added.emit("Sem kit de reparo disponível.", "warning")
        return
    if GameState.resources.energy < 5.0:
        GameState.log_added.emit("A estação precisa de pelo menos 5%% de energia.", "warning")
        return
    Inventory.remove_item("repair_kit")
    health = min(1.0, health + 0.4)
    GameState.resources.energy -= 5.0
    GameState.log_added.emit("Reparo concluído em %s: integridade %d%%." % [target_system, int(health * 100.0)], "good")
