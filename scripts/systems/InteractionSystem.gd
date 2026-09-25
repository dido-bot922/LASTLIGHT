extends Node
class_name LL_InteractionSystem

signal focused(target: Node, prompt: String)
signal unfocused
signal used(target: Node)

@export var distance := 3.4
@export var collision_mask := 1
var camera: Camera3D
var target: Node
var last_target: Node

func configure(player_camera: Camera3D) -> void:
    camera = player_camera

func _physics_process(_delta: float) -> void:
    if camera == null:
        return
    var from := camera.global_position
    var to := from - camera.global_transform.basis.z * distance
    var query := PhysicsRayQueryParameters3D.create(from, to, collision_mask)
    var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
    target = result.get("collider") if not result.is_empty() else null
    if target == last_target:
        return
    last_target = target
    if target != null and target.has_method("interact"):
        var prompt_text := "[E] OPERAR"
        if target.has_method("get_interaction_prompt"):
            prompt_text = target.get_interaction_prompt()
        focused.emit(target, prompt_text)
    else:
        unfocused.emit()

func use() -> void:
    if target != null and target.has_method("interact"):
        target.interact()
        used.emit(target)
