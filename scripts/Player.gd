extends CharacterBody3D

signal interaction_target_changed(title: String)

@export var mouse_sensitivity := 0.0025
@export var walk_speed := 3.2
@export var sprint_speed := 5.4
@export var acceleration := 20.0
@export var gravity := 18.0

var camera: Camera3D
var pitch := 0.0
var current_target: Object

func _ready() -> void:
    camera = Camera3D.new()
    camera.name = "PlayerCamera"
    camera.position = Vector3(0.0, 1.55, 0.0)
    camera.fov = 76.0
    camera.current = true
    add_child(camera)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -1.45, 1.45)
        camera.rotation.x = pitch
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
    if event.is_action_pressed("interact"):
        _interact()

func _physics_process(delta: float) -> void:
    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_vec.x, 0.0, input_vec.y)).normalized()
    var target_speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
    velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, direction.z * target_speed, acceleration * delta)
    velocity.y = 0.0 if is_on_floor() else velocity.y - gravity * delta
    move_and_slide()
    _update_target()

func _update_target() -> void:
    var from := camera.global_position
    var to := from - camera.global_transform.basis.z * 3.2
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [self]
    var result := get_world_3d().direct_space_state.intersect_ray(query)
    var target = result.get("collider") if not result.is_empty() else null
    if target == current_target:
        return
    current_target = target
    if target != null and target.has_method("interact"):
        interaction_target_changed.emit("E  OPERAR  //  " + target.name)
    else:
        interaction_target_changed.emit("")

func _interact() -> void:
    if current_target != null and current_target.has_method("interact"):
        current_target.interact()
