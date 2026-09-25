extends Node
class_name LL_AssetManifest

const VERSION := "1.0.0"
const QUALITY_PROFILES := {
    "ULTRA": {"texture_limit": 8192, "shadow_size": 4096, "msaa": 4},
    "CINEMATIC": {"texture_limit": 4096, "shadow_size": 2048, "msaa": 2},
    "PERFORMANCE": {"texture_limit": 2048, "shadow_size": 1024, "msaa": 0}
}

var characters: Dictionary = {}
var animations: Dictionary = {}
var materials: Dictionary = {}
var validated := false

func register_character(id: String, scene_path: String, rig: String, animation_set: Array[String]) -> void:
    characters[id] = {"scene": scene_path, "rig": rig, "animations": animation_set, "valid": false}

func register_animation(id: String, path: String, looping := false, frames := 0) -> void:
    animations[id] = {"path": path, "looping": looping, "frames": frames, "valid": ResourceLoader.exists(path)}

func register_material(id: String, path: String, resolution := 4096) -> void:
    materials[id] = {"path": path, "resolution": resolution, "valid": ResourceLoader.exists(path)}

func validate() -> Dictionary:
    var missing: Array[String] = []
    var valid_characters := 0
    for id in characters:
        var item: Dictionary = characters[id]
        item.valid = ResourceLoader.exists(item.scene)
        if item.valid:
            valid_characters += 1
        else:
            missing.append("character:" + id)
    var valid_animations := 0
    for id in animations:
        var animation: Dictionary = animations[id]
        if animation.valid:
            valid_animations += 1
        else:
            missing.append("animation:" + id)
    var valid_materials := 0
    for id in materials:
        var material: Dictionary = materials[id]
        if material.valid:
            valid_materials += 1
        else:
            missing.append("material:" + id)
    validated = missing.is_empty()
    return {"version": VERSION, "valid": validated, "missing": missing, "characters": valid_characters, "animations": valid_animations, "materials": valid_materials}

func profile(id: String) -> Dictionary:
    return QUALITY_PROFILES.get(id, QUALITY_PROFILES.CINEMATIC).duplicate(true)

func summary() -> String:
    return "assets=%d characters=%d animations=%d materials=%d" % [characters.size() + animations.size() + materials.size(), characters.size(), animations.size(), materials.size()]
