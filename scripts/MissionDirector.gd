extends Node
class_name MissionDirector

signal objective_changed(title: String, description: String)
signal mission_completed(id: String)
signal phase_changed(phase: String)

var phase := "PREPARATION"
var active_objective := "activate_systems"
var objectives := {
    "activate_systems": {"title": "Acordar a nave", "description": "Ative o reator e o suporte de vida.", "done": false},
    "calibrate_sensors": {"title": "Calibrar sensores", "description": "Ligue comunicação e laboratório e analise o sinal.", "done": false},
    "decode_signal": {"title": "Decodificar LASTLIGHT", "description": "Complete cinco leituras do padrão desconhecido.", "done": false},
    "prepare_launch": {"title": "Preparar lançamento", "description": "Conclua a análise e verifique o combustível.", "done": false}
}
var scans := 0

func _ready() -> void:
    GameState.log_added.connect(_on_log)
    objective_changed.emit(objectives[active_objective].title, objectives[active_objective].description)

func _process(_delta: float) -> void:
    if active_objective == "activate_systems" and GameState.systems.power and GameState.systems.life_support:
        _complete("activate_systems", "Sistemas primários estabilizados.")
        _set_objective("calibrate_sensors")
    elif active_objective == "calibrate_sensors" and GameState.systems.comms and GameState.systems.science:
        _complete("calibrate_sensors", "Matriz científica pronta.")
        _set_objective("decode_signal")
    elif active_objective == "decode_signal" and scans >= 5:
        _complete("decode_signal", "O sinal responde às suas medições.")
        _set_objective("prepare_launch")
    elif active_objective == "prepare_launch" and GameState.anomaly_progress >= 100.0 and GameState.resources.fuel >= 50.0:
        _complete("prepare_launch", "A janela de lançamento foi aberta.")
        phase = "LAUNCH_READY"
        phase_changed.emit(phase)
        GameState.log_added.emit("IA: janela de lançamento calculada. A missão pode começar.", "critical")

func register_scan() -> void:
    scans += 1
    GameState.scan_anomaly()

func _set_objective(id: String) -> void:
    active_objective = id
    objective_changed.emit(objectives[id].title, objectives[id].description)
    GameState.log_added.emit("OBJETIVO: " + objectives[id].title, "good")

func _complete(id: String, message: String) -> void:
    if objectives[id].done:
        return
    objectives[id].done = true
    mission_completed.emit(id)
    GameState.log_added.emit(message, "good")

func _on_log(_message: String, _severity: String) -> void:
    pass
