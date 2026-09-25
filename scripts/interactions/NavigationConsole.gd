extends StaticBody3D
class_name LL_NavigationConsole

var destination := "LUNA-ORBITA"
var destinations := ["LUNA-ORBITA", "CERES-RELAY", "KEPLER-GATE", "VEIL-9"]
var index := 0
var screen: Label3D

func setup(position_3d: Vector3) -> void:
    position = position_3d
    _build()
    _refresh()

func _build() -> void:
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.9, 1.35, 0.6)
    collision.shape = shape
    add_child(collision)
    var mesh := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size = Vector3(1.9, 1.35, 0.6)
    mesh.mesh = cube
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("263b47")
    material.metallic = 0.8
    material.roughness = 0.2
    mesh.material_override = material
    add_child(mesh)
    screen = Label3D.new()
    screen.font_size = 18
    screen.position = Vector3(0, 0.1, -0.33)
    screen.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    screen.no_depth_test = true
    screen.modulate = Color("96e5ff")
    add_child(screen)
    var title := Label3D.new()
    title.text = "NAVIGATION\n[E] SELECT / LAUNCH"
    title.font_size = 22
    title.position = Vector3(0, 1.2, -0.2)
    title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    title.no_depth_test = true
    title.modulate = Color("96e5ff")
    add_child(title)

func get_interaction_prompt() -> String:
    return "[E] SELECIONAR ROTA / TRANSFERIR"

func interact() -> void:
    if not GameState.systems.get("navigation", false):
        GameState.toggle_system("navigation")
        EventBus.post("Navegação calibrada. Rota padrão selecionada.", "good")
        _refresh()
        return
    if not GameState.systems.get("thrusters", false):
        GameState.toggle_system("thrusters")
        EventBus.post("Propulsão armada. Segunda interação inicia a transferência.", "good")
        _refresh()
        return
    NavigationSystem.select_destination(destination)
    NavigationSystem.begin_transfer()
    _refresh()

func cycle_destination() -> void:
    index = (index + 1) % destinations.size()
    destination = destinations[index]
    _refresh()

func _refresh() -> void:
    if screen == null:
        return
    var route := NavigationSystem.destinations.get(destination, {})
    screen.text = "%s\nFUEL %d%%" % [destination, int(route.get("fuel", 0.0))]
