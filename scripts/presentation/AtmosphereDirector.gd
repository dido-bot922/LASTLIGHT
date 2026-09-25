extends Node
class_name LL_AtmosphereDirector

var phase := "calm"
var intensity := 0.2
var event_clock := 0.0
var events := ["distant_rumble", "panel_flicker", "static_burst", "cold_breath", "hull_click"]

func _process(delta: float) -> void:
    event_clock += delta
    if event_clock < 18.0:
        return
    event_clock = 0.0
    _advance_atmosphere()

func set_phase(next_phase: String) -> void:
    phase = next_phase
    match phase:
        "calm": intensity = 0.2
        "uneasy": intensity = 0.45
        "contact": intensity = 0.75
        "crisis": intensity = 1.0
    EventBus.post("Atmosfera: " + phase, "info")

func _advance_atmosphere() -> void:
    var event_id: String = events[randi() % events.size()]
    EventBus.remember("atmosphere_event", {"id": event_id, "intensity": intensity})
    if intensity > 0.65:
        AudioDirector.play_alert("atmosphere")
    EventBus.post("Sinal ambiental: " + event_id, "info")
