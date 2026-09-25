extends Node
class_name LL_FirstPersonInteractionDirector

signal focus_changed(target: Node, prompt: String)
signal focus_cleared
signal interaction_started(target: Node, action: String)
signal interaction_finished(target: Node, action: String, success: bool)

@export var distance := 3.4
@export var collision_mask := 1
@export var require_line_of_sight := true

var camera: Camera3D
var focused_target: Node
var last_target: Node
var cooldown := 0.0
var history: Array[Dictionary] = []

func attach_to_camera(owner_camera: Camera3D) -> void:
    camera = owner_camera

func _physics_process(delta: float) -> void:
    cooldown = maxf(0.0, cooldown - delta)
    if camera == null:
        return
    var next_target := _raycast_target()
    if next_target == focused_target:
        return
    focused_target = next_target
    if focused_target == null:
        focus_cleared.emit()
        return
    var prompt := "[E] OPERAR"
    if focused_target.has_method("get_interaction_prompt"):
        prompt = str(focused_target.get_interaction_prompt())
    elif focused_target.has_meta("interaction_prompt"):
        prompt = str(focused_target.get_meta("interaction_prompt"))
    focus_changed.emit(focused_target, prompt)

func use() -> bool:
    if cooldown > 0.0 or focused_target == null:
        return false
    if not focused_target.has_method("interact"):
        return false
    cooldown = 0.18
    var action := "interact"
    if focused_target.has_method("get_interaction_action"):
        action = str(focused_target.get_interaction_action())
    interaction_started.emit(focused_target, action)
    var result = focused_target.interact()
    var success := true
    if result is bool:
        success = result
    history.append({"target": focused_target.name, "action": action, "success": success, "time": Time.get_ticks_msec()})
    if history.size() > 100:
        history.pop_front()
    interaction_finished.emit(focused_target, action, success)
    return success

func _raycast_target() -> Node:
    var from := camera.global_position
    var to := from - camera.global_transform.basis.z * distance
    var query := PhysicsRayQueryParameters3D.create(from, to, collision_mask)
    query.exclude = [camera.get_parent()]
    var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
    if result.is_empty():
        return null
    var collider = result.get("collider")
    if collider is Node and collider.has_method("interact"):
        return collider
    return null
