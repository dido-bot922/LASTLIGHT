extends CharacterBody3D

@export var mouse_sensitivity := 0.0025
@export var walk_speed := 3.2
@export var sprint_speed := 6.0
@export var acceleration := 18.0
@export var gravity := 18.0

var camera: Camera3D
var pitch := 0.0

func _ready() -> void:
    camera = Camera3D.new()
    camera.name = "PlayerCamera"
    camera.position = Vector3(0.0, 1.55, 0.0)
    camera.current = true
    add_child(camera)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -1.45, 1.45)
        camera.rotation.x = pitch

    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    if event.is_action_pressed("interact"):
        _interact()

func _physics_process(delta: float) -> void:
    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var move_dir := (transform.basis * Vector3(input_vec.x, 0.0, input_vec.y)).normalized()
    var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed

    velocity.x = move_toward(velocity.x, move_dir.x * speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, move_dir.z * speed, acceleration * delta)

    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0

    move_and_slide()

func _interact() -> void:
    var from := camera.global_position
    var to := from - camera.global_transform.basis.z * 3.0
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [self]
    var result := get_world_3d().direct_space_state.intersect_ray(query)
    if not result.is_empty() and result.collider.has_method("interact"):
        result.collider.interact()
