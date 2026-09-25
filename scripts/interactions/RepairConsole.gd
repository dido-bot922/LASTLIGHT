extends StaticBody3D
class_name LL_RepairConsole

@export var failure_id := "coolant_leak"
@export var required_system := "reactor"
var display: Label3D
var progress_light: MeshInstance3D
var busy := false

func setup(id: String, system_id: String, position_3d: Vector3) -> void:
    failure_id = id
    required_system = system_id
    position = position_3d
    _build_geometry()
    _build_display()
    _refresh()

func _build_geometry() -> void:
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.5, 1.6, 0.55)
    collision.shape = shape
    add_child(collision)
    var mesh := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size = Vector3(1.5, 1.6, 0.55)
    mesh.mesh = cube
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("342b35")
    material.metallic = 0.75
    material.roughness = 0.26
    mesh.material_override = material
    add_child(mesh)
    progress_light = MeshInstance3D.new()
    var led := BoxMesh.new()
    led.size = Vector3(0.12, 0.12, 0.04)
    progress_light.mesh = led
    progress_light.position = Vector3(-0.55, 0.58, -0.3)
    add_child(progress_light)

func _build_display() -> void:
    display = Label3D.new()
    display.font_size = 22
    display.position = Vector3(0, 0.12, -0.31)
    display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    display.no_depth_test = true
    display.modulate = Color("ffd08a")
    add_child(display)
    var title := Label3D.new()
    title.text = "MAINTENANCE\n[E] DIAGNOSTICAR"
    title.font_size = 24
    title.position = Vector3(0, 1.25, -0.2)
    title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    title.no_depth_test = true
    title.modulate = Color("ffd08a")
    add_child(title)

func get_interaction_prompt() -> String:
    return "[E] DIAGNOSTICAR / REPARAR"

func interact() -> void:
    if not GameState.systems.get(required_system, false):
        EventBus.post("Ative %s antes de reparar este conjunto." % required_system.to_upper(), "warning")
        return
    if not FailureSystem.has(failure_id):
        FailureSystem.create_failure(failure_id)
    FailureSystem.repair(failure_id, _tool_quality())
    _refresh()

func _tool_quality() -> float:
    var quality := 1.0
    if ResourceSystem.get_value("temperature") < 5.0:
        quality -= 0.2
    if ResourceSystem.get_value("radiation") > 65.0:
        quality -= 0.15
    return maxf(0.25, quality)

func _refresh() -> void:
    if display == null:
        return
    if FailureSystem.has(failure_id):
        display.text = "FAULT\n%s" % failure_id.to_upper()
        _set_light(Color("ff586e"))
    else:
        display.text = "READY\n%s" % required_system.to_upper()
        _set_light(Color("57f2b0"))

func _set_light(color: Color) -> void:
    if progress_light == null:
        return
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy_multiplier = 3.0
    progress_light.material_override = material
