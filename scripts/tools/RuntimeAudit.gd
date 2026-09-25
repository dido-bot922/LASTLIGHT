extends Node
class_name LL_RuntimeAudit

var report: Dictionary = {}
var required_autoloads := [
    "GameState", "EventBus", "ResourceSystem", "FailureSystem", "EnvironmentalHazardSystem",
    "ScienceLab", "NavigationSystem", "ShipAI", "AlienSignal", "Campaign", "SaveManager",
    "SaveJournal", "MissionTelemetry", "AudioDirector", "AtmosphereDirector", "ResearchArchive",
    "ContentDatabase", "RuntimeBridge", "GameBootstrap", "ChoiceSystem", "TutorialDirector"
]

func run() -> Dictionary:
    var missing: Array[String] = []
    var invalid: Array[String] = []
    for id in required_autoloads:
        var node := get_node_or_null("/root/" + id)
        if node == null:
            missing.append(id)
    if not FileAccess.file_exists("res://scenes/Main.tscn"):
        invalid.append("Main.tscn")
    if not FileAccess.file_exists("res://scripts/Main.gd"):
        invalid.append("Main.gd")
    var line_counter := load("res://scripts/tools/LineCounter.gd").new()
    var lines: Dictionary = line_counter.count_project_lines()
    line_counter.free()
    report = {"ok": missing.is_empty() and invalid.is_empty(), "missing_autoloads": missing, "invalid_files": invalid, "lines": lines, "timestamp": Time.get_datetime_string_from_system()}
    EventBus.remember("runtime_audit", report)
    return report.duplicate(true)
