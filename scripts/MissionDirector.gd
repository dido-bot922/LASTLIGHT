extends Node
class_name MissionDirector

var current_phase := "EARTH_PREP"
var transition_lock := false

func _ready() -> void:
    _set_phase("EARTH_PREP")

func _process(_delta: float) -> void:
    if transition_lock:
        return
    if current_phase == "EARTH_PREP" and _all_preflight_systems_ready():
        _set_phase("SIGNAL_ANALYSIS")
    elif current_phase == "SIGNAL_ANALYSIS" and GameState.anomaly_progress >= 100.0:
        _set_phase("LAUNCH_READY")
    elif current_phase == "LAUNCH_READY" and GameState.systems.thrusters and GameState.systems.navigation:
        _set_phase("SPACE_TRAVEL")

func _all_preflight_systems_ready() -> bool:
    return GameState.systems.reactor and GameState.systems.life_support and GameState.systems.comms and GameState.systems.science

func _set_phase(next_phase: String) -> void:
    transition_lock = true
    current_phase = next_phase
    GameState.advance_phase(next_phase)
    match next_phase:
        "EARTH_PREP":
            GameState.set_objective("Preparar a missão", "Ative reator, suporte de vida, comunicação e laboratório.")
        "SIGNAL_ANALYSIS":
            GameState.set_objective("Investigar o sinal", "Realize cinco leituras no terminal científico.")
            GameState.log_added.emit("Todos os sistemas básicos respondem. O sinal precisa de uma análise completa.", "good")
        "LAUNCH_READY":
            GameState.set_objective("Validar lançamento", "Ative propulsão e navegação para liberar a partida.")
            GameState.log_added.emit("A análise revelou uma emissão deliberada. A janela de lançamento está aberta.", "critical")
        "SPACE_TRAVEL":
            GameState.set_objective("Cruzar o vazio", "Mantenha os sistemas estáveis durante a primeira transferência orbital.")
            GameState.log_added.emit("AURORA-7 deixou a órbita terrestre. O silêncio agora é absoluto.", "critical")
    await get_tree().process_frame
    transition_lock = false
