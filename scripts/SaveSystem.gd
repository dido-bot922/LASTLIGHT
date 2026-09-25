extends Node
class_name SaveSystem

const SAVE_PATH := "user://lastlight_save.json"

func save() -> bool:
    var data := {
        "resources": GameState.resources,
        "systems": GameState.systems,
        "anomaly_progress": GameState.anomaly_progress,
        "phase": GameState.phase
    }
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f == null:
        GameState.log_added.emit("Falha ao salvar o progresso da missão.", "critical")
        return false
    f.store_string(JSON.stringify(data))
    f.close()
    GameState.log_added.emit("Progresso salvo com sucesso.", "good")
    return true

func load() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var parsed = JSON.parse_string(f.get_as_text())
    f.close()
    if not parsed is Dictionary:
        return false
    if parsed.has("resources"):
        GameState.resources = parsed["resources"]
    if parsed.has("systems"):
        GameState.systems = parsed["systems"]
    if parsed.has("phase"):
        GameState.phase = parsed["phase"]
    GameState.anomaly_progress = float(parsed.get("anomaly_progress", 0.0))
    GameState.resources_changed.emit(GameState.resources)
    GameState.anomaly_changed.emit(GameState.anomaly_progress)
    GameState.log_added.emit("Progresso carregado.", "good")
    return true
