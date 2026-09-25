extends StaticBody3D

@export var system_id := "power"
@export var title := "PAINEL"
var label: Label3D
var indicator: MeshInstance3D

func setup(id: String, display_name: String, position_3d: Vector3) -> void:
    system_id = id
    title = display_name
    position = position_3d
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(1.4, 1.1, 0.18)
    shape.shape = box
    add_child(shape)
    var panel := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(1.4, 1.1, 0.12)
    panel.mesh = mesh
    panel.position.z = 0.05
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("162534")
    mat.metallic = 0.7
    mat.roughness = 0.28
    panel.material_override = mat
    add_child(panel)
    indicator = MeshInstance3D.new()
    var led := BoxMesh.new()
    led.size = Vector3(0.12, 0.12, 0.03)
    indicator.mesh = led
    indicator.position = Vector3(-0.48, 0.37, -0.04)
    add_child(indicator)
    label = Label3D.new()
    label.text = title + "\nE  OPERAR"
    label.font_size = 32
    label.modulate = Color("b9e9ff")
    label.position = Vector3(0, -0.02, -0.12)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.no_depth_test = true
    add_child(label)
    _refresh()

func interact() -> void:
    GameState.operate(system_id)
    _refresh()

func _refresh() -> void:
    if not indicator: return
    var mat := StandardMaterial3D.new()
    mat.emission_enabled = true
    mat.emission_energy_multiplier = 2.5
    mat.albedo_color = Color("46f5b0") if GameState.systems[system_id] else Color("e6a34a")
    mat.emission = mat.albedo_color
    indicator.material_override = mat
