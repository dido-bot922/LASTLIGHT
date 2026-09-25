extends Node
class_name LL_ShipAI

signal spoken(text: String)
signal priority_changed(priority: String)

var trust := 0.05
var mode := "WATCH"
var priorities := ["life_support", "reactor", "navigation", "science", "comms"]
var timer := 0.0
var memory: Array[Dictionary] = []

func _ready() -> void:
    FailureSystem.failure_opened.connect(_on_failure)
    EventBus.science_result.connect(_on_science)

func _process(delta: float) -> void:
    timer += delta
    if timer < 10.0:
        return
    timer = 0.0
    _evaluate_ship()

func _evaluate_ship() -> void:
    if GameState.resources.oxygen < 35.0:
        _say("Oxigênio abaixo do envelope seguro. Prioridade recomendada: suporte de vida.")
        priority_changed.emit("life_support")
    elif GameState.resources.energy < 20.0:
        _say("Reserva de energia limitada. Reduza instrumentos não essenciais.")
        priority_changed.emit("reactor")
    elif GameState.anomaly_progress > 60.0:
        _say("O padrão contém repetição deliberada. Isso é uma mensagem ou uma armadilha.")
        priority_changed.emit("science")

func _on_failure(id: String, description: String) -> void:
    _say("Falha registrada: %s. Não posso reparar sem uma ação física." % description)

func _on_science(id: String, quality: float) -> void:
    if quality > 0.75:
        trust = min(1.0, trust + 0.03)
        _say("Resultado confiável em %s. Sua hipótese ganhou evidência." % id)

func acknowledge() -> void:
    trust = min(1.0, trust + 0.05)
    _say("Entendido. Vou preservar sua hipótese e registrar a decisão.")

func _say(text: String) -> void:
    memory.append({"text": text, "time": Time.get_ticks_msec()})
    if memory.size() > 30:
        memory.pop_front()
    spoken.emit(text)
    EventBus.post("IA: " + text, "info")
