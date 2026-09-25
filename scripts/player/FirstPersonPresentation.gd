extends Node3D
class_name FirstPersonPresentation

signal state_changed(state: String)
signal action_started(action: String)
signal action_finished(action: String)

@export var head_bob_enabled := true
@export var head_bob_frequency := 8.0
@export var head_bob_amplitude := 0.018
@export var weapon_sway := 0.035
@export var camera_smooth := 12.0

var camera: Camera3D
var view_model: Node3D
var hands: Node3D
var active_state := "IDLE"
var action_timer := 0.0
var action_name := ""
var bob_time := 0.0
var default_camera_position := Vector3(0.0, 1.55, 0.0)
var default_camera_rotation := Vector3.ZERO
var target_fov := 76.0

func setup(owner_camera: Camera3D) -> void:
    camera = owner_camera
    if camera == null:
        return
    default_camera_position = camera.position
    default_camera_rotation = camera.rotation
    _build_view_model()

func _process(delta: float) -> void:
    if camera == null:
        return
    _update_action(delta)
    _update_camera(delta)
    _update_view_model(delta)

func set_state(next_state: String) -> void:
    if next_state == active_state:
        return
    active_state = next_state
    state_changed.emit(next_state)

func begin_action(id: String, duration := 0.6) -> bool:
    if action_timer > 0.0:
        return false
    action_name = id
    action_timer = duration
    action_started.emit(id)
    return true

func _update_action(delta: float) -> void:
    if action_timer <= 0.0:
        return
    action_timer -= delta
    if action_timer <= 0.0:
        action_timer = 0.0
        action_finished.emit(action_name)
        action_name = ""

func _update_camera(delta: float) -> void:
    var moving := active_state == "WALK" or active_state == "SPRINT"
    if head_bob_enabled and moving:
        var speed_factor := 1.35 if active_state == "SPRINT" else 1.0
        bob_time += delta * head_bob_frequency * speed_factor
        var amount := head_bob_amplitude * speed_factor
        var bob_target := default_camera_position + Vector3(sin(bob_time) * amount, absf(cos(bob_time)) * amount, 0.0)
        camera.position = camera.position.lerp(bob_target, delta * camera_smooth)
    else:
        camera.position = camera.position.lerp(default_camera_position, delta * camera_smooth)
    camera.fov = lerpf(camera.fov, target_fov, delta * 5.0)

func _update_view_model(delta: float) -> void:
    if hands == null:
        return
    var target_position := Vector3(0.0, -0.06, -0.38)
    var target_rotation := Vector3.ZERO
    if active_state == "SPRINT":
        target_position = Vector3(0.0, -0.13, -0.32)
        target_rotation = Vector3(-0.12, 0.0, 0.0)
    if action_timer > 0.0:
        target_position += Vector3(0.0, 0.05, 0.07)
        target_rotation.x -= 0.15
    hands.position = hands.position.lerp(target_position, delta * 10.0)
    hands.rotation = hands.rotation.lerp(target_rotation, delta * 10.0)

func _build_view_model() -> void:
    hands = Node3D.new()
    hands.name = "FirstPersonHands"
    camera.add_child(hands)
    view_model = Node3D.new()
    view_model.name = "ProceduralHandsFallback"
    hands.add_child(view_model)
    _make_forearm(Vector3(-0.19, -0.17, -0.4), -0.18)
    _make_forearm(Vector3(0.19, -0.17, -0.4), 0.18)

func _make_forearm(position_3d: Vector3, yaw: float) -> void:
    var mesh := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.055
    capsule.height = 0.34
    mesh.mesh = capsule
    mesh.position = position_3d
    mesh.rotation = Vector3(0.35, yaw, -yaw * 0.5)
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("303944")
    material.metallic = 0.65
    material.roughness = 0.32
    mesh.material_override = material
    view_model.add_child(mesh)
