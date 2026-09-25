extends Node
class_name LL_Campaign

signal chapter_started(id: String, title: String)
signal chapter_completed(id: String)

var chapters := [
    {"id": "C01", "title": "A última manhã", "phase": "EARTH_PREP"},
    {"id": "C02", "title": "A janela", "phase": "SIGNAL_ANALYSIS"},
    {"id": "C03", "title": "Quatro minutos de silêncio", "phase": "LAUNCH_READY"},
    {"id": "C04", "title": "Além da órbita", "phase": "SPACE_TRAVEL"},
    {"id": "C05", "title": "A resposta", "phase": "FIRST_CONTACT"}
]
var current_index := 0
var flags := {}

func _ready() -> void:
    GameState.mission_phase_changed.connect(_on_phase)
    chapter_started.emit(chapters[0].id, chapters[0].title)

func set_flag(id: String, value = true) -> void:
    flags[id] = value

func has_flag(id: String) -> bool:
    return bool(flags.get(id, false))

func complete_current() -> void:
    if current_index >= chapters.size():
        return
    chapter_completed.emit(chapters[current_index].id)
    current_index = min(current_index + 1, chapters.size() - 1)
    var chapter: Dictionary = chapters[current_index]
    chapter_started.emit(chapter.id, chapter.title)
    EventBus.post("CAPÍTULO: " + chapter.title, "critical")

func _on_phase(next_phase: String) -> void:
    if current_index >= chapters.size():
        return
    if chapters[current_index].phase == next_phase:
        EventBus.post("Capítulo iniciado: " + chapters[current_index].title, "good")
