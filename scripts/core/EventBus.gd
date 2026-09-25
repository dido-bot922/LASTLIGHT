extends Node
class_name LL_EventBus

signal notification(text: String, severity: String)
signal objective_started(id: String, title: String)
signal objective_completed(id: String)
signal objective_failed(id: String, reason: String)
signal system_state_changed(id: String, state: String)
signal failure_created(id: String, severity: int)
signal failure_resolved(id: String)
signal science_result(id: String, quality: float)
signal alien_pattern_received(pattern: String, confidence: float)
signal chapter_changed(id: String)

var history: Array[Dictionary] = []
var max_history := 200
var sequence := 0

func post(text: String, severity := "info") -> void:
    sequence += 1
    history.append({"sequence": sequence, "text": text, "severity": severity, "time": Time.get_ticks_msec()})
    _trim_history()
    notification.emit(text, severity)
    var state := get_node_or_null("/root/GameState")
    if state != null and state.has_signal("log_added"):
        state.log_added.emit(text, severity)

func remember(event_name: String, payload: Dictionary = {}) -> void:
    sequence += 1
    history.append({"sequence": sequence, "event": event_name, "payload": payload, "time": Time.get_ticks_msec()})
    _trim_history()

func recent(limit := 20) -> Array[Dictionary]:
    var safe_limit := maxi(0, mini(limit, history.size()))
    return history.slice(history.size() - safe_limit, history.size())

func find_event(event_name: String, limit := 20) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for item in history:
        if item.get("event", "") == event_name:
            result.append(item.duplicate(true))
    if result.size() > limit:
        return result.slice(result.size() - limit, result.size())
    return result

func clear_history() -> void:
    history.clear()
    sequence = 0

func _trim_history() -> void:
    while history.size() > max_history:
        history.pop_front()
