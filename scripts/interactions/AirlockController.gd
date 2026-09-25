extends StaticBody3D
class_name LL_AirlockController

var open := false
var equalized := false
var pressure := 1.0
var inner_door: MeshInstance3D
var outer_door: MeshInstance3D
var display: Label3D

func setup(position_3d: Vector3) -> void:
    position = position_3d
    _build_door("inner")
    _build_door("outer")
    _build_display()

func _build_door(kind: String) -> void:
    var mesh := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size = Vector3(2.6, 3.2, 0.16)
    mesh.mesh = cube
    mesh.position = Vector3(0, 1.6, -1.0 if kind == "inner" else 1.0)
    mesh.material_override = _material(Color("344854"))
    add_child(mesh)
    if kind == "inner":
        inner_door = mesh
    else:
        outer_door = mesh
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(2.6, 3.2, 0.16)
    collision.shape = shape
    collision.position = mesh.position
    add_child(collision)

func _build_display() -> void:
    display = Label3D.new()
    display.position = Vector3(0, 3.8, 0)
    display.font_size = 24
    display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    display.no_depth_test = true
    display.modulate = Color("d4ecff")
    add_child(display)
    _refresh()

func get_interaction_prompt() -> String:
    return "[E] CONTROLAR AIRLOCK"

func interact() -> void:
    if not GameState.systems.get("airlock", false):
        EventBus.post("Airlock offline. Ative o controlador do módulo.", "warning")
        return
    if not equalized:
        _equalize()
    else:
        _toggle_outer()
    _refresh()

func _equalize() -> void:
    pressure = move_toward(pressure, 0.0, 0.25)
    equalized = pressure < 0.1
    EventBus.post("Câmara em equalização: %.0f%%" % ((1.0 - pressure) * 100.0), "info")

func _toggle_outer() -> void:
    open = not open
    var target := Vector3(0, 4.2, 1.0) if open else Vector3(0, 1.6, 1.0)
    var tween := create_tween()
    tween.tween_property(outer_door, "position", target, 0.8)
    EventBus.post("Porta externa %s." % ("aberta" if open else "fechada"), "good")

func _refresh() -> void:
    if display == null:
        return
    display.text = "AIRLOCK\n%s" % ("OPEN" if open else ("EQUALIZED" if equalized else "PRESSURIZED"))

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = 0.8
    material.roughness = 0.25
    return material
