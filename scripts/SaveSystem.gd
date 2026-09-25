extends Node
class_name SaveSystem

const SAVE_PATH := "user://lastlight_save.json"

func save_game() -> bool:
    var data := {
        "version": 1,
        "resources": GameState.resources,
        "systems": GameState.systems,
        "anomaly_progress": GameState.anomaly_progress,
        "mission_time": GameState.mission_time
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        GameState.log_added.emit("Falha ao criar registro de missão.", "critical")
        return false
    file.store_string(JSON.stringify(data))
    file.close()
    GameState.log_added.emit("Registro da missão salvo.", "good")
    return true

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if not parsed is Dictionary:
        return false
    for key in ["resources", "systems"]:
        if parsed.has(key):
            if key == "resources": GameState.resources = parsed[key]
            else: GameState.systems = parsed[key]
    GameState.anomaly_progress = float(parsed.get("anomaly_progress", 0.0))
    GameState.mission_time = float(parsed.get("mission_time", 0.0))
    GameState.resources_changed.emit(GameState.resources)
    GameState.anomaly_changed.emit(GameState.anomaly_progress)
    GameState.log_added.emit("Registro da missão restaurado.", "good")
    return true
