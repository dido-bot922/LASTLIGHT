extends Node
class_name LL_SaveManager

const PATH := "user://lastlight_profile.json"
const VERSION := 2
signal saved
signal loaded
signal failed(message: String)

func save_profile(extra: Dictionary = {}) -> bool:
    var payload := {
        "version": VERSION,
        "timestamp": Time.get_datetime_string_from_system(),
        "phase": GameState.phase,
        "objective": {"title": GameState.objective_title, "description": GameState.objective_description},
        "resources": GameState.resources.duplicate(true),
        "systems": GameState.systems.duplicate(true),
        "anomaly": GameState.anomaly_progress,
        "scans": GameState.scans_completed,
        "extra": extra
    }
    var file := FileAccess.open(PATH, FileAccess.WRITE)
    if file == null:
        failed.emit("Não foi possível abrir o arquivo de salvamento.")
        return false
    file.store_string(JSON.stringify(payload, "  "))
    file.close()
    saved.emit()
    EventBus.post("Registro de missão salvo.", "good")
    return true

func load_profile() -> bool:
    if not FileAccess.file_exists(PATH):
        failed.emit("Nenhum registro encontrado.")
        return false
    var file := FileAccess.open(PATH, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if not parsed is Dictionary or int(parsed.get("version", 0)) > VERSION:
        failed.emit("Versão de registro incompatível.")
        return false
    GameState.phase = str(parsed.get("phase", GameState.phase))
    GameState.resources = parsed.get("resources", GameState.resources)
    GameState.systems = parsed.get("systems", GameState.systems)
    GameState.anomaly_progress = float(parsed.get("anomaly", 0.0))
    GameState.scans_completed = int(parsed.get("scans", 0))
    GameState.resources_changed.emit(GameState.resources)
    GameState.anomaly_changed.emit(GameState.anomaly_progress)
    loaded.emit()
    EventBus.post("Registro de missão restaurado.", "good")
    return true
