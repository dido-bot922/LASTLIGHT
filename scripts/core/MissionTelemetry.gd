extends Node
class_name LL_MissionTelemetry

signal metric_changed(id: String, value: float)
signal milestone_reached(id: String)

var metrics := {
    "distance_walked": 0.0,
    "time_in_ship": 0.0,
    "interactions": 0.0,
    "repairs": 0.0,
    "experiments": 0.0,
    "failures_resolved": 0.0,
    "signals_observed": 0.0,
    "decisions": 0.0
}
var milestones := {
    "first_step": false,
    "first_interaction": false,
    "first_repair": false,
    "first_experiment": false,
    "first_contact": false
}
var _last_position := Vector3.ZERO
var _has_position := false

func _process(delta: float) -> void:
    metrics.time_in_ship += delta
    _check_milestones()

func track_position(position_3d: Vector3) -> void:
    if _has_position:
        var distance := _last_position.distance_to(position_3d)
        if distance > 0.001 and distance < 2.0:
            metrics.distance_walked += distance
            metric_changed.emit("distance_walked", metrics.distance_walked)
    _last_position = position_3d
    _has_position = true

func increment(id: String, amount := 1.0) -> void:
    if not metrics.has(id):
        metrics[id] = 0.0
    metrics[id] += amount
    metric_changed.emit(id, metrics[id])
    _check_milestones()

func export_report() -> Dictionary:
    return {"metrics": metrics.duplicate(true), "milestones": milestones.duplicate(true), "created": Time.get_datetime_string_from_system()}

func _check_milestones() -> void:
    _milestone("first_step", metrics.distance_walked > 0.5)
    _milestone("first_interaction", metrics.interactions >= 1.0)
    _milestone("first_repair", metrics.repairs >= 1.0)
    _milestone("first_experiment", metrics.experiments >= 1.0)
    _milestone("first_contact", GameState.anomaly_progress >= 100.0)

func _milestone(id: String, condition: bool) -> void:
    if condition and not milestones.get(id, false):
        milestones[id] = true
        milestone_reached.emit(id)
        EventBus.post("MARCO ALCANÇADO: " + id, "good")
