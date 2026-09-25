extends Node
class_name ShipIntel

signal message_received(text: String)

var trust := 0.0
var warning_timer := 0.0

func _process(delta: float) -> void:
    warning_timer += delta
    if warning_timer > 12.0:
        warning_timer = 0.0
        if GameState.resources.oxygen < 35.0:
            _speak("Suporte de vida crítico. Oxigênio abaixo do mínimo recomendado.")
        elif GameState.resources.energy < 20.0:
            _speak("Reserva energética baixa. Consumo deve ser prioritizado.")
        elif GameState.anomaly_progress > 60.0:
            _speak("O padrão responde à análise e não é uma emissão natural conhecida.")

func _speak(text: String) -> void:
    message_received.emit(text)
    GameState.log_added.emit("IA: " + text, "good")

func establish_trust() -> void:
    trust += 0.1
    _speak("Sua hipótese foi registrada. Não vou substituir sua análise por uma resposta automática.")
