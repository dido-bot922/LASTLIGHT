extends Node
class_name CharacterPipeline

const REQUIRED_BONES := ["head", "neck", "spine", "hand_l", "hand_r"]
var imported_assets: Dictionary = {}
var fallback_enabled := true
var quality_profile := "CINEMATIC"

func register_character(id: String, scene: PackedScene, metadata: Dictionary = {}) -> void:
    if scene == null:
        push_warning("Character scene nula: " + id)
        return
    imported_assets[id] = {"scene": scene, "metadata": metadata}

func spawn_character(id: String, parent: Node, transform := Transform3D.IDENTITY) -> Node:
    if not imported_assets.has(id):
        return _spawn_fallback(id, parent, transform)
    var instance: Node = imported_assets[id].scene.instantiate()
    parent.add_child(instance)
    if instance is Node3D:
        instance.transform = transform
    _configure_instance(instance, imported_assets[id].metadata)
    return instance

func validate_rig(root: Node) -> Dictionary:
    var found: Array[String] = []
    for bone in REQUIRED_BONES:
        if root.find_child(bone, true, false) != null:
            found.append(bone)
    return {"valid": found.size() == REQUIRED_BONES.size(), "found": found, "missing": _missing(found)}

func configure_quality(profile: String) -> void:
    quality_profile = profile
    match profile:
        "ULTRA":
            fallback_enabled = false
        "CINEMATIC":
            fallback_enabled = true
        "PERFORMANCE":
            fallback_enabled = true
        _:
            quality_profile = "CINEMATIC"

func _configure_instance(instance: Node, metadata: Dictionary) -> void:
    var animator := FirstPersonAnimationRouter.new()
    animator.name = "AnimationRouter"
    instance.add_child(animator)
    animator.setup(instance)
    instance.set_meta("character_metadata", metadata)
    instance.set_meta("quality_profile", quality_profile)

func _spawn_fallback(id: String, parent: Node, transform: Transform3D) -> Node3D:
    var root := Node3D.new()
    root.name = "FallbackCharacter_" + id
    parent.add_child(root)
    root.transform = transform
    var body := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.28
    capsule.height = 1.3
    body.mesh = capsule
    body.position.y = 0.85
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("25384a")
    material.metallic = 0.4
    material.roughness = 0.45
    body.material_override = material
    root.add_child(body)
    return root

func _missing(found: Array[String]) -> Array[String]:
    var result: Array[String] = []
    for bone in REQUIRED_BONES:
        if bone not in found:
            result.append(bone)
    return result
