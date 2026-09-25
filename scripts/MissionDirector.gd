extends Node
class_name MissionDirector

signal objective_changed(title: String, description: String)
signal mission_phase_changed(phase: String)

var current_phase := "EARTH_PREP"

func _ready() -> void:
    GameState.objective_changed.connect(_on_objective_changed)
    GameState.mission_phase_changed.connect(_on_phase_changed)
    _apply_phase("EARTH_PREP")

func _process(_delta: float) -> void:
    if current_phase == "EARTH_PREP":
        if GameState.systems.reactor and GameState.systems.life_support and GameState.systems.comms and GameState.systems.science:
            GameState.advance_phase("LAUNCH")
            _apply_phase("LAUNCH")
    elif current_phase == "LAUNCH":
        if GameState.anomaly_progress >= 100.0 and GameState.resources.fuel >= 50.0:
            GameState.advance_phase("SPACE_TRAVEL")
            _apply_phase("SPACE_TRAVEL")

func _apply_phase(name: String) -> void:
    current_phase = name
    match name:
        "EARTH_PREP":
            GameState.set_objective("Preparar a missão", "Ative reator, suporte de vida, comunicação e laboratório antes do lançamento.")
            GameState.log_added.emit("Objetivo inicial: preparar a nave para a missão de partida.", "good")
        "LAUNCH":
            GameState.set_objective("Lançamento", "Conclua o diagnóstico do sinal e valide os sistemas para partir.")
            GameState.log_added.emit("Lançamento liberado. O sinal responde ao laboratório.", "critical")
        "SPACE_TRAVEL":
            GameState.set_objective("Viagem espacial", "A nave deve deixar o sistema terrestre e avançar rumo ao desconhecido.")
            GameState.log_added.emit("Sistema de propulsão otimizado. O campo de viagem foi aberto.", "critical")

func _on_objective_changed(_title: String, _description: String) -> void:
    pass

func _on_phase_changed(_phase: String) -> void:
    pass
