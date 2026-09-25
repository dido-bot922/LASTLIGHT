extends StaticBody3D

var system_id := "power"
var title_text := "PAINEL"
var body_mesh: MeshInstance3D
var indicator: MeshInstance3D
var label: Label3D

func setup(id: String, display_name: String, position_3d: Vector3) -> void:
    system_id = id
    title_text = display_name
    position = position_3d

    var collision := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(1.4, 1.1, 0.18)
    collision.shape = box
    add_child(collision)

    body_mesh = MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(1.4, 1.1, 0.12)
    body_mesh.mesh = mesh
    body_mesh.position.z = 0.05
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("162534")
    material.metallic = 0.7
    material.roughness = 0.28
    body_mesh.material_override = material
    add_child(body_mesh)

    indicator = MeshInstance3D.new()
    var led := BoxMesh.new()
    led.size = Vector3(0.12, 0.12, 0.03)
    indicator.mesh = led
    indicator.position = Vector3(-0.48, 0.37, -0.04)
    add_child(indicator)

    label = Label3D.new()
    label.text = title_text + "\nE  OPERAR"
    label.font_size = 32
    label.modulate = Color("b9e9ff")
    label.position = Vector3(0.0, -0.02, -0.12)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.no_depth_test = true
    add_child(label)

    _refresh()

func interact() -> void:
    GameState.toggle_system(system_id)
    _refresh()

func _refresh() -> void:
    if indicator == null:
        return

    var active := GameState.systems[system_id]
    var material := StandardMaterial3D.new()
    material.emission_enabled = true
    material.emission_energy_multiplier = 2.5
    material.albedo_color = Color("46f5b0") if active else Color("e6a34a")
    material.emission = material.albedo_color
    indicator.material_override = material
