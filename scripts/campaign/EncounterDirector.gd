extends Node
class_name LL_EncounterDirector

signal encounter_started(id: String, title: String)
signal encounter_updated(id: String, text: String)
signal encounter_finished(id: String, outcome: String)

var encounters := {
    "first_echo": {
        "title": "O primeiro eco",
        "steps": [
            "O sensor retorna um intervalo que não pertence ao ruído do casco.",
            "A repetição permanece quando todos os instrumentos são desligados.",
            "O silêncio parece conter uma segunda camada.",
            "Uma resposta exige mais do que potência: exige contexto."
        ],
        "required_signal": 60.0
    },
    "dark_transit": {
        "title": "Trânsito escuro",
        "steps": [
            "A estrela de referência desaparece atrás de uma geometria impossível.",
            "A nave continua recebendo luz de uma direção sem fonte.",
            "A IA recomenda não corrigir o curso.",
            "A tripulação precisa decidir se a anomalia é passagem ou destino."
        ],
        "required_signal": 85.0
    }
}
var active_id := ""
var step := 0
var clock := 0.0
var step_duration := 8.0

func start(id: String) -> bool:
    if not encounters.has(id) or not active_id.is_empty():
        return false
    active_id = id
    step = 0
    clock = 0.0
    encounter_started.emit(id, encounters[id].title)
    EventBus.post("ENCONTRO: " + encounters[id].title, "critical")
    _publish_step()
    return true

func _process(delta: float) -> void:
    if active_id.is_empty():
        return
    clock += delta
    if clock < step_duration:
        return
    clock = 0.0
    step += 1
    if step >= encounters[active_id].steps.size():
        _finish()
    else:
        _publish_step()

func _publish_step() -> void:
    var encounter: Dictionary = encounters[active_id]
    var text: String = encounter.steps[step]
    encounter_updated.emit(active_id, text)
    EventBus.post(text, "info")

func _finish() -> void:
    var outcome := "understood" if GameState.anomaly_progress >= encounters[active_id].required_signal else "incomplete"
    encounter_finished.emit(active_id, outcome)
    EventBus.post("Encontro encerrado: " + outcome, "good" if outcome == "understood" else "warning")
    active_id = ""
    step = 0
