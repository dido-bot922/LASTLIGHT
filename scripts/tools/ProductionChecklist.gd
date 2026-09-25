extends Node
class_name LL_ProductionChecklist

const CHECKS := [
    "main_scene_exists",
    "player_script_exists",
    "first_person_presentation_exists",
    "animation_router_exists",
    "line_counter_exists",
    "quality_gate_exists",
    "asset_manifest_exists",
    "input_prompt_service_exists",
    "scenario_director_exists"
]

func run() -> Dictionary:
    var results := {}
    var passed := 0
    for id in CHECKS:
        var path := _path_for(id)
        var ok := FileAccess.file_exists(path)
        results[id] = {"ok": ok, "path": path}
        if ok:
            passed += 1
    var report := {"passed": passed, "total": CHECKS.size(), "ok": passed == CHECKS.size(), "checks": results}
    EventBus.remember("production_checklist", report)
    return report

func _path_for(id: String) -> String:
    var paths := {
        "main_scene_exists": "res://scenes/Main.tscn",
        "player_script_exists": "res://scripts/Player.gd",
        "first_person_presentation_exists": "res://scripts/player/FirstPersonPresentation.gd",
        "animation_router_exists": "res://scripts/player/FirstPersonAnimationRouter.gd",
        "line_counter_exists": "res://scripts/tools/LineCounter.gd",
        "quality_gate_exists": "res://scripts/tools/QualityGate.gd",
        "asset_manifest_exists": "res://scripts/characters/AssetManifest.gd",
        "input_prompt_service_exists": "res://scripts/presentation/InputPromptService.gd",
        "scenario_director_exists": "res://scripts/campaign/FirstPersonScenarioDirector.gd"
    }
    return paths.get(id, "")
