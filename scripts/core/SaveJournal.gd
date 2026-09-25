extends Node
class_name LL_SaveJournal

const PATH := "user://lastlight_journal.json"
var entries: Array[Dictionary] = []

func _ready() -> void:
    EventBus.notification.connect(_on_notification)
    _load()

func add_entry(title: String, body: String, category := "mission") -> void:
    entries.append({"title": title, "body": body, "category": category, "time": Time.get_datetime_string_from_system()})
    if entries.size() > 500:
        entries.pop_front()
    _save()

func search(query: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    var needle := query.to_lower()
    for entry in entries:
        if str(entry.title).to_lower().contains(needle) or str(entry.body).to_lower().contains(needle):
            result.append(entry.duplicate(true))
    return result

func _on_notification(text: String, severity: String) -> void:
    add_entry(severity.to_upper(), text, severity)

func _save() -> void:
    var file := FileAccess.open(PATH, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify({"version": 1, "entries": entries}, "  "))
        file.close()

func _load() -> void:
    if not FileAccess.file_exists(PATH):
        return
    var file := FileAccess.open(PATH, FileAccess.READ)
    if file == null:
        return
    var data = JSON.parse_string(file.get_as_text())
    file.close()
    if data is Dictionary and data.get("entries", []) is Array:
        entries = data.entries
