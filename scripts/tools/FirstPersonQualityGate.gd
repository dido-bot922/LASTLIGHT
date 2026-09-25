extends Node
class_name FirstPersonQualityGate

func validate() -> Dictionary:
    var report := {"ok": true, "checks": [], "warnings": []}
    _check(report, "first_person_camera", _has_player_camera())
    _check(report, "first_person_presentation", ResourceLoader.exists("res://scripts/player/FirstPersonPresentation.gd"))
    _check(report, "animation_router", ResourceLoader.exists("res://scripts/player/FirstPersonAnimationRouter.gd"))
    _check(report, "character_pipeline", ResourceLoader.exists("res://scripts/characters/CharacterPipeline.gd"))
    if not ResourceLoader.exists("res://assets/characters"):
        report.warnings.append("Nenhum diretório de assets encontrado; usando fallback procedural.")
    return report

func _has_player_camera() -> bool:
    return ResourceLoader.exists("res://scripts/Player.gd")

func _check(report: Dictionary, id: String, result: bool) -> void:
    report.checks.append({"id": id, "ok": result})
    if not result:
        report.ok = false
