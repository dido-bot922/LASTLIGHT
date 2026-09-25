extends Node
class_name LL_EnvironmentalHazardSystem

signal hazard_entered(id: String)
signal hazard_exited(id: String)
signal exposure_changed(id: String, exposure: float)

var hazards := {
    "radiation_zone": {"radius": 4.0, "damage": 0.12, "resource": "radiation"},
    "thermal_zone": {"radius": 3.0, "damage": 0.08, "resource": "temperature"},
    "vacuum_zone": {"radius": 2.0, "damage": 0.16, "resource": "oxygen"}
}
var active: Dictionary = {}
var exposures: Dictionary = {}

func enter(id: String) -> bool:
    if not hazards.has(id):
        return false
    if not active.has(id):
        active[id] = true
        exposures[id] = 0.0
        hazard_entered.emit(id)
        EventBus.post("Zona de risco: " + id, "warning")
    return true

func leave(id: String) -> void:
    if active.erase(id):
        hazard_exited.emit(id)
        EventBus.post("Saída da zona de risco: " + id, "good")

func _process(delta: float) -> void:
    for id in active:
        var definition: Dictionary = hazards[id]
        exposures[id] = minf(100.0, float(exposures[id]) + delta * 4.0)
        exposure_changed.emit(id, exposures[id])
        _apply_exposure(id, definition, delta)

func _apply_exposure(id: String, definition: Dictionary, delta: float) -> void:
    var resource_id: String = definition.resource
    if resource_id == "radiation":
        ResourceSystem.change("radiation", delta * definition.damage * 10.0)
    elif resource_id == "oxygen":
        ResourceSystem.change("oxygen", -delta * definition.damage * 10.0)
    elif resource_id == "temperature":
        ResourceSystem.change("temperature", delta * definition.damage * 5.0)
