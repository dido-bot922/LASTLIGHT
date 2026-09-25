extends Node
class_name LL_ChoiceSystem

signal choice_presented(id: String, title: String, options: Array)
signal choice_selected(id: String, option: String)

var choices := {
    "first_signal": {
        "title": "O sinal está respondendo. O que fazer?",
        "options": ["analyze", "silence", "broadcast"],
        "descriptions": {
            "analyze": "Aumentar a resolução científica.",
            "silence": "Reduzir emissão e observar.",
            "broadcast": "Enviar uma resposta simples."
        }
    },
    "reactor_load": {
        "title": "O reator está instável.",
        "options": ["throttle", "overdrive", "shutdown"],
        "descriptions": {
            "throttle": "Reduzir potência e preservar combustível.",
            "overdrive": "Forçar potência para acelerar a missão.",
            "shutdown": "Desligar o núcleo e perder tempo."
        }
    }
}
var decisions := {}

func present(id: String) -> bool:
    if not choices.has(id):
        return false
    var choice: Dictionary = choices[id]
    choice_presented.emit(id, choice.title, choice.options)
    EventBus.post("DECISÃO: " + choice.title, "warning")
    return true

func select(id: String, option: String) -> bool:
    if not choices.has(id) or option not in choices[id].options:
        return false
    decisions[id] = option
    choice_selected.emit(id, option)
    _apply(id, option)
    return true

func has_decision(id: String) -> bool:
    return decisions.has(id)

func get_decision(id: String) -> String:
    return str(decisions.get(id, ""))

func _apply(id: String, option: String) -> void:
    match id:
        "first_signal":
            if option == "analyze":
                GameState.resources.signal = min(100.0, GameState.resources.signal + 20.0)
                EventBus.post("A análise ganhou prioridade. O padrão ficou mais nítido.", "good")
            elif option == "silence":
                GameState.resources.signal = max(0.0, GameState.resources.signal - 10.0)
                EventBus.post("A emissão foi reduzida. A resposta permanece desconhecida.", "info")
            elif option == "broadcast":
                AlienSignal.observe("human_response")
                EventBus.post("Resposta transmitida. Agora existe uma testemunha do contato.", "critical")
        "reactor_load":
            if option == "throttle":
                ResourceSystem.set_rate("energy", 0.03)
                EventBus.post("Reator limitado. Segurança acima de velocidade.", "good")
            elif option == "overdrive":
                ResourceSystem.set_rate("energy", -0.3)
                FailureSystem.create_failure("thermal_spike")
                EventBus.post("Overdrive ativado. O núcleo está aquecendo.", "warning")
            elif option == "shutdown":
                GameState.systems.reactor = false
                EventBus.post("Reator desligado manualmente.", "warning")
