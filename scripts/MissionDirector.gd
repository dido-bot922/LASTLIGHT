extends Node

var phase := "EARTH_PREP"
var phase_lock := false

func _ready() -> void:
    _set_phase("EARTH_PREP")

func _process(_delta: float) -> void:
    if phase_lock:
        return

    if phase == "EARTH_PREP" and _preflight_ready():
        _set_phase("SIGNAL_ANALYSIS")
    elif phase == "SIGNAL_ANALYSIS" and GameState.anomaly_progress >= 100.0:
        _set_phase("LAUNCH_READY")
    elif phase == "LAUNCH_READY" and GameState.systems.thrusters and GameState.systems.navigation:
        _set_phase("SPACE_TRAVEL")

func _preflight_ready() -> bool:
    return GameState.systems.reactor and GameState.systems.life_support and GameState.systems.comms and GameState.systems.science

func _set_phase(next_phase: String) -> void:
    phase_lock = true
    phase = next_phase
    GameState.advance_phase(next_phase)

    match next_phase:
        "EARTH_PREP":
            GameState.set_objective("Preparar a missão", "Ative reator, suporte de vida, comunicações e laboratório para o desfile inicial.")
        "SIGNAL_ANALYSIS":
            GameState.set_objective("Analisar o sinal", "Execute leituras no laboratório até confirmar o padrão emitido.")
            GameState.log_added.emit("Todos os módulos primários estabilizaram. O sinal precisa de leitura completa.", "good")
        "LAUNCH_READY":
            GameState.set_objective("Validar lançamento", "Ative propulsão e navegação para liberar a partida.")
            GameState.log_added.emit("O padrão não é natural. A janela de lançamento foi aberta.", "critical")
        "SPACE_TRAVEL":
            GameState.set_objective("Cruzar o vazio", "Mantenha a nave estável enquanto a órbita é deixada para trás.")
            GameState.log_added.emit("AURORA-7 sai da órbita terrestre. O silêncio do espaço agora é real.", "critical")

    phase_lock = false
