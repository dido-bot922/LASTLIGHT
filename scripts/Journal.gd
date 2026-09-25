extends Node
class_name Journal

signal entry_added(text: String)

var entries: Array[String] = []

func _ready() -> void:
    GameState.journal_updated.connect(_on_journal_update)
    _add_entry("Registro inicial: a missão foi iniciada em órbita terrestre.")

func _add_entry(text: String) -> void:
    entries.append(text)
    entry_added.emit(text)
    GameState.log_added.emit("JORNAL: " + text, "good")

func _on_journal_update(text: String) -> void:
    _add_entry(text)

func get_recent(count := 5) -> Array[String]:
    var start := max(0, entries.size() - count)
    return entries.slice(start, entries.size())
