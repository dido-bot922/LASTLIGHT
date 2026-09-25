extends Node
class_name LL_SubtitleDirector

signal subtitle_started(text: String)
signal subtitle_finished

var queue: Array[Dictionary] = []
var active := {}
var elapsed := 0.0

func enqueue(text: String, duration := 3.5, speaker := "") -> void:
    queue.append({"text": text, "duration": duration, "speaker": speaker})
    if active.is_empty():
        _next()

func clear() -> void:
    queue.clear()
    active.clear()
    elapsed = 0.0
    subtitle_finished.emit()

func _process(delta: float) -> void:
    if active.is_empty():
        return
    elapsed += delta
    if elapsed >= float(active.duration):
        _next()

func _next() -> void:
    if queue.is_empty():
        active.clear()
        elapsed = 0.0
        subtitle_finished.emit()
        return
    active = queue.pop_front()
    elapsed = 0.0
    subtitle_started.emit(str(active.text))
    EventBus.remember("subtitle", active)
