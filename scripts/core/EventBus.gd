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

func post(text: String, severity := "info") -> void:
    history.append({"text": text, "severity": severity, "time": Time.get_ticks_msec()})
    if history.size() > max_history:
        history.pop_front()
    notification.emit(text, severity)
    if has_node("../GameState"):
        GameState.log_added.emit(text, severity)

func remember(event_name: String, payload: Dictionary = {}) -> void:
    history.append({"event": event_name, "payload": payload, "time": Time.get_ticks_msec()})
    if history.size() > max_history:
        history.pop_front()

func recent(limit := 20) -> Array[Dictionary]:
    return history.slice(max(0, history.size() - limit), history.size())
