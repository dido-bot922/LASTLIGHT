extends Node
class_name CinematicDirector

signal shot_changed(id: String)
signal caption_changed(text: String)

var active_shot := "gameplay"
var shots := {
    "gameplay": {"fov": 76.0, "shake": 0.0, "caption": ""},
    "impact": {"fov": 70.0, "shake": 0.22, "caption": "IMPACTO ESTRUTURAL"},
    "contact": {"fov": 68.0, "shake": 0.04, "caption": "SINAL EXTERNO CONFIRMADO"},
    "emergency": {"fov": 80.0, "shake": 0.12, "caption": "PROTOCOLO DE EMERGÊNCIA"}
}
var timer := 0.0
var shot_duration := 0.0

func play_shot(id: String, duration := 1.0) -> bool:
    if not shots.has(id):
        return false
    active_shot = id
    shot_duration = duration
    timer = 0.0
    shot_changed.emit(id)
    caption_changed.emit(shots[id].caption)
    return true

func _process(delta: float) -> void:
    if shot_duration <= 0.0:
        return
    timer += delta
    if timer >= shot_duration:
        timer = 0.0
        shot_duration = 0.0
        play_shot("gameplay", 0.0)

func get_camera_profile() -> Dictionary:
    return shots.get(active_shot, shots.gameplay).duplicate(true)
