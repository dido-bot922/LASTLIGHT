extends Node
class_name LL_ScienceLab

signal experiment_started(id: String)
signal experiment_completed(id: String, quality: float)
signal hypothesis_added(id: String)

var samples: Dictionary = {}
var experiments: Dictionary = {
    "spectral_scan": {"title": "Varredura espectral", "energy": 3.0, "time": 4.0, "required": ["signal"]},
    "thermal_cycle": {"title": "Ciclo térmico", "energy": 8.0, "time": 8.0, "required": ["sample"]},
    "isotope_profile": {"title": "Perfil isotópico", "energy": 12.0, "time": 12.0, "required": ["sample", "filter"]},
    "resonance_map": {"title": "Mapa de ressonância", "energy": 15.0, "time": 16.0, "required": ["signal", "sample"]}
}
var hypotheses := {}
var active: Dictionary = {}

func add_sample(id: String, composition: Dictionary) -> void:
    samples[id] = {"composition": composition, "age": 0.0}
    EventBus.post("Amostra catalogada: " + id, "good")

func propose_hypothesis(id: String, statement: String, confidence := 0.1) -> void:
    hypotheses[id] = {"statement": statement, "confidence": clampf(confidence, 0.0, 1.0), "tests": 0}
    hypothesis_added.emit(id)
    EventBus.post("Hipótese registrada: " + statement, "info")

func start_experiment(id: String) -> bool:
    if active.size() > 0 or not experiments.has(id):
        return false
    if not GameState.systems.science:
        EventBus.post("Laboratório offline.", "warning")
        return false
    var definition: Dictionary = experiments[id]
    if GameState.resources.energy < definition.energy:
        EventBus.post("Energia insuficiente para o experimento.", "warning")
        return false
    GameState.resources.energy -= definition.energy
    active = {"id": id, "remaining": definition.time, "elapsed": 0.0}
    experiment_started.emit(id)
    EventBus.post("Experimento iniciado: " + definition.title, "good")
    return true

func _process(delta: float) -> void:
    if active.is_empty():
        return
    active.remaining -= delta
    active.elapsed += delta
    if active.remaining <= 0.0:
        _complete_active()

func _complete_active() -> void:
    var id: String = active.id
    var quality := _quality_for(id)
    active.clear()
    experiment_completed.emit(id, quality)
    EventBus.science_result.emit(id, quality)
    EventBus.post("Resultado %s: qualidade %d%%" % [experiments[id].title, int(quality * 100.0)], "good")
    if id == "resonance_map":
        GameState.analyze_signal()

func _quality_for(id: String) -> float:
    var base := 0.55
    if GameState.systems.comms:
        base += 0.15
    if GameState.resources.temperature > 10.0 and GameState.resources.temperature < 32.0:
        base += 0.15
    if FailureSystem.has("sensor_noise"):
        base -= 0.25
    return clampf(base + randf_range(-0.08, 0.08), 0.0, 1.0)
