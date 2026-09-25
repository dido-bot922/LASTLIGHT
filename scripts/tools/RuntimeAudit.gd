extends Node
class_name LL_RuntimeAudit

const REQUIRED_FILES := ["res://scenes/Main.tscn", "res://scripts/Main.gd", "res://scripts/Player.gd", "res://scripts/HUD.gd", "res://scripts/GameState.gd", "res://scripts/core/RuntimeBridge.gd"]

func run() -> Dictionary:
    var missing_files: Array[String] = []
    for path in REQUIRED_FILES:
        if not FileAccess.file_exists(path):
            missing_files.append(path)
    var counter := load("res://scripts/tools/LineCounter.gd").new()
    var lines: Dictionary = counter.count_project_lines()
    counter.free()
    var report := {"ok": missing_files.is_empty(), "missing_files": missing_files, "lines": lines, "autoloads": _autoload_report(), "timestamp": Time.get_datetime_string_from_system()}
    EventBus.remember("runtime_audit", report)
    return report

func _autoload_report() -> Dictionary:
    var ids := ["GameState", "EventBus", "ResourceSystem", "FailureSystem", "ScienceLab", "NavigationSystem", "SaveManager", "RuntimeBridge"]
    var result := {}
    for id in ids:
        result[id] = get_node_or_null("/root/" + id) != null
    return result
