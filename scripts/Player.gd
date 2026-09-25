extends CharacterBody3D
class_name ShipPlayer

signal interaction_target_changed(prompt: String)
signal movement_state_changed(state: String)
signal stamina_changed(value: float, maximum: float)

const FirstPersonPresentation = preload("res://scripts/player/FirstPersonPresentation.gd")
const FirstPersonAnimationRouter = preload("res://scripts/player/FirstPersonAnimationRouter.gd")
const FirstPersonFeedback = preload("res://scripts/player/FirstPersonFeedback.gd")

@export var mouse_sensitivity := 0.0025
@export var walk_speed := 3.2
@export var sprint_speed := 5.4
@export var acceleration := 20.0
@export var gravity := 18.0
@export var interaction_distance := 3.4
@export var stamina_maximum := 100.0
@export var stamina_drain := 22.0
@export var stamina_recovery := 17.0

var camera: Camera3D
var presentation: FirstPersonPresentation
var animation_router: FirstPersonAnimationRouter
var feedback: FirstPersonFeedback
var pitch := 0.0
var current_target: Object
var movement_state := "IDLE"
var stamina := 100.0
var _bob_time := 0.0
var _locked := false

func _ready() -> void:
    _create_camera()
    _create_first_person_layers()
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _create_camera() -> void:
    camera = Camera3D.new()
    camera.name = "PlayerCamera"
    camera.position = Vector3(0.0, 1.55, 0.0)
    camera.fov = 76.0
    camera.near = 0.03
    camera.current = true
    add_child(camera)

func _create_first_person_layers() -> void:
    presentation = FirstPersonPresentation.new()
    presentation.name = "FirstPersonPresentation"
    add_child(presentation)
    presentation.setup(camera)
    animation_router = FirstPersonAnimationRouter.new()
    animation_router.name = "FirstPersonAnimationRouter"
    add_child(animation_router)
    animation_router.setup(presentation)
    feedback = FirstPersonFeedback.new()
    feedback.name = "FirstPersonFeedback"
    add_child(feedback)
    feedback.subtitle.connect(_on_subtitle)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not _locked:
        rotate_y(-event.relative.x * mouse_sensitivity)
        pitch = clampf(pitch - event.relative.y * mouse_sensitivity, -1.45, 1.45)
        camera.rotation.x = pitch
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        _toggle_cursor()
    if event.is_action_pressed("interact"):
        _interact()

func _physics_process(delta: float) -> void:
    if _locked:
        _brake(delta)
        return
    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var local_direction := Vector3(input_vec.x, 0.0, input_vec.y)
    var direction := (transform.basis * local_direction).normalized()
    var wants_sprint := Input.is_action_pressed("sprint") and input_vec.length() > 0.1
    var sprinting := wants_sprint and stamina > 0.0
    var target_speed := sprint_speed if sprinting else walk_speed
    velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, direction.z * target_speed, acceleration * delta)
    if is_on_floor():
        velocity.y = 0.0
    else:
        velocity.y -= gravity * delta
    move_and_slide()
    _update_stamina(delta, sprinting)
    _update_movement_state(direction, sprinting)
    _update_target()

func _brake(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
    velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
    move_and_slide()

func _update_stamina(delta: float, sprinting: bool) -> void:
    if sprinting:
        stamina = maxf(0.0, stamina - stamina_drain * delta)
    else:
        stamina = minf(stamina_maximum, stamina + stamina_recovery * delta)
    stamina_changed.emit(stamina, stamina_maximum)

func _update_movement_state(direction: Vector3, sprinting: bool) -> void:
    var next := "SPRINT" if sprinting else ("WALK" if direction.length() > 0.05 else "IDLE")
    if next == movement_state:
        return
    movement_state = next
    if presentation != null:
        presentation.set_state(next)
    if animation_router != null:
        animation_router.play(next.to_lower())
    movement_state_changed.emit(next)

func _update_target() -> void:
    if camera == null:
        return
    var from := camera.global_position
    var to := from - camera.global_transform.basis.z * interaction_distance
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [self]
    var result := get_world_3d().direct_space_state.intersect_ray(query)
    var target = result.get("collider") if not result.is_empty() else null
    if target == current_target:
        return
    current_target = target
    if target != null and target.has_method("interact"):
        var prompt := "[E] OPERAR // " + target.name
        if target.has_method("get_interaction_prompt"):
            prompt = target.get_interaction_prompt()
        interaction_target_changed.emit(prompt)
    else:
        interaction_target_changed.emit("")

func _interact() -> void:
    if current_target == null or not current_target.has_method("interact"):
        return
    if presentation != null:
        presentation.begin_action("interact", 0.45)
    if animation_router != null:
        animation_router.play("interact")
    if feedback != null:
        feedback.confirm()
    current_target.interact()

func lock_controls(value: bool) -> void:
    _locked = value
    if value:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _toggle_cursor() -> void:
    var captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if captured else Input.MOUSE_MODE_CAPTURED)

func _on_subtitle(text: String, duration: float) -> void:
    EventBus.remember("first_person_subtitle", {"text": text, "duration": duration})
