extends StaticBody3D
class_name LL_ScienceConsole

@export var experiment_id := "spectral_scan"
var screen: Label3D
var last_quality := -1.0

func setup(id: String, position_3d: Vector3) -> void:
    experiment_id = id
    position = position_3d
    _build_console()
    ScienceLab.experiment_completed.connect(_on_experiment_completed)

func _build_console() -> void:
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.8, 1.25, 0.55)
    collision.shape = shape
    add_child(collision)
    var mesh := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size = Vector3(1.8, 1.25, 0.55)
    mesh.mesh = cube
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("263b63")
    material.metallic = 0.75
    material.roughness = 0.22
    mesh.material_override = material
    add_child(mesh)
    screen = Label3D.new()
    screen.font_size = 20
    screen.position = Vector3(0, 0.1, -0.31)
    screen.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    screen.no_depth_test = true
    screen.modulate = Color("b6d4ff")
    add_child(screen)
    var title := Label3D.new()
    title.text = "SCIENCE CONSOLE\n[E] EXECUTAR"
    title.font_size = 24
    title.position = Vector3(0, 1.1, -0.2)
    title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    title.no_depth_test = true
    title.modulate = Color("cbd9ff")
    add_child(title)
    _refresh()

func get_interaction_prompt() -> String:
    return "[E] EXECUTAR EXPERIMENTO"

func interact() -> void:
    if not GameState.systems.get("science", false):
        EventBus.post("Laboratório sem energia.", "warning")
        return
    if ScienceLab.active.is_empty():
        ScienceLab.start_experiment(experiment_id)
    else:
        EventBus.post("Outro experimento já está em andamento.", "info")
    _refresh()

func _process(_delta: float) -> void:
    _refresh()

func _refresh() -> void:
    if screen == null:
        return
    if not ScienceLab.active.is_empty():
        screen.text = "RUNNING\n%02d sec" % int(ceil(float(ScienceLab.active.remaining)))
    elif last_quality >= 0.0:
        screen.text = "RESULT\n%d%%" % int(last_quality * 100.0)
    else:
        screen.text = "READY\n%s" % experiment_id.to_upper()

func _on_experiment_completed(id: String, quality: float) -> void:
    if id == experiment_id:
        last_quality = quality
        _refresh()
