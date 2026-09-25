extends Node
class_name LL_QualityGate

signal completed(report: Dictionary)

var last_report: Dictionary = {}

func run() -> Dictionary:
    var errors: Array[String] = []
    var warnings: Array[String] = []
    var counter := LL_LineCounter.new()
    var lines: Dictionary = counter.count_project_lines()
    counter.free()

    _require_autoload("GameState", errors)
    _require_autoload("EventBus", errors)
    _require_autoload("ResourceSystem", errors)
    _require_autoload("FailureSystem", errors)
    _require_autoload("ScienceLab", errors)
    _require_autoload("NavigationSystem", errors)
    _require_autoload("RuntimeBridge", errors)

    if lines.code < 10000:
        warnings.append("A base ainda possui %d linhas de código; meta: 10000." % lines.code)
    if not FileAccess.file_exists("res://scenes/Main.tscn"):
        errors.append("Cena principal ausente.")
    if not FileAccess.file_exists("res://scripts/Main.gd"):
        errors.append("Script principal ausente.")
    if ScienceLab.experiments.size() < 4:
        warnings.append("Poucos experimentos registrados.")
    if NavigationSystem.destinations.size() < 4:
        warnings.append("Poucas rotas registradas.")

    last_report = {
        "ok": errors.is_empty(),
        "errors": errors,
        "warnings": warnings,
        "lines": lines,
        "timestamp": Time.get_datetime_string_from_system()
    }
    completed.emit(last_report)
    return last_report.duplicate(true)

func _require_autoload(id: String, errors: Array[String]) -> void:
    if get_node_or_null("/root/" + id) == null:
        errors.append("Autoload ausente: " + id)
