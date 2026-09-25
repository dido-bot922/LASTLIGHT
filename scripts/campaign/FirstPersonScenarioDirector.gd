extends Node
class_name LL_FirstPersonScenarioDirector

signal scenario_started(id: String)
signal scenario_step(id: String, step: int, text: String)
signal scenario_finished(id: String, outcome: String)

var scenarios := {
    "reactor_failure": {
        "steps": [
            "As luzes do corredor oscilam uma vez.",
            "A temperatura do painel sobe além da margem operacional.",
            "A IA isola o compartimento do reator.",
            "A última decisão precisa ser feita manualmente."
        ],
        "duration": 5.0
    },
    "first_contact": {
        "steps": [
            "O ruído abandona o espectro conhecido.",
            "A cabine fica silenciosa, embora os ventiladores continuem ativos.",
            "Uma sequência de três pulsos espera por resposta.",
            "A câmera permanece em primeira pessoa: ninguém pode decidir por você."
        ],
        "duration": 7.0
    }
}
var active_id := ""
var active_step := 0
var elapsed := 0.0

func start(id: String) -> bool:
    if active_id != "" or not scenarios.has(id):
        return false
    active_id = id
    active_step = 0
    elapsed = 0.0
    scenario_started.emit(id)
    EventBus.post("CENA: " + id, "critical")
    _publish()
    return true

func _process(delta: float) -> void:
    if active_id == "":
        return
    elapsed += delta
    if elapsed < float(scenarios[active_id].duration):
        return
    elapsed = 0.0
    active_step += 1
    if active_step >= scenarios[active_id].steps.size():
        var completed := active_id
        active_id = ""
        scenario_finished.emit(completed, "observed")
        EventBus.post("Cena concluída: " + completed, "good")
    else:
        _publish()

func _publish() -> void:
    var text: String = scenarios[active_id].steps[active_step]
    scenario_step.emit(active_id, active_step, text)
    EventBus.post(text, "info")
