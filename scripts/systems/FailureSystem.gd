extends Node
class_name LL_FailureSystem

signal failure_opened(failure_id: String, description: String)
signal failure_progressed(failure_id: String, progress: float)
signal failure_closed(failure_id: String)

const SEVERITY_MINOR := 1
const SEVERITY_MAJOR := 2
const SEVERITY_CRITICAL := 3

var failures: Dictionary = {}
var definitions := {
    "coolant_leak": {"title": "Vazamento de refrigerante", "system": "reactor", "severity": 2, "repair": 18.0},
    "oxygen_scrubber": {"title": "Depurador de oxigênio instável", "system": "life_support", "severity": 3, "repair": 28.0},
    "antenna_drift": {"title": "Desvio da antena", "system": "comms", "severity": 1, "repair": 12.0},
    "sensor_noise": {"title": "Ruído nos sensores", "system": "science", "severity": 1, "repair": 14.0},
    "thermal_spike": {"title": "Pico térmico", "system": "reactor", "severity": 3, "repair": 34.0},
    "guidance_fault": {"title": "Falha de navegação", "system": "navigation", "severity": 2, "repair": 22.0}
}

func _ready() -> void:
    set_process(true)

func _process(delta: float) -> void:
    for id in failures:
        var f: Dictionary = failures[id]
        f["age"] = float(f.get("age", 0.0)) + delta
        if int(f.get("severity", 1)) >= SEVERITY_CRITICAL and f.age > 45.0:
            EventBus.post("Falha crítica sem atenção: " + definitions[id].title, "critical")

func create_failure(id: String) -> bool:
    if failures.has(id) or not definitions.has(id):
        return false
    var definition: Dictionary = definitions[id]
    failures[id] = {"id": id, "progress": 0.0, "age": 0.0, "severity": definition.severity}
    failure_opened.emit(id, definition.title)
    EventBus.post("FALHA: " + definition.title, "critical" if definition.severity == 3 else "warning")
    return true

func repair(id: String, tool_quality := 1.0) -> bool:
    if not failures.has(id):
        return false
    var definition: Dictionary = definitions[id]
    var f: Dictionary = failures[id]
    f.progress = min(100.0, f.progress + float(definition.repair) * tool_quality)
    failure_progressed.emit(id, f.progress)
    if f.progress >= 100.0:
        failures.erase(id)
        failure_closed.emit(id)
        EventBus.post("Reparo concluído: " + definition.title, "good")
    else:
        EventBus.post("Diagnóstico %s: %d%%" % [definition.title, int(f.progress)], "info")
    return true

func has(id: String) -> bool:
    return failures.has(id)

func count_active() -> int:
    return failures.size()

func snapshot() -> Dictionary:
    return failures.duplicate(true)

func restore(data: Dictionary) -> void:
    failures = data.duplicate(true)
