extends Node
class_name LL_ResearchArchive

var records: Dictionary = {}
var tags: Dictionary = {}

func record(id: String, title: String, body: String, category := "mission") -> void:
    records[id] = {"title": title, "body": body, "category": category, "time": Time.get_datetime_string_from_system()}
    tags[id] = []
    EventBus.post("Registro arquivado: " + title, "good")

func add_tag(id: String, tag: String) -> void:
    if not records.has(id):
        return
    if not tags.has(id):
        tags[id] = []
    if tag not in tags[id]:
        tags[id].append(tag)

func search(query: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    var needle := query.to_lower()
    for id in records:
        var record_data: Dictionary = records[id]
        if str(record_data.title).to_lower().contains(needle) or str(record_data.body).to_lower().contains(needle):
            result.append(record_data.duplicate(true))
    return result

func export_json() -> String:
    return JSON.stringify({"records": records, "tags": tags}, "  ")

func import_json(text: String) -> bool:
    var parsed = JSON.parse_string(text)
    if not parsed is Dictionary:
        return false
    records = parsed.get("records", {})
    tags = parsed.get("tags", {})
    return true
