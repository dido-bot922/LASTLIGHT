extends Node
class_name LL_ResourceSystem

signal changed(id: String, value: float, delta: float)
signal critical(id: String, value: float)
signal depleted(id: String)

const DEFINITIONS := {
    "energy": {"min": 0.0, "max": 100.0, "critical": 18.0},
    "oxygen": {"min": 0.0, "max": 100.0, "critical": 24.0},
    "fuel": {"min": 0.0, "max": 100.0, "critical": 15.0},
    "temperature": {"min": -40.0, "max": 80.0, "critical": 8.0},
    "radiation": {"min": 0.0, "max": 100.0, "critical": 70.0},
    "pressure": {"min": 0.0, "max": 1.0, "critical": 0.35},
    "signal": {"min": 0.0, "max": 100.0, "critical": 8.0}
}

var values := {
    "energy": 82.0, "oxygen": 96.0, "fuel": 74.0,
    "temperature": 21.0, "radiation": 3.0, "pressure": 1.0, "signal": 0.0
}
var rates := {}
var paused := false

func _ready() -> void:
    for id in DEFINITIONS:
        rates[id] = 0.0

func _process(delta: float) -> void:
    if paused:
        return
    for id in rates:
        if absf(rates[id]) > 0.00001:
            change(id, rates[id] * delta)

func set_rate(id: String, per_second: float) -> void:
    if DEFINITIONS.has(id):
        rates[id] = per_second

func change(id: String, amount: float) -> bool:
    if not DEFINITIONS.has(id):
        return false
    var old: float = values.get(id, 0.0)
    var definition: Dictionary = DEFINITIONS[id]
    var next := clampf(old + amount, definition.min, definition.max)
    values[id] = next
    var actual := next - old
    changed.emit(id, next, actual)
    if next <= definition.critical or (id == "radiation" and next >= definition.critical):
        critical.emit(id, next)
    if is_zero_approx(next - definition.min):
        depleted.emit(id)
    return true

func set_value(id: String, value: float) -> bool:
    if not DEFINITIONS.has(id):
        return false
    var old: float = values.get(id, 0.0)
    values[id] = clampf(value, DEFINITIONS[id].min, DEFINITIONS[id].max)
    changed.emit(id, values[id], values[id] - old)
    return true

func get_value(id: String) -> float:
    return float(values.get(id, 0.0))

func snapshot() -> Dictionary:
    return values.duplicate(true)

func restore(data: Dictionary) -> void:
    for id in DEFINITIONS:
        if data.has(id):
            set_value(id, float(data[id]))
