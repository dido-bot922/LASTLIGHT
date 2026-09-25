extends StaticBody3D
class_name InteractableDoor

@export var locked := true
@export var required_item := "sensor_filter"
@export var open_distance := 2.2
var closed_position := Vector3.ZERO
var is_open := false
var label: Label3D

func configure(position_3d: Vector3, door_name := "PORTA DE ACESSO") -> void:
    position = position_3d
    closed_position = position
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(2.8, 3.4, 0.25)
    collision.shape = shape
    add_child(collision)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(2.8, 3.4, 0.25)
    mesh.mesh = box
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("172b38")
    material.metallic = 0.8
    mesh.material_override = material
    add_child(mesh)
    label = Label3D.new()
    label.text = door_name + "\nE  ABRIR"
    label.position = Vector3(0, 2.0, -0.2)
    label.font_size = 28
    label.modulate = Color("b9e9ff")
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.no_depth_test = true
    add_child(label)

func interact() -> void:
    if locked and not GameState.systems.power:
        GameState.log_added.emit("A porta não responde: energia insuficiente.", "warning")
        return
    if locked:
        locked = false
        GameState.log_added.emit("Trava manual liberada. Acesso autorizado.", "good")
    is_open = not is_open
    var target := closed_position + Vector3(0, open_distance, 0) if is_open else closed_position
    var tween := create_tween()
    tween.tween_property(self, "position", target, 0.7).set_trans(Tween.TRANS_QUAD)
