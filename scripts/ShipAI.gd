extends Node
class_name ShipAI

signal message_received(message: String)
var trust := 0.0
var active := true
var last_warning := 0.0

func _process(delta: float) -> void:
    if not active:
        return
    last_warning += delta
    if GameState.resources.oxygen < 35.0 and last_warning > 8.0:
        _speak("Oxigênio abaixo do limite confortável. Recomendo suporte de vida online.")
    elif GameState.resources.energy < 20.0 and last_warning > 8.0:
        _speak("Reserva energética crítica. Algumas funções serão priorizadas.")
    elif GameState.anomaly_progress > 50.0 and last_warning > 15.0:
        _speak("O padrão não corresponde a uma emissão natural catalogada.")
    if last_warning > 8.0:
        last_warning = 0.0

func acknowledge_discovery() -> void:
    trust += 0.1
    _speak("Registrei sua hipótese. Não vou substituí-la por uma conclusão automática.")

func _speak(text: String) -> void:
    message_received.emit(text)
    GameState.log_added.emit("IA: " + text, "good")
