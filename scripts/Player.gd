extends Node3D

@export var mouse_sensitivity := 0.0025
var velocity := Vector3.ZERO
var gravity := 18.0
var camera: Camera3D
var prompt: Label

func _ready() -> void:
    camera = Camera3D.new()
    camera.position = Vector3(0, 1.55, 0)
    camera.current = true
    add_child(camera)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera.rotation.x = clamp(camera.rotation.x - event.relative.y * mouse_sensitivity, -1.45, 1.45)
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
    if event.is_action_pressed("interact"):
        interact()

func _physics_process(delta: float) -> void:
    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
    var speed := 6.0 if Input.is_action_pressed("sprint") else 3.2
    velocity.x = move_toward(velocity.x, direction.x * speed, 18.0 * delta)
    velocity.z = move_toward(velocity.z, direction.z * speed, 18.0 * delta)
    if not is_on_floor(): velocity.y -= gravity * delta
    else: velocity.y = 0.0
    move_and_slide()

func interact() -> void:
    var query := PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_transform.basis.z * 3.0)
    query.exclude = [self]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit and hit.collider.has_method("interact"):
        hit.collider.interact()
